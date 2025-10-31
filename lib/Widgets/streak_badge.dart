import 'package:flutter/material.dart';
import '../database/database.dart';
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';

class StreakBadge extends StatefulWidget {
  const StreakBadge({super.key});

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  int _previousStreak = 0;

  @override
  void initState() {
    super.initState();

    // Animación de escala (bounce)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    // Animación de pulso para el ícono de fuego
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateStreak(int newStreak) {
    // Solo animar si aumentó el streak
    if (newStreak > _previousStreak && newStreak > 0) {
      _controller.forward().then((_) => _controller.reverse());
    }
    _previousStreak = newStreak;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<List<Habit>>(
      stream: DatabaseService().database.watchTodaysHabits(),
      builder: (context, snapshot) {
        return FutureBuilder<Map<String, int>>(
          future: DatabaseService().database.getGlobalStreak(),
          builder: (context, streakSnapshot) {
            final currentStreak = streakSnapshot.data?['current'] ?? 0;

            // Animar cuando cambia el streak
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _animateStreak(currentStreak);
            });

            return ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: currentStreak > 0
                      ? (isDark
                      ? const Color(0xFFF9A825).withOpacity(0.15)
                      : const Color(0xFFFFF9E6))
                      : cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentStreak > 0
                        ? const Color(0xFFF9A825).withOpacity(0.3)
                        : cs.outlineVariant,
                  ),
                  boxShadow: currentStreak > 0
                      ? [
                    BoxShadow(
                      color: const Color(0xFFF9A825).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícono de fuego animado
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: currentStreak > 0
                            ? const Color(0xFFF9A825)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Texto del streak
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        currentStreak == 0
                            ? l10n.startStreak
                            : l10n.streakActiveDays(currentStreak), // "Racha: {days} días"
                        key: ValueKey<int>(currentStreak),
                        style: TextStyle(
                          color: currentStreak > 0
                              ? const Color(0xFFF9A825)
                              : cs.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

