import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'commit_screen.dart';
import 'settings_screen.dart';
import '../main.dart';
import '../database/database.dart';
import '../services/database_service.dart';
import '../widgets/injury_selection_screen.dart';

// ======================= ANALYTICS SCREEN =======================
class AnalyticsScreen extends StatefulWidget {  // ← CAMBIAR A StatefulWidget
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? planData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    try {
      final db = DatabaseService().database;
      final data = await db.getTreatmentPlanProgress();

      setState(() {
        planData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading progress: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Show loading while checking data
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If no plan exists, redirect to injury selection
    if (planData == null || !planData!['hasPlan']) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const InjurySelectionScreen(),
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const HomeHeader(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProgressData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Text(
                'Hi, Ricardo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // ⭐ ACTUALIZAR: Usar datos reales del plan
              TrainingProgressCardGreen(
                progress: (planData!['progress'] as num).toDouble(),
                sessionsDone: planData!['completedSessions'] as int,
                sessionsTotal: planData!['totalSessions'] as int,
                injuryName: planData!['injuryName'] as String,
                onRefresh: _loadProgressData,
              ),

              const SizedBox(height: 28),
              const SectionHeader(overline: 'NEXT WORKOUT'),
              const SizedBox(height: 12),

              // ⭐ ACTUALIZAR: Navegar a categoría específica y refrescar al volver
              NextWorkoutTileOrange(
                onTap: () async {
                  final injuryType = planData!['injuryType'] as String;
                  final injuryName = planData!['injuryName'] as String;

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExerciseListScreen(
                        category: injuryType,
                        categoryName: injuryName,
                        treatmentPlanId: planData!['plan'].id,
                      ),
                    ),
                  );

                  // Refresh data after completing workout
                  _loadProgressData();
                },
              ),

              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () async {
                  // Navigate to all treatment categories
                  final plan = planData!['plan']; // ✅ Obtener el plan
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TreatmentCategoriesScreen(
                        treatmentPlanId: plan.id,  // ✅ Pasar el ID del plan
                      ),
                    ),
                  );
                  _loadProgressData();
                },
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('See other workout options'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
              ),

              const SizedBox(height: 12),
              Divider(color: cs.outlineVariant, thickness: 1),
              const SizedBox(height: 12),
              const SectionHeader(overline: 'YOUR ROUTINE'),
              const SizedBox(height: 16),

              // ⭐ ACTUALIZAR: Calcular stats reales
              FutureBuilder<Map<String, dynamic>>(
                future: _getRoutineStats(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final stats = snapshot.data!;
                  return Row(
                    children: [
                      Expanded(
                        child: RoutineStatCardGradient(
                          icon: Icons.local_fire_department_rounded,
                          title: '${stats['consecutiveWeeks']}',
                          subtitle: 'Consecutive\ntraining weeks',
                          gradient: const [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: RoutineStatCardGradient(
                          icon: Icons.trending_down_rounded,
                          title: stats['commitment'],
                          subtitle: 'Training\ncommitment',
                          gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _AnalyticsBottomNav(),
    );
  }

  Future<Map<String, dynamic>> _getRoutineStats() async {
    try {
      final db = DatabaseService().database;
      final plan = await db.getActiveTreatmentPlan();

      if (plan == null) {
        return {
          'consecutiveWeeks': 0,
          'commitment': 'Low',
        };
      }

      final sessions = await db.getWorkoutSessionsByPlan(plan.id);

      // Calculate consecutive weeks
      int consecutiveWeeks = _calculateConsecutiveWeeks(sessions);

      // Calculate commitment level
      String commitment = _calculateCommitment(sessions);

      return {
        'consecutiveWeeks': consecutiveWeeks,
        'commitment': commitment,
      };
    } catch (e) {
      return {
        'consecutiveWeeks': 0,
        'commitment': 'Low',
      };
    }
  }

  int _calculateConsecutiveWeeks(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 0;

    // Sort sessions by date (most recent first)
    sessions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    int consecutiveWeeks = 0;
    DateTime checkWeek = startOfWeek;

    // Check each week going backwards
    for (int i = 0; i < 52; i++) {
      bool hasWorkoutThisWeek = sessions.any((session) {
        return session.completedAt.isAfter(checkWeek) &&
            session.completedAt.isBefore(checkWeek.add(const Duration(days: 7)));
      });

      if (hasWorkoutThisWeek) {
        consecutiveWeeks++;
        checkWeek = checkWeek.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    return consecutiveWeeks;
  }

  String _calculateCommitment(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return 'Low';

    // Count sessions in last 30 days
    DateTime thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    int recentSessions = sessions.where((s) =>
        s.completedAt.isAfter(thirtyDaysAgo)
    ).length;

    // Calculate weekly average
    double weeklyAverage = recentSessions / 4.0;

    if (weeklyAverage >= 3) return 'High';
    if (weeklyAverage >= 2) return 'Medium';
    return 'Low';
  }
}



// ======================= TREATMENT CATEGORIES =======================
class TreatmentCategoriesScreen extends StatelessWidget {
  final int treatmentPlanId;

  const TreatmentCategoriesScreen({
    super.key,
    required this.treatmentPlanId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Categories'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Recovery Program',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Therapeutic exercises for rehabilitation',
              style: TextStyle(
                fontSize: 15,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            WorkoutSplitCard(
              letter: 'A',
              title: 'Ligament Tear',
              subtitle: '7 recovery exercises',
              active: false,
              color: const Color(0xFFF59E0B),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseListScreen(
                      category: 'A',
                      categoryName: 'Ligament Tear',
                      treatmentPlanId: treatmentPlanId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            WorkoutSplitCard(
              letter: 'B',
              title: 'Rotator Cuff Issues',
              subtitle: '7 recovery exercises',
              active: false,
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseListScreen(
                      category: 'B',
                      categoryName: 'Rotator Cuff Issues',
                      treatmentPlanId: treatmentPlanId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            WorkoutSplitCard(
              letter: 'C',
              title: 'Tendinitis',
              subtitle: '7 recovery exercises',
              active: false,
              color: const Color(0xFF14B8A6),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseListScreen(
                      category: 'C',
                      categoryName: 'Tendinitis',
                      treatmentPlanId: treatmentPlanId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= REUSABLE WIDGETS =======================
class SectionHeader extends StatelessWidget {
  final String overline;
  final String? trailing;
  const SectionHeader({super.key, required this.overline, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          overline.toUpperCase(),
          style: TextStyle(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        if (trailing != null)
          Text(trailing!, style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// ⭐ CORRECTED: Added injuryName and onRefresh parameters
class TrainingProgressCardGreen extends StatelessWidget {
  final double progress;
  final int sessionsDone;
  final int sessionsTotal;
  final String injuryName;
  final VoidCallback? onRefresh;

  const TrainingProgressCardGreen({
    super.key,
    required this.progress,
    required this.sessionsDone,
    required this.sessionsTotal,
    required this.injuryName,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14B8A6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRefresh,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My training',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              injuryName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (onRefresh != null)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Sessions: $sessionsDone/$sessionsTotal',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 10,
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ModernChip(
                      icon: Icons.calendar_today_rounded,
                      label: '$sessionsTotal-session plan',
                    ),
                    const _ModernChip(
                      icon: Icons.flag_rounded,
                      label: 'Goal: 3/week',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _ModernChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ModernChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class NextWorkoutTileOrange extends StatelessWidget {
  final VoidCallback onTap;

  const NextWorkoutTileOrange({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Open my workout',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start your recovery session',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoutineStatCardGradient extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const RoutineStatCardGradient({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.95),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutSplitCard extends StatelessWidget {
  final String letter;
  final String title;
  final String subtitle;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const WorkoutSplitCard({
    super.key,
    required this.letter,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? color : cs.outlineVariant.withOpacity(0.5),
          width: active ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: active
                ? color.withOpacity(0.15)
                : cs.shadow.withOpacity(0.04),
            blurRadius: active ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: cs.onSurfaceVariant,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= EXERCISE LIST =======================
class ExerciseListScreen extends StatefulWidget {
  final String category;
  final String categoryName;
  final int treatmentPlanId;

  const ExerciseListScreen({
    super.key,
    required this.category,
    required this.categoryName,
    required this.treatmentPlanId,
  });

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  late List<Map<String, dynamic>> exercises;
  int nextSessionNumber = 1;

  @override
  void initState() {
    super.initState();
    exercises = _getExercisesForCategory(widget.category);
    _loadNextSessionNumber();
  }

  Future<void> _loadNextSessionNumber() async {
    final db = DatabaseService().database;
    final sessionNum = await db.getNextSessionNumber(widget.treatmentPlanId);
    setState(() {
      nextSessionNumber = sessionNum;
    });
  }

  List<Map<String, dynamic>> _getExercisesForCategory(String category) {
    switch (category) {
      case 'A':
        return [
          {
            'name': 'Gentle knee mobilization',
            'description': 'Controlled flexion and extension',
            'duration': '3 sets x 10 reps',
            'completed': false,
            'instructions': [
              'Sit on a chair with your back straight',
              'Slowly bend your knee bringing your heel towards your buttocks',
              'Hold for 2 seconds at maximum flexion',
              'Return to starting position in a controlled manner',
              'Repeat the movement smoothly without forcing'
            ],
            'tips': [
              'Do not force if you feel sharp pain',
              'Breathe naturally throughout the exercise',
              'You can use your hands to assist the movement gently'
            ],
          },
          {
            'name': 'Isometric quadriceps strengthening',
            'description': 'Contraction without movement',
            'duration': '3 sets x 15 seconds',
            'completed': false,
            'instructions': [
              'Sit with your leg extended on a flat surface',
              'Place a rolled towel under your knee',
              'Press down on the towel contracting your quadriceps',
              'Hold the contraction for 15 seconds',
              'Relax and repeat'
            ],
            'tips': [
              'Keep your ankle flexed (toes pointing up)',
              'The knee should remain fully extended',
              'You should feel tension in the front of your thigh'
            ],
          },
          {
            'name': 'Straight leg raise',
            'description': 'Extended leg in supine position',
            'duration': '3 sets x 10 reps',
            'completed': false,
            'instructions': [
              'Lie on your back with one leg bent',
              'Keep the other leg completely straight',
              'Lift the straight leg to the height of the bent knee',
              'Hold for 2 seconds',
              'Lower slowly without touching the floor'
            ],
            'tips': [
              'Keep your ankle flexed throughout',
              'Do not arch your lower back',
              'Start without weight and progress gradually'
            ],
          },
          {
            'name': 'Glute bridge',
            'description': 'Posterior chain strengthening',
            'duration': '3 sets x 12 reps',
            'completed': false,
            'instructions': [
              'Lie on your back with knees bent and feet flat',
              'Keep your arms at your sides',
              'Lift your hips forming a straight line from knees to shoulders',
              'Squeeze your glutes at the top',
              'Lower slowly to starting position'
            ],
            'tips': [
              'Keep your core engaged',
              'Do not hyperextend your lower back',
              'Focus on using your glutes, not your lower back'
            ],
          },
          {
            'name': 'Partial squats with support',
            'description': 'Limited knee flexion',
            'duration': '3 sets x 10 reps',
            'completed': false,
            'instructions': [
              'Stand next to a stable surface for support',
              'Place feet shoulder-width apart',
              'Bend your knees only 30-45 degrees',
              'Keep your weight on your heels',
              'Return to standing position'
            ],
            'tips': [
              'Do not let your knees go past your toes',
              'Keep your back straight',
              'Start with shallow squats and progress gradually'
            ],
          },
          {
            'name': 'Single-leg balance',
            'description': 'Proprioception and stability',
            'duration': '3 sets x 30 seconds',
            'completed': false,
            'instructions': [
              'Stand near a wall or stable surface',
              'Lift one foot slightly off the ground',
              'Maintain balance on the other leg',
              'Keep your knee slightly bent',
              'Hold the position for 30 seconds'
            ],
            'tips': [
              'Focus on a fixed point ahead',
              'Use support if needed initially',
              'Progress to closing your eyes when ready'
            ],
          },
          {
            'name': 'Hamstring stretch',
            'description': 'Posterior flexibility',
            'duration': '3 sets x 20 seconds',
            'completed': false,
            'instructions': [
              'Sit on the floor with one leg extended',
              'Bend the other leg with foot against inner thigh',
              'Reach forward towards your toes',
              'Keep your back straight',
              'Hold the stretch for 20 seconds'
            ],
            'tips': [
              'Do not bounce during the stretch',
              'You should feel tension, not pain',
              'Breathe deeply to enhance the stretch'
            ],
          },
        ];

      case 'B':
        return [
          {
            'name': 'Codman pendulum',
            'description': 'Passive shoulder mobilization',
            'duration': '3 sets x 1 minute',
            'completed': false,
            'instructions': [
              'Lean forward supporting yourself with your healthy arm',
              'Let your affected arm hang loosely',
              'Gently swing your arm in small circles',
              'Perform circles in both directions',
              'Use gravity to assist the movement'
            ],
            'tips': [
              'Relax your shoulder completely',
              'Start with very small movements',
              'Do not force the range of motion'
            ],
          },
          {
            'name': 'External rotation with elastic band',
            'description': 'Rotator strengthening',
            'duration': '3 sets x 15 reps',
            'completed': false,
            'instructions': [
              'Attach elastic band at elbow height',
              'Stand sideways to the anchor point',
              'Keep elbow at 90 degrees against your body',
              'Rotate forearm outward against resistance',
              'Return slowly to starting position'
            ],
            'tips': [
              'Keep your elbow tucked to your side',
              'Move only your forearm, not your whole arm',
              'Use light resistance initially'
            ],
          },
          {
            'name': 'Internal rotation with elastic band',
            'description': 'Internal rotator work',
            'duration': '3 sets x 15 reps',
            'completed': false,
            'instructions': [
              'Attach band at elbow height',
              'Stand with band on outside of working arm',
              'Keep elbow at 90 degrees',
              'Rotate forearm across your body',
              'Control the return movement'
            ],
            'tips': [
              'Maintain elbow position throughout',
              'Focus on controlled movements',
              'Do not allow shoulder to move forward'
            ],
          },
          {
            'name': 'Front raise with light dumbbell',
            'description': 'Anterior deltoid strengthening',
            'duration': '3 sets x 12 reps',
            'completed': false,
            'instructions': [
              'Stand with light dumbbell in hand',
              'Keep arm straight with slight elbow bend',
              'Raise arm forward to shoulder height',
              'Hold briefly at the top',
              'Lower slowly to starting position'
            ],
            'tips': [
              'Start with 1-2 lbs maximum',
              'Do not swing the weight',
              'Stop if you feel pain in the shoulder'
            ],
          },
          {
            'name': 'Scapular abduction',
            'description': 'Supraspinatus work',
            'duration': '3 sets x 12 reps',
            'completed': false,
            'instructions': [
              'Lie on your side with affected arm on top',
              'Hold light weight with arm at side',
              'Lift arm outward to 45 degrees',
              'Hold for 2 seconds',
              'Lower slowly'
            ],
            'tips': [
              'Keep movement controlled and slow',
              'Do not lift past 45 degrees initially',
              'Use very light weight (1-2 lbs)'
            ],
          },
          {
            'name': 'Shoulder press with light dumbbells',
            'description': 'Global strengthening',
            'duration': '3 sets x 10 reps',
            'completed': false,
            'instructions': [
              'Sit with back supported',
              'Hold dumbbells at shoulder height',
              'Press weights overhead until arms are extended',
              'Lower slowly back to shoulder height',
              'Maintain good posture throughout'
            ],
            'tips': [
              'Do not arch your back',
              'Exhale as you press up',
              'Only progress to this when earlier exercises are pain-free'
            ],
          },
          {
            'name': 'Cross-body shoulder stretch',
            'description': 'Flexibility and mobility',
            'duration': '3 sets x 20 seconds',
            'completed': false,
            'instructions': [
              'Stand or sit comfortably',
              'Bring affected arm across your chest',
              'Use other arm to gently pull it closer',
              'Hold stretch for 20 seconds',
              'Release slowly'
            ],
            'tips': [
              'Keep shoulders relaxed',
              'Pull at upper arm, not elbow',
              'Feel stretch in back of shoulder'
            ],
          },
        ];

      case 'C':
        return [
          {
            'name': 'Ice massage',
            'description': 'Local anti-inflammatory',
            'duration': '2x daily x 10 minutes',
            'completed': false,
            'instructions': [
              'Freeze water in a paper cup',
              'Peel back paper to expose ice',
              'Massage affected area in circular motions',
              'Continue for 10 minutes',
              'Apply immediately after activity'
            ],
            'tips': [
              'Move ice continuously to avoid frostbite',
              'Area should feel numb when complete',
              'Best applied within 48 hours of inflammation'
            ],
          },
          {
            'name': 'Eccentric tendon stretch',
            'description': 'Controlled elongation',
            'duration': '3 sets x 15 reps',
            'completed': false,
            'instructions': [
              'Stand on a step with heels hanging off edge',
              'Rise up on toes using both feet',
              'Remove unaffected foot',
              'Slowly lower affected heel below step level',
              'Use both feet to rise again'
            ],
            'tips': [
              'Lower very slowly (3-5 seconds)',
              'This exercise should cause mild discomfort',
              'Critical for tendon healing'
            ],
          },
          {
            'name': 'Gentle concentric strengthening',
            'description': 'Progressive load',
            'duration': '3 sets x 10 reps',
            'completed': false,
            'instructions': [
              'Start with the affected joint in lengthened position',
              'Contract muscle to move joint through range',
              'Use light resistance band or weight',
              'Control the entire movement',
              'Return to starting position'
            ],
            'tips': [
              'Only begin when eccentric exercises are tolerable',
              'Start with minimal resistance',
              'Progress very gradually'
            ],
          },
          {
            'name': 'Joint mobilization',
            'description': 'Full range of motion',
            'duration': '3 sets x 10 reps',
            'completed': false,
            'instructions': [
              'Gently move joint through complete range',
              'Take 3 seconds in each direction',
              'Include all planes of movement',
              'Stop before pain point',
              'Repeat slowly and controlled'
            ],
            'tips': [
              'Perform multiple times daily',
              'Gradually increase range as pain decreases',
              'Can be done in warm water for easier movement'
            ],
          },
          {
            'name': 'Isometric exercises',
            'description': 'Contraction without movement',
            'duration': '3 sets x 10 seconds',
            'completed': false,
            'instructions': [
              'Position joint at neutral/comfortable angle',
              'Contract muscle without moving joint',
              'Hold contraction for 10 seconds',
              'Gradually increase intensity to 70% max',
              'Relax completely between reps'
            ],
            'tips': [
              'Safe to perform even with inflammation',
              'Maintains strength without stressing tendon',
              'Can perform multiple times daily'
            ],
          },
          {
            'name': 'Elastic band strengthening',
            'description': 'Progressive resistance',
            'duration': '3 sets x 12 reps',
            'completed': false,
            'instructions': [
              'Secure elastic band at appropriate height',
              'Grasp band with affected limb',
              'Perform controlled movements against resistance',
              'Focus on full range of motion',
              'Return slowly to starting position'
            ],
            'tips': [
              'Start with lightest band resistance',
              'Quality of movement over quantity',
              'Progress resistance only when pain-free'
            ],
          },
          {
            'name': 'Active stretching',
            'description': 'Flexibility and mobility',
            'duration': '3 sets x 20 seconds',
            'completed': false,
            'instructions': [
              'Warm up area with light activity first',
              'Move joint to end range gently',
              'Hold stretch for 20 seconds',
              'You should feel mild tension',
              'Release slowly'
            ],
            'tips': [
              'Never bounce during stretches',
              'Perform after ice or heat therapy',
              'Essential for preventing re-injury'
            ],
          },
        ];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Category ${widget.category}'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.categoryName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Therapeutic recovery exercises',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ⭐ NEW: Show session number
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Session $nextSessionNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: exercises.length,
              itemBuilder: (_, i) {
                final ex = exercises[i];
                return ExerciseItem(
                  index: i + 1,
                  name: ex['name'],
                  description: ex['description'],
                  duration: ex['duration'],
                  completed: ex['completed'],
                  onChanged: (v) => setState(() => ex['completed'] = v ?? false),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailScreen(
                          name: ex['name'],
                          description: ex['description'],
                          duration: ex['duration'],
                          instructions: List<String>.from(ex['instructions']),
                          tips: List<String>.from(ex['tips']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (_) => const WorkoutCheckInDialog(),
                  );
                  if (result != null && context.mounted) {
                    await _saveWorkoutSession(result);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✓ Session completed and saved'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        backgroundColor: cs.tertiary,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Complete session'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWorkoutSession(Map<String, dynamic> data) async {
    final db = DatabaseService().database;
    await db.insertWorkoutSession(
      treatmentPlanId: widget.treatmentPlanId,
      category: widget.category,
      categoryName: widget.categoryName,
      sessionNumber: nextSessionNumber,
      painLevel: data['pain'].round(),
      stiffness: data['stiffness'].round(),
      notes: data['notes'],
      completedAt: DateTime.now(),
    );
  }
}

class ExerciseItem extends StatelessWidget {
  final int index;
  final String name;
  final String description;
  final String duration;
  final bool completed;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const ExerciseItem({
    super.key,
    required this.index,
    required this.name,
    required this.description,
    required this.duration,
    required this.completed,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: completed
              ? cs.primary.withOpacity(0.3)
              : cs.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: completed
                        ? LinearGradient(
                      colors: [cs.primary, cs.primary.withOpacity(0.7)],
                    )
                        : LinearGradient(
                      colors: [
                        cs.surfaceContainerHighest,
                        cs.surfaceContainer
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: completed ? Colors.white : cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: cs.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.timer_outlined,
                                    size: 14, color: cs.onPrimaryContainer),
                                const SizedBox(width: 4),
                                Text(
                                  duration,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 14, color: cs.tertiary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Tap for instructions',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.tertiary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Checkbox(
                  value: completed,
                  onChanged: onChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= EXERCISE DETAIL =======================
class ExerciseDetailScreen extends StatelessWidget {
  final String name;
  final String description;
  final String duration;
  final List<String> instructions;
  final List<String> tips;

  const ExerciseDetailScreen({
    super.key,
    required this.name,
    required this.description,
    required this.duration,
    required this.instructions,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Instructions'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.95),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          duration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Step-by-step instructions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.6,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.error.withOpacity(0.3), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.warning_amber_rounded,
                            color: cs.error, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Safety tips',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: cs.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...tips.map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: cs.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 14,
                                color: cs.onSurface,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to exercise list'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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

// ======================= CHECK-IN DIALOG =======================
class WorkoutCheckInDialog extends StatefulWidget {
  const WorkoutCheckInDialog({super.key});

  @override
  State<WorkoutCheckInDialog> createState() => _WorkoutCheckInDialogState();
}

class _WorkoutCheckInDialogState extends State<WorkoutCheckInDialog> {
  double pain = 2, stiffness = 5;
  final notes = TextEditingController();

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  String bandLabel(double v, List<String> bands) {
    if (v <= 3) return bands[0];
    if (v <= 6) return bands[1];
    return bands[2];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color colorFor(double v) {
      if (v <= 3) return const Color(0xFF10B981);
      if (v <= 6) return const Color(0xFF3B82F6);
      return const Color(0xFFEF4444);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s check-in',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tell us how you feel after the session.',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              _SliderRow(
                title: 'Pain level',
                value: pain,
                valueLabel:
                '${pain.toInt()}/10 — ${bandLabel(pain, ['Improving', 'Moderate', 'High'])}',
                color: colorFor(pain),
                onChanged: (v) => setState(() => pain = v),
              ),
              const SizedBox(height: 16),
              _SliderRow(
                title: 'Stiffness',
                value: stiffness,
                valueLabel:
                '${stiffness.toInt()}/10 — ${bandLabel(stiffness, ['Flexible', 'Stable', 'Stiff'])}',
                color: colorFor(stiffness),
                onChanged: (v) => setState(() => stiffness = v),
              ),
              const SizedBox(height: 20),
              Text(
                'How do you feel today?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notes,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Any observations?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        final data = {
                          'pain': pain,
                          'stiffness': stiffness,
                          'notes': notes.text,
                        };
                        Navigator.pop(context, data);
                      },
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Send'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String title;
  final double value;
  final String valueLabel;
  final Color color;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.title,
    required this.value,
    required this.valueLabel,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueLabel,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            inactiveTrackColor: color.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 10,
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ======================= BOTTOM NAV =======================
class _AnalyticsBottomNav extends StatefulWidget {
  const _AnalyticsBottomNav();

  @override
  State<_AnalyticsBottomNav> createState() => _AnalyticsBottomNavState();
}

class _AnalyticsBottomNavState extends State<_AnalyticsBottomNav> {
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return NavigationBar(
      height: 70,
      backgroundColor: cs.surface,
      indicatorColor: cs.primaryContainer,
      selectedIndex: _currentIndex,
      elevation: 8,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
            break;
          case 1:
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CalendarScreen()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CommitScreen()),
            );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.favorite_border_rounded),
          selectedIcon: Icon(Icons.favorite_rounded),
          label: 'Health',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics_rounded),
          label: 'Analytics',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_rounded),
          selectedIcon: Icon(Icons.calendar_month_rounded),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.task_alt_outlined),
          selectedIcon: Icon(Icons.task_alt_rounded),
          label: 'Commit',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Settings',
        ),
      ],
    );
  }
}
