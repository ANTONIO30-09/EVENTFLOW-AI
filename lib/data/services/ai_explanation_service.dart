import 'dart:convert';
import 'package:http/http.dart' as http;
import 'seating_service.dart';

class AiExplanationService {
  static const String _apiKey = String.fromEnvironment('GROQ_API_KEY');
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'openai/gpt-oss-20b';

  Future<String> generateExplanation(DistributionResult result) async {
    if (_apiKey.isEmpty) {
      return 'No se configuró la API key de Groq. La distribución se generó correctamente.';
    }

    final prompt = _buildPrompt(result);

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Sos un asistente que explica en español la distribución de invitados en un evento. No cambies la asignación, solo explícala de forma clara y breve.'
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.4,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>;
        final first = choices.first as Map<String, dynamic>;
        final message = first['message'] as Map<String, dynamic>;
        return message['content'] as String? ?? 'No se obtuvo explicación.';
      } else {
        return 'Error al generar explicación: ${response.statusCode}';
      }
    } catch (e) {
      return 'No se pudo conectar con Groq: $e';
    }
  }

  String _buildPrompt(DistributionResult result) {
    final buffer = StringBuffer();
    buffer.writeln('Distribución generada:');
    for (final assignment in result.assignments) {
      final guests = assignment.guests.join(', ');
      buffer.writeln('${assignment.tableName}: $guests');
    }
    if (result.unassignedGuests.isNotEmpty) {
      buffer.writeln('Sin asignar: ${result.unassignedGuests.join(', ')}');
    }
    if (result.warning != null) {
      buffer.writeln('Advertencia: ${result.warning}');
    }
    buffer.writeln('Explicá brevemente por qué quedó así esta distribución.');
    return buffer.toString();
  }
}
