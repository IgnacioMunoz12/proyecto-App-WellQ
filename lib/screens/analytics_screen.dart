import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'commit_screen.dart';
import 'settings_screen.dart';
// <-- unificado minúsculas
import '../services/database_service.dart';
import '../l10n/app_localizations.dart';

// ======================= ANALYTICS SCREEN =======================
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: const HomeHeader(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.hiUser('Ricardo'), // "Hi, Ricardo"
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            TrainingProgressCardGreen(
              progress: 0.08,
              sessionsDone: 1,
              sessionsTotal: 12,
              overline: l10n.myTrainingOverline,         // "My training"
              progressLabel: l10n.progressLabel,         // "Progress"
              sessionsLabel: l10n.sessionsXofY(1, 12),   // "Sessions: 1/12"
              planChip: l10n.planSessions(12),           // "12-session plan"
              goalChip: l10n.goalPerWeek(3),             // "Goal: 3/week"
            ),

            const SizedBox(height: 16),

            SectionHeader(overline: l10n.nextWorkoutOverline),
            const SizedBox(height: 8),

            NextWorkoutTileOrange(
              title: l10n.openMyWorkout,                              // "Open my workout"
              subtitle: l10n.todayWorkoutSubtitle('6:30 PM', 'A'),    // "Today 6:30 PM • Category A"
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TreatmentCategoriesScreen(),
                  ),
                );
              },
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.seeOtherWorkouts), // "See other workout options"
              ),
            ),

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            SectionHeader(overline: l10n.yourRoutineOverline),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: RoutineStatCardGradient(
                    icon: Icons.fitness_center,
                    title: '1',
                    subtitle: l10n.consecutiveTrainingWeeks, // "Consecutive\ntraining weeks"
                    gradient: const [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RoutineStatCardGradient(
                    icon: Icons.trending_down,
                    title: l10n.statusLow, // Reutilizamos "Low"
                    subtitle: l10n.trainingCommitment, // "Training\ncommitment"
                    gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _AnalyticsBottomNav(),
    );
  }
}

// ======================= TREATMENT CATEGORIES =======================
class TreatmentCategoriesScreen extends StatelessWidget {
  const TreatmentCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.treatmentCategoriesTitle),
        backgroundColor: cs.surface,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.recoveryProgramTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.therapeuticExercisesRehab,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            WorkoutSplitCard(
              letter: 'A',
              title: l10n.injuryLigamentTear,
              subtitle: l10n.recoveryExercisesCount(7),
              active: false,
              color: Colors.amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseListScreen(
                      category: 'A',
                      categoryName: l10n.injuryLigamentTear,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            WorkoutSplitCard(
              letter: 'B',
              title: l10n.injuryRotatorCuff,
              subtitle: l10n.recoveryExercisesCount(7),
              active: false,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseListScreen(
                      category: 'B',
                      categoryName: l10n.injuryRotatorCuff,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            WorkoutSplitCard(
              letter: 'C',
              title: l10n.injuryTendinitis,
              subtitle: l10n.recoveryExercisesCount(7),
              active: false,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ExerciseListScreen(
                      category: 'C',
                      categoryName: l10n.injuryTendinitis,
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
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        if (trailing != null)
          Text(trailing!, style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class TrainingProgressCardGreen extends StatelessWidget {
  final double progress;
  final int sessionsDone;
  final int sessionsTotal;

  // Textos localizados que vienen de arriba
  final String overline;
  final String progressLabel;
  final String sessionsLabel;
  final String planChip;
  final String goalChip;

  const TrainingProgressCardGreen({
    super.key,
    required this.progress,
    required this.sessionsDone,
    required this.sessionsTotal,
    required this.overline,
    required this.progressLabel,
    required this.sessionsLabel,
    required this.planChip,
    required this.goalChip,
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: const [
                Icon(Icons.trending_up, color: Colors.white, size: 16),
                SizedBox(width: 6),
              ],
            ),
            Text(overline,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(progressLabel,
                      style: const TextStyle(color: Colors.white70)),
                ),
                Text(sessionsLabel,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 2),
            Text('${(progress * 100).round()}%',
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF0EA5E9)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.schedule, size: 18),
                  label: Text(planChip),
                  onPressed: () {},
                  backgroundColor: Colors.black.withOpacity(0.28),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                ActionChip(
                  avatar: const Icon(Icons.flag, size: 18),
                  label: Text(goalChip),
                  onPressed: () {},
                  backgroundColor: Colors.black.withOpacity(0.28),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}

class NextWorkoutTileOrange extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;

  const NextWorkoutTileOrange({
    super.key,
    required this.onTap,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: onTap,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.25),
            child: const Icon(Icons.fitness_center, color: Colors.white),
          ),
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.white)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.chevron_right, color: Colors.white),
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onPrimaryContainer.withOpacity(0.9),
                  height: 1.3,
                )),
          ]),
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
    final border =
    active ? BorderSide(color: color, width: 2) : BorderSide.none;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: border,
      ),
      color: active ? color.withOpacity(0.08) : cs.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 24,
              child: Text(
                letter,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ]),
        ),
      ),
    );
  }
}

