import 'package:flutter/material.dart';
import '../database/database.dart';
import '../services/database_service.dart';
import '../screens/analytics_screen.dart';
import '../l10n/app_localizations.dart';

class TodaysHabitsSection extends StatefulWidget {
  const TodaysHabitsSection({super.key});

  @override
  State<TodaysHabitsSection> createState() => _TodaysHabitsSectionState();
}

class _TodaysHabitsSectionState extends State<TodaysHabitsSection> {
  late final AppDatabase _database;

  @override
  void initState() {
    super.initState();
    _database = DatabaseService().database;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.todaysHabitsTitle), // "Hábitos de hoy"
        const SizedBox(height: 12),

        StreamBuilder<List<Habit>>(
          stream: _database.watchTodaysHabits(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final habits = snapshot.data!;

            if (habits.isEmpty) {
              return _EmptyHabitsState(cs: cs);
            }

            return Column(
              children: habits.map((habit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HabitCard(
                    habit: habit,
                    onStart: () => _startHabit(habit),
                    onComplete: () => _completeHabit(habit.id),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _startHabit(Habit habit) async {
    // Physical Therapy lleva a Analytics
    if (habit.title.toLowerCase().contains('physical therapy')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
      );
      return;
    }

    // Morning Stretches muestra video
    if (habit.title.toLowerCase().contains('morning stretches') ||
        habit.title.toLowerCase().contains('stretching')) {
      showDialog(
        context: context,
        builder: (context) => _StretchingGuideDialog(
          habit: habit,
          database: _database,
        ),
      );
      return;
    }

    // Meditation muestra temporizador con opción de completar
    if (habit.title.toLowerCase().contains('meditation')) {
      showDialog(
        context: context,
        builder: (context) => _MeditationTimerDialog(
          habit: habit,
          database: _database,
        ),
      );
      return;
    }

    // Otros hábitos usan temporizador normal
    showDialog(
      context: context,
      builder: (context) => _HabitTimerDialog(
        habit: habit,
        database: _database,
      ),
    );
  }

  Future<void> _completeHabit(int habitId) async {
    final habitBefore = await _database.getHabitById(habitId);
    final previousStreak = habitBefore?.currentStreak ?? 0;

    await _database.completeHabitWithStreak(habitId);

    if (mounted) {
      final habitAfter = await _database.getHabitById(habitId);

      if (habitAfter != null) {
        final newStreak = habitAfter.currentStreak;
        final isNewRecord = newStreak > habitAfter.longestStreak - 1;

        final l10n = AppLocalizations.of(context);
        String message;
        if (newStreak == 1) {
          message = l10n.habitSnackStart; // "¡Gran inicio! ¡Comienza tu racha!"
        } else if (isNewRecord) {
          message = l10n.habitSnackNewRecord(newStreak);
        } else if (newStreak >= 7) {
          message = l10n.habitSnackAmazing(newStreak);
        } else {
          message = l10n.habitSnackCompleted(newStreak);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF22D3A6),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// Dialog para estiramientos con guía
class _StretchingGuideDialog extends StatefulWidget {
  final Habit habit;
  final AppDatabase database;

  const _StretchingGuideDialog({
    required this.habit,
    required this.database,
  });

  @override
  State<_StretchingGuideDialog> createState() => _StretchingGuideDialogState();
}

class _StretchingGuideDialogState extends State<_StretchingGuideDialog> {
  int _currentStep = 0;
  late int _remainingSeconds;
  bool _isRunning = false;

  final List<Map<String, dynamic>> _stretchingSteps = [
    {
      'title': 'Neck Stretch',
      'duration': 30,
      'description': 'Slowly tilt your head to each side, holding for 15 seconds',
      'icon': Icons.person,
    },
    {
      'title': 'Shoulder Rolls',
      'duration': 30,
      'description': 'Roll shoulders forward 5 times, then backward 5 times',
      'icon': Icons.accessibility_new,
    },
    {
      'title': 'Arm Circles',
      'duration': 30,
      'description': 'Extend arms and make large circles, 10 forward, 10 backward',
      'icon': Icons.directions_walk,
    },
    {
      'title': 'Torso Twist',
      'duration': 30,
      'description': 'Stand with feet shoulder-width apart, twist gently side to side',
      'icon': Icons.swap_horiz,
    },
    {
      'title': 'Hamstring Stretch',
      'duration': 30,
      'description': 'Sit and reach for your toes, hold for 30 seconds',
      'icon': Icons.airline_seat_legroom_normal,
    },
    {
      'title': 'Calf Stretch',
      'duration': 30,
      'description': 'Step forward, press back heel down, hold 15 seconds each leg',
      'icon': Icons.directions_run,
    },
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _stretchingSteps[0]['duration'];
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _startCountdown();
    }
  }

  Future<void> _startCountdown() async {
    while (_isRunning && _remainingSeconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRunning) {
        setState(() {
          _remainingSeconds--;
        });
      }
    }

    if (_remainingSeconds == 0 && mounted) {
      _nextStep();
    }
  }

  void _nextStep() {
    if (_currentStep < _stretchingSteps.length - 1) {
      setState(() {
        _currentStep++;
        _remainingSeconds = _stretchingSteps[_currentStep]['duration'];
        _isRunning = false;
      });
    } else {
      _completeStretching();
    }
  }

  Future<void> _completeStretching() async {
    await widget.database.completeHabitWithStreak(widget.habit.id);
    if (mounted) Navigator.of(context).pop();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _stretchingSteps[_currentStep];
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
            localizedHabitTitle(context, widget.habit.title),
        style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.stepOfTotal(_currentStep + 1, _stretchingSteps.length),
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF22D3A6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                currentExercise['icon'],
                size: 60,
                color: const Color(0xFF22D3A6),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              currentExercise['title'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              currentExercise['description'],
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: Color(0xFF22D3A6),
              ),
            ),

            const SizedBox(height: 16),

            LinearProgressIndicator(
              value: 1 - (_remainingSeconds / currentExercise['duration']),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22D3A6)),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: cs.outline),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF22D3A6),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isRunning ? l10n.pause : l10n.start),
                  ),
                ),
              ],
            ),

            if (!_isRunning && _remainingSeconds < currentExercise['duration'])
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: _nextStep,
                  child: Text(
                    _currentStep < _stretchingSteps.length - 1
                        ? l10n.skipToNext
                        : l10n.completeNow,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isRunning = false;
    super.dispose();
  }
}

