import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';

class CommitScreen extends StatefulWidget {
  const CommitScreen({Key? key}) : super(key: key);

  @override
  State<CommitScreen> createState() => _CommitScreenState();
}

class _CommitScreenState extends State<CommitScreen> {
  // Lista de compromisos con progreso
  final List<Map<String, dynamic>> _commitments = [
    {
      'title': 'Drink 8 glasses of water',
      'current': 6,
      'target': 8,
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'unit': 'glasses',
    },
    {
      'title': 'Walk 10,000 steps',
      'current': 8245,
      'target': 10000,
      'icon': Icons.directions_walk,
      'color': Colors.green,
      'unit': 'steps',
    },
    {
      'title': 'Sleep 8 hours',
      'current': 7.5,
      'target': 8.0,
      'icon': Icons.nightlight_round,
      'color': Colors.purple,
      'unit': 'hours',
    },
    {
      'title': 'Eat 5 fruits/vegetables',
      'current': 3,
      'target': 5,
      'icon': Icons.local_dining,
      'color': Colors.orange,
      'unit': 'servings',
    },
    {
      'title': 'Take vitamins',
      'current': 0,
      'target': 1,
      'icon': Icons.medical_services,
      'color': Colors.red,
      'unit': 'pills',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Commitments'),
        backgroundColor: cs.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCommitmentDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estadísticas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
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
                            'Today\'s Progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: cs.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_getCompletedCount()}/${_commitments.length} commitments completed',
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onPrimary.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircularProgressIndicator(
                      value: _getOverallProgress(),
                      backgroundColor: cs.onPrimary.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimary),
                      strokeWidth: 6,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Lista de compromisos
              Expanded(
                child: ListView.builder(
                  itemCount: _commitments.length,
                  itemBuilder: (context, index) {
                    final commitment = _commitments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCommitmentCard(commitment, index),
                    );
                  },
                ),
              ),

              // Botón para añadir nuevo compromiso
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showAddCommitmentDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Commitment'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _CommitBottomNav(),
    );
  }

  Widget _buildCommitmentCard(Map<String, dynamic> commitment, int index) {
    final cs = Theme.of(context).colorScheme;
    final progress = (commitment['current'] / commitment['target']).clamp(0.0, 1.0);
    final isCompleted = progress >= 1.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEditCommitmentDialog(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: commitment['color'].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      commitment['icon'],
                      color: commitment['color'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commitment['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${commitment['current']}/${commitment['target']} ${commitment['unit']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: commitment['color'],
                        ),
                      ),
                      if (isCompleted)
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: commitment['color'].withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(commitment['color']),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCompletedCount() {
    return _commitments.where((c) => (c['current'] / c['target']) >= 1.0).length;
  }

  double _getOverallProgress() {
    if (_commitments.isEmpty) return 0.0;
    return _getCompletedCount() / _commitments.length;
  }

  void _showAddCommitmentDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Commitment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Commitment Title',
                  hintText: 'e.g., Exercise for 30 minutes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target',
                  hintText: 'e.g., 30',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && targetController.text.isNotEmpty) {
                  setState(() {
                    _commitments.add({
                      'title': titleController.text,
                      'current': 0,
                      'target': int.tryParse(targetController.text) ?? 1,
                      'icon': Icons.star,
                      'color': Colors.blue,
                      'unit': 'units',
                    });
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Commitment added successfully!')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCommitmentDialog(int index) {
    final commitment = _commitments[index];
    final currentController = TextEditingController(
      text: commitment['current'].toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update: ${commitment['title']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Current Progress',
                  hintText: 'Enter current value',
                  suffixText: commitment['unit'],
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Target: ${commitment['target']} ${commitment['unit']}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newValue = double.tryParse(currentController.text);
                if (newValue != null) {
                  setState(() {
                    _commitments[index]['current'] = newValue;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progress updated!')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

// BottomNav específico para Commit
class _CommitBottomNav extends StatefulWidget {
  const _CommitBottomNav();

  @override
  State<_CommitBottomNav> createState() => _CommitBottomNavState();
}

class _CommitBottomNavState extends State<_CommitBottomNav> {
  int _currentIndex = 3; // Commit es índice 3

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
            break;
          case 3:
          // Commit - ya estás aquí
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