// ======================= EXERCISE LIST =======================
// ======================= EXERCISE LIST =======================
class ExerciseListScreen extends StatefulWidget {
  final String category;
  final String categoryName;

  const ExerciseListScreen({
    super.key,
    required this.category,
    required this.categoryName,
  });

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  // ✅ 1) Declarar la lista en el estado
  late List<Map<String, dynamic>> exercises;

  @override
  void initState() {
    super.initState();
    // ✅ 2) Cargar ejercicios según la categoría
    exercises = _getExercisesForCategory(widget.category);
  }

  // ✅ 3) Dejar SOLO UNA versión de este método
  List<Map<String, dynamic>> _getExercisesForCategory(String category) {
    switch (category) {
      case 'A': // Desgarro de ligamento (ejemplo)
        return [
          {
            'name': 'Péndulo (Codman)',
            'description': 'Movilidad suave del hombro sin dolor.',
            'duration': '1–2 min',
            'completed': false,
            'instructions': [
              'Inclínate hacia delante con el brazo afectado colgando.',
              'Realiza círculos pequeños sin dolor (30–45 s por sentido).',
              'Mantén el tronco estable; el movimiento es de balanceo.'
            ],
            'tips': [
              'Si aparece dolor punzante, detén el ejercicio.',
              'Comienza con rangos muy cortos.'
            ],
          },
          {
            'name': 'Isométrico de bíceps en pared',
            'description': 'Activación sin mover la articulación.',
            'duration': '3 × 20–30 s',
            'completed': false,
            'instructions': [
              'Codo a 90°, puño contra la pared.',
              'Empuja suave (5/10 de esfuerzo) sin mover el brazo.',
              'Respira normal. Descansa 20 s entre series.'
            ],
            'tips': [
              'Evita encoger el hombro hacia la oreja.',
              'Aumenta tiempo progresivamente.'
            ],
          },
          {
            'name': 'Rotación externa con banda',
            'description': 'Fortalece rotadores externos.',
            'duration': '2–3 × 12–15 rep',
            'completed': false,
            'instructions': [
              'Codo pegado al cuerpo a 90°.',
              'Gira el antebrazo hacia fuera controlado y vuelve lento.'
            ],
            'tips': [
              'No arquees la espalda.',
              'Reduce tensión si molesta.'
            ],
          },
        ];

      case 'B': // Manguito rotador (ejemplo)
        return [
          {
            'name': 'Rotación interna con banda',
            'description': 'Activa subescapular.',
            'duration': '2–3 × 12–15 rep',
            'completed': false,
            'instructions': [
              'Codo a 90° pegado al cuerpo.',
              'Tira la banda hacia el ombligo y regresa controlado.'
            ],
            'tips': [
              'Coloca una toalla entre codo y costillas para mejor técnica.'
            ],
          },
          {
            'name': 'Elevación escapular (depresión y retracción)',
            'description': 'Control de escápulas.',
            'duration': '2–3 × 10–12 rep',
            'completed': false,
            'instructions': [
              'De pie, brazos al lado.',
              'Lleva hombros levemente atrás y abajo, mantén 2 s y suelta.'
            ],
            'tips': [
              'Movimiento corto, lento y sin dolor.'
            ],
          },
          {
            'name': 'Abducción asistida con palo',
            'description': 'Movilidad asistida sin dolor.',
            'duration': '2 × 8–10 rep',
            'completed': false,
            'instructions': [
              'Sujeta un palo con ambas manos al frente.',
              'La mano sana ayuda a elevar el brazo afectado hasta rango cómodo.',
              'Baja lento.'
            ],
            'tips': [
              'No fuerces el final del rango.',
              'Progresión semanal suave.'
            ],
          },
        ];

      case 'C': // Tendinitis (ejemplo)
        return [
          {
            'name': 'Estiramiento de antebrazo (flexores)',
            'description': 'Alivia carga en tendones.',
            'duration': '3 × 20–30 s',
            'completed': false,
            'instructions': [
              'Brazo extendido, palma arriba.',
              'Con la otra mano tira suavemente de los dedos hacia abajo.'
            ],
            'tips': [
              'Debe sentirse tensión, no dolor agudo.'
            ],
          },
          {
            'name': 'Deslizamiento en pared',
            'description': 'Movilidad controlada de hombro.',
            'duration': '2 × 8–10 rep',
            'completed': false,
            'instructions': [
              'Apoya antebrazos en pared y desliza hacia arriba.',
              'Mantén escápulas activas y baja lento.'
            ],
            'tips': [
              'No encoger hombros.',
              'Evita compensar con la espalda.'
            ],
          },
          {
            'name': 'Prono–supinación con mancuerna',
            'description': 'Fortalece rotación de antebrazo.',
            'duration': '2–3 × 10–12 rep',
            'completed': false,
            'instructions': [
              'Codo a 90°, sujeta la mancuerna liviana por el extremo.',
              'Gira palma arriba/abajo controlado.'
            ],
            'tips': [
              'Peso liviano al inicio (0.5–1 kg).',
              'Movimiento lento y sin dolor.'
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.categoryTitle(widget.category)),
        backgroundColor: cs.surface,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.therapeuticRecoveryExercises,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: exercises.length,
              itemBuilder: (_, i) {
                final ex = exercises[i];
                return ExerciseItem(
                  index: i + 1,
                  name: ex['name'],
                  description: ex['description'],
                  duration: ex['duration'],
                  completed: ex['completed'],
                  tapHint: l10n.tapForInstructions,
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
            padding: const EdgeInsets.all(16),
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
                        content: Text(l10n.sessionSaved),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        backgroundColor: cs.tertiary,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check_circle),
                label: Text(l10n.completeSession),
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
      category: widget.category,
      categoryName: widget.categoryName,
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
  final String tapHint;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const ExerciseItem({
    super.key,
    required this.index,
    required this.name,
    required this.description,
    required this.duration,
    required this.completed,
    required this.tapHint,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Número/Avatar
              CircleAvatar(
                backgroundColor:
                completed ? cs.tertiary : cs.surfaceContainerHighest,
                radius: 18,
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: completed ? cs.onTertiary : cs.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Contenido expandible
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Descripción
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Duración
                    Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Hint (sin overflow)
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: cs.tertiary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            tapHint,
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.tertiary,
                              fontStyle: FontStyle.italic,
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

              // Checkbox
              Checkbox(
                value: completed,
                onChanged: onChanged,
              ),
            ],
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exerciseInstructionsTitle),
        backgroundColor: cs.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Instrucciones
            Text(
              l10n.stepByStepInstructions,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            ...instructions.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.primaryContainer,
                      child: Text(
                        '${entry.key + 1}',
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.error.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: cs.error, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        l10n.safetyTips,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: cs.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...tips.map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, color: cs.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 14,
                                color: cs.onSurface,
                                height: 1.4,
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

            // Botón back
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: Text(l10n.backToExerciseList),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
    final l10n = AppLocalizations.of(context);

    Color colorFor(double v) {
      if (v <= 3) return cs.tertiary;
      if (v <= 6) return cs.primary;
      return cs.error;
    }

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.todaysCheckInTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.checkInSubtitle,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              _SliderRow(
                title: l10n.painLevel,
                value: pain,
                valueLabel:
                '${pain.toInt()}/10 — ${bandLabel(pain, [l10n.statusImproving, l10n.statusModerate, l10n.statusHigh])}',
                color: colorFor(pain),
                onChanged: (v) => setState(() => pain = v),
              ),
              const SizedBox(height: 12),
              _SliderRow(
                title: l10n.stiffness,
                value: stiffness,
                valueLabel:
                '${stiffness.toInt()}/10 — ${bandLabel(stiffness, [l10n.statusFlexible, l10n.statusStable, l10n.statusStiff])}',
                color: colorFor(stiffness),
                onChanged: (v) => setState(() => stiffness = v),
              ),

              const SizedBox(height: 16),
              Text(
                l10n.howDoYouFeelToday,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notes,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: l10n.anyObservationsHint,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: Text(l10n.cancel),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      final data = {
                        'pain': pain,
                        'stiffness': stiffness,
                        'notes': notes.text,
                      };
                      Navigator.pop(context, data);
                    },
                    icon: const Icon(Icons.send),
                    label: Text(l10n.send),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(valueLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ]),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: color,
          thumbColor: color,
          overlayColor: color.withOpacity(0.2),
          trackHeight: 6,
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
    ]);
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
    final l10n = AppLocalizations.of(context);

    return NavigationBar(
      height: 64,
      backgroundColor: cs.surface,
      indicatorColor: cs.primary.withOpacity(0.14),
      selectedIndex: _currentIndex,
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
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.favorite_border_rounded),
          selectedIcon: const Icon(Icons.favorite_rounded),
          label: l10n.navHealth,
        ),
        NavigationDestination(
          icon: const Icon(Icons.insert_chart_outlined_rounded),
          selectedIcon: const Icon(Icons.insert_chart_rounded),
          label: l10n.navAnalytics,
        ),
        NavigationDestination(
          icon: const Icon(Icons.event_note_rounded),
          selectedIcon: const Icon(Icons.event_note),
          label: l10n.navCalendar,
        ),
        NavigationDestination(
          icon: const Icon(Icons.task_alt_outlined),
          selectedIcon: const Icon(Icons.task_alt),
          label: l10n.navCommit,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: l10n.navSettings,
        ),
      ],
    );
  }
}