// Dialog para meditación con opción de completar
class _MeditationTimerDialog extends StatefulWidget {
  final Habit habit;
  final AppDatabase database;

  const _MeditationTimerDialog({
    required this.habit,
    required this.database,
  });

  @override
  State<_MeditationTimerDialog> createState() => _MeditationTimerDialogState();
}

class _MeditationTimerDialogState extends State<_MeditationTimerDialog> {
  late int _remainingSeconds;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.habit.durationMinutes * 60;
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _startCountdown();
    }
  }

  Future<void> _startCountdown() async {
    while (_isRunning && _remainingSeconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRunning) {
        setState(() {
          _remainingSeconds--;
        });
      }
    }

    if (_remainingSeconds == 0 && mounted) {
      await widget.database.completeHabitWithStreak(widget.habit.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizedHabitTitle(context, widget.habit.title),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            LinearProgressIndicator(
              value: 1 - (_remainingSeconds / (widget.habit.durationMinutes * 60)),
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22D3A6)),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF22D3A6),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isRunning ? l10n.pause : l10n.start),
                  ),
                ),
              ],
            ),

            if (!_isRunning && _remainingSeconds < widget.habit.durationMinutes * 60)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () async {
                      await widget.database.completeHabitWithStreak(widget.habit.id);
                      if (mounted) Navigator.of(context).pop();
                    },
                    child: Text(l10n.completeEarly),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isRunning = false;
    super.dispose();
  }
}
String localizedHabitTitle(BuildContext context, String raw) {
  final l10n = AppLocalizations.of(context);
  final t = raw.trim().toLowerCase();

  if (t.contains('morning stretches')) return l10n.habitMorningStretches;
  if (t.contains('physical therapy')) return l10n.habitPhysicalTherapy;
  if (t.contains('evening walk')) return l10n.habitEveningWalk;
  if (t.contains('meditation')) return l10n.habitMeditation;

  // Si no es uno de los semilla, deja el texto tal cual viene de BD
  return raw;
}
// Código existente (_HabitCard, _HabitTimerDialog, etc.)
class _HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  const _HabitCard({
    required this.habit,
    this.onStart,
    this.onComplete,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'medical_services':
        return Icons.medical_services;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'spa':
        return Icons.spa;
      default:
        return Icons.task_alt;
    }
  }

  Color _getColor(String hexColor) {
    return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final isCompleted = habit.completedToday;
    final icon = _getIconData(habit.iconName);
    final iconColor = _getColor(habit.colorHex);

    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF22D3A6).withOpacity(0.15)
                    : iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Color(0xFF22D3A6), size: 20)
                  : Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizedHabitTitle(context, habit.title),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.minutes(habit.durationMinutes)} • ${isCompleted ? l10n.habitDone : l10n.habitPending}',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (!isCompleted)
              InkWell(
                onTap: onStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    l10n.start,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HabitTimerDialog extends StatefulWidget {
  final Habit habit;
  final AppDatabase database;

  const _HabitTimerDialog({
    required this.habit,
    required this.database,
  });

  @override
  State<_HabitTimerDialog> createState() => _HabitTimerDialogState();
}

class _HabitTimerDialogState extends State<_HabitTimerDialog> {
  late int _remainingSeconds;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.habit.durationMinutes * 60;
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _startCountdown();
    }
  }

  Future<void> _startCountdown() async {
    while (_isRunning && _remainingSeconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRunning) {
        setState(() {
          _remainingSeconds--;
        });
      }
    }

    if (_remainingSeconds == 0 && mounted) {
      await widget.database.completeHabitWithStreak(widget.habit.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizedHabitTitle(context, widget.habit.title)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(_remainingSeconds),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: 1 - (_remainingSeconds / (widget.habit.durationMinutes * 60)),
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22D3A6)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _toggleTimer,
          child: Text(_isRunning ? l10n.pause : l10n.start),
        ),
        if (!_isRunning && _remainingSeconds < widget.habit.durationMinutes * 60)
          TextButton(
            onPressed: () async {
              await widget.database.completeHabitWithStreak(widget.habit.id);
              if (mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.completeAction),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _isRunning = false;
    super.dispose();
  }
}

class _EmptyHabitsState extends StatelessWidget {
  final ColorScheme cs;

  const _EmptyHabitsState({required this.cs});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 48, color: cs.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            l10n.noHabitsYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.addFirstHabit,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
    );
  }
}

