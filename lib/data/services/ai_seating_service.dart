import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/guest_model.dart';
import '../models/seating_table_model.dart';
import '../models/compatibility_rule_model.dart';
import 'seating_service.dart';

/// Excepción para respuestas de Groq inválidas (JSON malformado, etc).
class AiInvalidResponseException implements Exception {
  final String message;
  AiInvalidResponseException(this.message);
  @override
  String toString() => 'AiInvalidResponseException: $message';
}

/// Motor de IA generativo para distribución de mesas.
///
/// Flujo:
/// 1. Construye un prompt con invitados, familias, reglas y mesas.
/// 2. Llama a Groq (openai/gpt-oss-20b, T=0.2, json_object).
/// 3. Parsea JSON estricto.
/// 4. Valida con SeatingService.validateAiDistribution.
/// 5. Si falla, reintenta UNA vez con el error como hint.
/// 6. Si vuelve a fallar, hace fallback al algoritmo determinístico.
class AiSeatingService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'openai/gpt-oss-20b';
  static const Duration _timeout = Duration(seconds: 15);

  final SeatingService _seatingService = SeatingService();

  /// Genera una distribución con IA, validada contra el algoritmo.
  ///
  /// Siempre devuelve un [DistributionResult] válido. Si la IA falla 2 veces,
  /// devuelve el resultado del algoritmo determinístico con
  /// `source: DistributionSource.algorithm`.
  Future<DistributionResult> generateWithAI({
    required String eventName,
    required List<GuestModel> guests,
    required List<SeatingTable> tables,
    required List<CompatibilityRule> rules,
  }) async {
    if (_apiKey.isEmpty) {
      return _fallback(guests: guests, tables: tables, rules: rules);
    }

    final baseUserPrompt = _buildUserPrompt(
      eventName: eventName,
      guests: guests,
      tables: tables,
      rules: rules,
    );

    String? retryHint;

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final userPrompt = retryHint == null
            ? baseUserPrompt
            : '$baseUserPrompt\n\n$retryHint';

        final rawBody = await _callGroq(
          systemPrompt: _systemPrompt,
          userPrompt: userPrompt,
        );

        final parsed = _parseResponse(rawBody);

        final errors = _seatingService.validateAiDistribution(
          aiResult: parsed,
          guests: guests,
          tables: tables,
          rules: rules,
        );

        if (errors.isEmpty) {
          return _buildResult(parsed, source: DistributionSource.ai);
        }

        retryHint = _buildValidationRetryHint(errors);
      } on AiInvalidResponseException catch (e) {
        retryHint = _buildJsonRetryHint(e.message);
      } catch (_) {
        retryHint = _buildJsonRetryHint('Error desconocido al procesar la respuesta.');
      }
    }

    return _fallback(guests: guests, tables: tables, rules: rules);
  }

  // ============================================================
  // PROMPTS (aprobados por el usuario, no modificar sin consultar)
  // ============================================================

  static const String _systemPrompt = """Sos un asistente experto en logística de eventos. Recibís una lista de invitados con sus familias, reglas de compatibilidad y mesas disponibles con su capacidad. Devolvés una asignación óptima en formato JSON estricto.

REGLAS OBLIGATORIAS (violarlas invalida tu respuesta):
1. Cada invitado debe aparecer EXACTAMENTE UNA vez entre "assignments" y "unassigned".
2. Ninguna mesa puede tener más invitados que su "capacity".
3. PROHIBIDO asignar juntos a dos invitados con regla "forbid".
4. Si dos invitados tienen regla "prefer", asignalos juntos siempre que haya espacio.
5. Invitados con el mismo "familyGroup" deben ir en la misma mesa si hay espacio.
6. Si no hay espacio para todos, los sobrantes van en "unassigned".
7. Usá EXCLUSIVAMENTE nombres textuales de la lista de invitados. NO inventes personas, NO cambies apellidos, NO agregues datos.
8. Devolvé SOLO el JSON. Sin markdown, sin texto extra, sin comentarios.
9. IMPORTANTE: el campo "+N acompañantes" es SOLO informativo. NO suma sillas a la capacidad de la mesa. Cada invitado ocupa exactamente 1 silla, independientemente de sus acompañantes.

FORMATO DE SALIDA OBLIGATORIO:
{
  "assignments": [
    {"table": "Mesa 1", "guests": ["Nombre Apellido", "Otro Nombre"]}
  ],
  "unassigned": ["Nombre Sobrante"]
}""";

  String _buildUserPrompt({
    required String eventName,
    required List<GuestModel> guests,
    required List<SeatingTable> tables,
    required List<CompatibilityRule> rules,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Evento: $eventName');
    buffer.writeln();
    buffer.writeln('MESAS DISPONIBLES (${tables.length}):');
    for (final t in tables) {
      buffer.writeln('- ${t.name} (capacidad: ${t.capacity})');
    }
    buffer.writeln();
    buffer.writeln('INVITADOS (${guests.length}):');
    for (final g in guests) {
      final familia = g.familyGroup.isEmpty ? '(sin grupo)' : g.familyGroup;
      final plural = g.companions == 1 ? 'acompañante' : 'acompañantes';
      buffer.writeln('- ${g.name} | Familia: $familia | +${g.companions} $plural');
    }
    buffer.writeln();
    buffer.writeln('REGLAS DE COMPATIBILIDAD (${rules.length}):');
    if (rules.isEmpty) {
      buffer.writeln('- (sin reglas cargadas)');
    } else {
      for (final r in rules) {
        final symbol = r.ruleType == 'forbid' ? '≠' : '=';
        final label = r.ruleType == 'forbid' ? 'FORBID' : 'PREFER';
        buffer.writeln('- $label: ${r.guestA} $symbol ${r.guestB}');
      }
    }
    buffer.writeln();
    buffer.writeln('Generá la asignación óptima respetando TODAS las reglas. Devolvé SOLO el JSON.');
    return buffer.toString();
  }

  String _buildValidationRetryHint(List<String> errors) {
    final buffer = StringBuffer();
    buffer.writeln('IMPORTANTE: Tu respuesta anterior tuvo estos problemas:');
    for (final e in errors) {
      buffer.writeln('- $e');
    }
    buffer.writeln('Corregí esos problemas respetando TODAS las reglas anteriores. Devolvé SOLO el JSON.');
    return buffer.toString();
  }

  String _buildJsonRetryHint(String parseError) {
    return 'IMPORTANTE: Tu respuesta anterior no fue un JSON válido. Error: $parseError\n\nDevolvé SOLO el JSON, sin markdown, sin texto extra, sin bloques de código.';
  }

  // ============================================================
  // LLAMADA A GROQ
  // ============================================================

  Future<String> _callGroq({
    required String systemPrompt,
    required String userPrompt,
  }) async {
    final response = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': _model,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
            'temperature': 0.2,
            'max_tokens': 2000,
            'response_format': {'type': 'json_object'},
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AiInvalidResponseException(
          'Groq respondió con status ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw AiInvalidResponseException('Groq no devolvió choices.');
    }
    final first = choices.first as Map<String, dynamic>;
    final message = first['message'] as Map<String, dynamic>?;
    final content = message?['content'] as String?;
    if (content == null || content.isEmpty) {
      throw AiInvalidResponseException('Groq devolvió contenido vacío.');
    }
    return content;
  }

  Map<String, dynamic> _parseResponse(String raw) {
    var cleaned = raw.trim();
    // Quitar bloques de markdown si Groq los agregó a pesar del response_format.
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll(RegExp(r'^```[a-zA-Z]*\n?'), '');
      cleaned = cleaned.replaceAll(RegExp(r'\n?```$'), '');
      cleaned = cleaned.trim();
    }
    try {
      final parsed = jsonDecode(cleaned);
      if (parsed is! Map<String, dynamic>) {
        throw AiInvalidResponseException('La respuesta no es un objeto JSON.');
      }
      return parsed;
    } catch (e) {
      throw AiInvalidResponseException('JSON malformado: $e');
    }
  }

  DistributionResult _buildResult(
    Map<String, dynamic> parsed, {
    required DistributionSource source,
  }) {
    final rawAssignments = (parsed['assignments'] as List).cast<dynamic>();
    final rawUnassigned =
        (parsed['unassigned'] as List?)?.cast<dynamic>() ?? <dynamic>[];

    final assignments = <TableAssignment>[];
    for (final item in rawAssignments) {
      final map = item as Map<String, dynamic>;
      final table = map['table'] as String;
      final guestsList = (map['guests'] as List).cast<String>();
      assignments.add(TableAssignment(tableName: table, guests: guestsList));
    }

    final unassigned = rawUnassigned.cast<String>();

    return DistributionResult(
      assignments: assignments,
      unassignedGuests: unassigned,
      source: source,
    );
  }

  DistributionResult _fallback({
    required List<GuestModel> guests,
    required List<SeatingTable> tables,
    required List<CompatibilityRule> rules,
  }) {
    return _seatingService.generateDistribution(
      guests: guests,
      tables: tables,
      rules: rules,
    );
  }
}
