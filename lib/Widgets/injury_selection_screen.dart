// injury_selection_screen.dart
import 'package:flutter/material.dart';
import '../widgets/user_profile_setup_screen.dart';

class InjurySelectionScreen extends StatefulWidget {
  const InjurySelectionScreen({super.key});

  @override
  State<InjurySelectionScreen> createState() => _InjurySelectionScreenState();
}

class _InjurySelectionScreenState extends State<InjurySelectionScreen> {
  String? selectedInjury;


  final List<Map<String, dynamic>> injuries = [
    {
      'type': 'A',
      'name': 'Ligament Tear',
      'description': 'Recovery exercises for knee ligament injuries',
      'color': const Color(0xFFF59E0B),
      'icon': Icons.sports_kabaddi_rounded,
      'exercises': 7,
      'duration': '8-12 weeks',
    },
    {
      'type': 'B',
      'name': 'Rotator Cuff Issues',
      'description': 'Rehabilitation for shoulder rotator cuff problems',
      'color': const Color(0xFF3B82F6),
      'icon': Icons.accessibility_new_rounded,
      'exercises': 7,
      'duration': '6-10 weeks',
    },
    {
      'type': 'C',
      'name': 'Tendinitis',
      'description': 'Treatment protocol for tendon inflammation',
      'color': const Color(0xFF14B8A6),
      'icon': Icons.healing_rounded,
      'exercises': 7,
      'duration': '4-8 weeks',
    },
  ];

  void _startTreatmentPlan() {  // ✅ Ya no es async
    if (selectedInjury == null) return;

    final injury = injuries.firstWhere((i) => i['type'] == selectedInjury);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfileSetupScreen(
          injuryType: injury['type'],
          injuryName: injury['name'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome to WellQ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Let\'s start your recovery journey',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Select your injury type',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We\'ll create a personalized 12-session recovery plan for you',
                      style: TextStyle(
                        fontSize: 15,
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Injury cards
                    ...injuries.map((injury) {
                      final isSelected = selectedInjury == injury['type'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InjuryCard(
                          injury: injury,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              selectedInjury = injury['type'];
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: selectedInjury == null ? null : _startTreatmentPlan,  // ✅ Simplificado
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text(
                      'Start my recovery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
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
class InjuryCard extends StatelessWidget {
  final Map<String, dynamic> injury;
  final bool isSelected;
  final VoidCallback onTap;

  const InjuryCard({
    super.key,
    required this.injury,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = injury['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? color : cs.outlineVariant.withOpacity(0.5),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? color.withOpacity(0.2)
                : cs.shadow.withOpacity(0.05),
            blurRadius: isSelected ? 16 : 8,
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
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
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    injury['icon'],
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        injury['name'],
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        injury['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.fitness_center_rounded,
                            label: '${injury['exercises']} exercises',
                            color: color,
                          ),
                          _InfoChip(
                            icon: Icons.schedule_rounded,
                            label: injury['duration'],
                            color: color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Checkbox
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? color : cs.outlineVariant,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
