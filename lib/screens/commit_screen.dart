import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import '../services/database_service.dart';
import '../services/health_data_service.dart';
import '../l10n/app_localizations.dart';

class CommitScreen extends StatefulWidget {
  const CommitScreen({super.key});

  @override
  State<CommitScreen> createState() => _CommitScreenState();
}

class _CommitScreenState extends State<CommitScreen> {
  final healthService = HealthDataService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (healthService.needsRefresh() || !healthService.hasPermissions) {
      await healthService.initialize();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // Loading state
    if (healthService.isLoading) {
      return Scaffold(
        appBar: const HomeHeader(),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF22D3A6)),
        ),
      );
    }

    // Permisos no otorgados
    if (!healthService.hasPermissions) {
      return Scaffold(
        appBar: const HomeHeader(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.health_and_safety_rounded, size: 80, color: cs.primary),
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.healthPermsTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.healthPermsBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant, height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await healthService.requestPermissions();
                      if (healthService.hasPermissions) {
                        await healthService.fetchAllHealthData();
                      }
                      if (mounted) setState(() {});
                    },
                    icon: const Icon(Icons.security),
                    label: Text(l10n.grantPermissions),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22D3A6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  child: Text(l10n.goToDashboard),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Datos listos
    final commitments = _getCommitmentsFromHealthData(l10n);

    return Scaffold(
      appBar: const HomeHeader(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await healthService.fetchAllHealthData();
            if (mounted) setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Indicador de mock (solo desarrollo)
              if (healthService.usingMockData && !const bool.fromEnvironment('dart.vm.product'))
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.usingMockData,
                          style: TextStyle(fontSize: 13, color: cs.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),

              // StreakCard
              const _StreakCard(),

              const SizedBox(height: 24),

              Text(
                l10n.dailyCommitmentsTitle,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),

              const SizedBox(height: 16),

              // Progress Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.todaysProgress,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.commitmentsCompleted(
                              _getCompletedCount(commitments),
                              commitments.length,
                            ),
                            style: TextStyle(fontSize: 14, color: cs.onPrimary.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressIndicator(
                      value: _getOverallProgress(commitments),
                      backgroundColor: cs.onPrimary.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                      strokeWidth: 6,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Lista de commitments
              ...commitments.map((commitment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCommitmentCard(commitment),
              )),

              const SizedBox(height: 16),

              // Botón de refresh
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await healthService.fetchAllHealthData();
                    if (mounted) setState(() {});
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.refreshData),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    side: BorderSide(color: cs.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _CommitBottomNav(),
    );
  }

  List<Map<String, dynamic>> _getCommitmentsFromHealthData(AppLocalizations l10n) {
    return [
      {
        'title': l10n.commitWalkSteps(HealthDataService.stepsGoal),
        'current': healthService.steps,
        'target': HealthDataService.stepsGoal,
        'icon': Icons.directions_walk,
        'color': const Color(0xFF22D3A6),
        'unit': l10n.unitSteps,
      },
      {
        'title': l10n.commitDrinkWater(HealthDataService.waterGoal.round()),
        'current': healthService.waterIntake,
        'target': HealthDataService.waterGoal,
        'icon': Icons.water_drop,
        'color': const Color(0xFF3B82F6),
        'unit': l10n.unitLitersShort,
      },
      {
        'title': l10n.commitSleepHours(HealthDataService.sleepGoal.round()),
        'current': healthService.sleepHours,
        'target': HealthDataService.sleepGoal.toDouble(),
        'icon': Icons.nightlight_round,
        'color': const Color(0xFF8B5CF6),
        'unit': l10n.unitHours,
      },
      {
        'title': l10n.commitConsumeCalories(HealthDataService.caloriesGoal),
        'current': healthService.caloriesIntake,
        'target': HealthDataService.caloriesGoal.toDouble(),
        'icon': Icons.local_dining,
        'color': const Color(0xFFF59E0B),
        'unit': l10n.unitKcal,
      },
    ];
  }

  Widget _buildCommitmentCard(Map<String, dynamic> commitment) {
    final cs = Theme.of(context).colorScheme;
    final current = (commitment['current'] as num).toDouble();
    final target = (commitment['target'] as num).toDouble();
    final progress = (current / target).clamp(0.0, 1.0);
    final isCompleted = progress >= 1.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: commitment['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(commitment['icon'], color: commitment['color'], size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    commitment['title'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${current.toStringAsFixed(current < 10 ? 1 : 0)}/${target.toStringAsFixed(0)} ${commitment['unit']}',
                    style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                  ),
                ]),
              ),
              Column(
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: commitment['color']),
                  ),
                  if (isCompleted) const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: commitment['color'].withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(commitment['color']),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ]),
      ),
    );
  }

  int _getCompletedCount(List<Map<String, dynamic>> commitments) {
    return commitments.where((c) {
      final current = (c['current'] as num).toDouble();
      final target = (c['target'] as num).toDouble();
      return (current / target) >= 1.0;
    }).length;
  }

  double _getOverallProgress(List<Map<String, dynamic>> commitments) {
    if (commitments.isEmpty) return 0.0;
    return _getCompletedCount(commitments) / commitments.length;
  }
}

// StreakCard
class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<Map<String, int>>(
      future: DatabaseService().database.getGlobalStreak(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final currentStreak = snapshot.data!['current'] ?? 0;
        final longestStreak = snapshot.data!['longest'] ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEC4899), Color(0xFFA855F7)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                '$currentStreak',
                style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, height: 1),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.dayStreak,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.95)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  l10n.longestStreak(longestStreak),
                  style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// BottomNav
class _CommitBottomNav extends StatefulWidget {
  const _CommitBottomNav();

  @override
  State<_CommitBottomNav> createState() => _CommitBottomNavState();
}

class _CommitBottomNavState extends State<_CommitBottomNav> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return NavigationBar(
      height: 64,
      backgroundColor: cs.surface,
      indicatorColor: cs.primary.withOpacity(0.14),
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
        setState(() => _currentIndex = index);

        switch (index) {
          case 0:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
            break;
          case 1:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnalyticsScreen()));
            break;
          case 2:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CalendarScreen()));
            break;
          case 3:
            break;
          case 4:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
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

