import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/event_model.dart';
import '../../data/models/guest_model.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/database_service.dart';
import '../../widgets/neon_bottom_nav.dart';
import 'event_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 24),
              Text(
                'Próximos Eventos',
                style: GoogleFonts.fraunces(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.superficiePorcelana,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<EventModel>>(
                  stream: databaseService.streamEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.acentoBronce,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar eventos',
                          style: GoogleFonts.inter(
                            color: AppColors.alertaLadrillo,
                          ),
                        ),
                      );
                    }
                    final events = snapshot.data ?? [];
                    if (events.isEmpty) {
                      return Center(
                        child: Text(
                          'Todavía no hay eventos registrados.',
                          style: GoogleFonts.inter(
                            color: AppColors.textoSecundarioGris,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    // El primer evento que esté "en_curso" va destacado;
                    // si ninguno lo está, el primero de la lista.
                    final featuredIndex = events.indexWhere(
                      (e) => e.status == 'en_curso',
                    );
                    final featuredIdx = featuredIndex >= 0 ? featuredIndex : 0;
                    final featured = events[featuredIdx];
                    final rest = [
                      ...events.sublist(0, featuredIdx),
                      ...events.sublist(featuredIdx + 1),
                    ];

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        _FeaturedEventCard(
                          event: featured,
                          onTap: () => _openEvent(context, featured),
                        ),
                        if (rest.isNotEmpty) const SizedBox(height: 20),
                        ...rest.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SecondaryEventTile(
                              event: e,
                              onTap: () => _openEvent(context, e),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  void _openEvent(BuildContext context, EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
    );
  }

  // ============================================================
  // Header con avatar + nombre + rol
  // ============================================================
  Widget _buildHeader() {
    return FutureBuilder<UserModel?>(
      future: AuthService().fetchCurrentUserProfile(),
      builder: (context, snap) {
        final user = snap.data;
        final nombre = user?.name ?? 'Usuario';
        final rol = user == null
            ? ''
            : (user.isOrganizador ? 'Organizador' : 'Personal de Campo');
        return Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.acentoBronce,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.fondoAzulNoche,
                    size: 34,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bienvenido.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.superficiePorcelana.withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                  Text(
                    nombre,
                    style: GoogleFonts.fraunces(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.acentoBronce,
                      height: 1.05,
                    ),
                  ),
                  if (rol.isNotEmpty)
                    Text(
                      rol,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.superficiePorcelana.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // Barra de búsqueda (píldora blanca)
  // ============================================================
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.superficiePorcelana,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        style: GoogleFonts.inter(
          color: AppColors.fondoAzulNoche,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar evento',
          hintStyle: GoogleFonts.inter(
            color: AppColors.textoSecundarioGris,
            fontSize: 15,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.search,
              color: AppColors.fondoAzulNoche,
              size: 22,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Ícono temático por heurística (sin tocar Firestore)
  // ============================================================
  static IconData _iconForEvent(String name) {
    final n = name.toLowerCase();
    if (n.contains('boda') ||
        n.contains('casamiento') ||
        n.contains('matrimonio')) {
      return Icons.favorite;
    }
    if (n.contains('conferencia') ||
        n.contains('charla') ||
        n.contains('keynote') ||
        n.contains('seminario')) {
      return Icons.mic;
    }
    if (n.contains('cena') || n.contains('gala') || n.contains('banquete')) {
      return Icons.restaurant;
    }
    if (n.contains('cumple') || n.contains('cumpleaños')) {
      return Icons.cake;
    }
    if (n.contains('corporativo') ||
        n.contains('empresa') ||
        n.contains('reunión') ||
        n.contains('reunion')) {
      return Icons.business_center;
    }
    if (n.contains('concierto') ||
        n.contains('música') ||
        n.contains('musica') ||
        n.contains('festival')) {
      return Icons.music_note;
    }
    return Icons.celebration;
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'en_curso' => 'En curso',
      'finalizado' => 'Finalizado',
      _ => 'Próximo',
    };
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return const NeonBottomNav(currentIndex: 0);
  }
}

// ============================================================
// Card destacada (evento en curso o primero de la lista)
// ============================================================
class _FeaturedEventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _FeaturedEventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = HomeScreen._iconForEvent(event.name);
    final statusLabel = HomeScreen._statusLabel(event.status);
    final isRunning = event.status == 'en_curso';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.superficiePorcelana.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.acentoBronce, width: 1.6),
          boxShadow: [
            BoxShadow(
              color: AppColors.acentoBronce.withValues(alpha: 0.18),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.superficiePorcelana,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.acentoBronce, size: 38),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.fraunces(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.fondoAzulNoche,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isRunning
                              ? AppColors.exitoVerdeSalvia.withValues(
                                  alpha: 0.15,
                                )
                              : AppColors.alertaLadrillo.withValues(
                                  alpha: 0.12,
                                ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _AnimatedStatusIcon(isRunning: isRunning),
                            const SizedBox(width: 5),
                            Text(
                              statusLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isRunning
                                    ? AppColors.exitoVerdeSalvia
                                    : AppColors.alertaLadrillo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<GuestModel>>(
                    stream: DatabaseService().streamGuestsForEvent(event.id),
                    builder: (context, snap) {
                      final count = snap.hasData
                          ? snap.data!.length
                          : event.guestCount;
                      return Text(
                        '${event.location} • $count invitados',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textoSecundarioGris,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Tile secundario (resto de los eventos)
// ============================================================
class _SecondaryEventTile extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const _SecondaryEventTile({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.acentoBronce,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.fondoAzulNoche.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.superficiePorcelana,
                  ),
                ),
                const SizedBox(height: 2),
                StreamBuilder<List<GuestModel>>(
                  stream: DatabaseService().streamGuestsForEvent(event.id),
                  builder: (context, snap) {
                    final count = snap.hasData
                        ? snap.data!.length
                        : event.guestCount;
                    return Text(
                      '${event.location} • $count invitados',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.superficiePorcelana.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert,
            color: AppColors.superficiePorcelana.withValues(alpha: 0.7),
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Ícono de estado animado: 🕺 cuando el evento está en curso,
// 💤 cuando está próximo o finalizado.
// ============================================================
class _AnimatedStatusIcon extends StatefulWidget {
  final bool isRunning;
  const _AnimatedStatusIcon({required this.isRunning});

  @override
  State<_AnimatedStatusIcon> createState() => _AnimatedStatusIconState();
}

class _AnimatedStatusIconState extends State<_AnimatedStatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isRunning ? 1400 : 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const emojiStyle = TextStyle(fontSize: 13);
    return SizedBox(
      width: 16,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          if (widget.isRunning) {
            // Bailarín: rotación leve + bounce vertical
            final angle = math.sin(t * math.pi * 2) * 0.10;
            final dy = -math.sin(t * math.pi * 2).abs() * 1.5;
            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.rotate(
                angle: angle,
                child: const Center(child: Text('🕺', style: emojiStyle)),
              ),
            );
          } else {
            // Zzzz: pulso de escala + opacidad
            final pulse = 0.85 + 0.15 * math.sin(t * math.pi * 2);
            final opacity = 0.65 + 0.35 * math.sin(t * math.pi * 2).abs();
            return Transform.scale(
              scale: pulse,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: const Center(child: Text('💤', style: emojiStyle)),
              ),
            );
          }
        },
      ),
    );
  }
}
