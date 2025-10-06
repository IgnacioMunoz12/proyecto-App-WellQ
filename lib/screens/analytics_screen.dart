import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'commit_screen.dart';
import 'settings_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Analytics',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildAnalyticsCard(context, 'Weekly Report', Icons.bar_chart),
                    _buildAnalyticsCard(context, 'Trends', Icons.trending_up),
                    _buildAnalyticsCard(context, 'Goals Progress', Icons.track_changes),
                    _buildAnalyticsCard(context, 'Insights', Icons.lightbulb_outline),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _AnalyticsBottomNav(),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context, String title, IconData icon) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: cs.primary),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// BottomNav específico para Analytics
class _AnalyticsBottomNav extends StatefulWidget {
  const _AnalyticsBottomNav();

  @override
  State<_AnalyticsBottomNav> createState() => _AnalyticsBottomNavState();
}

class _AnalyticsBottomNavState extends State<_AnalyticsBottomNav> {
  int _currentIndex = 1; // Analytics es índice 1

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return NavigationBar(
      height: 64,
      backgroundColor: cs.surface,
      indicatorColor: cs.primary.withValues(alpha: 0.14),
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _currentIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
            break;
          case 1:
          // Analytics - ya estás aquí
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CommitScreen()),
            );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
          icon: Icon(Icons.insert_chart_outlined_rounded),
          selectedIcon: Icon(Icons.insert_chart_rounded),
          label: 'Analytics',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_note_rounded),
          selectedIcon: Icon(Icons.event_note),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(Icons.task_alt_outlined),
          selectedIcon: Icon(Icons.task_alt),
          label: 'Commit',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
