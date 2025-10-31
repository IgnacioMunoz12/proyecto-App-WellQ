import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import 'commit_screen.dart';
import '../main.dart';
import '../services/database_service.dart';
import '../services/health_data_service.dart';
import '../database/database.dart';
import '../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/native_notify_bridge.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              l10n.settingsTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // Theme Toggle
            Card(
              child: ListTile(
                leading: Icon(Icons.wb_sunny_rounded, color: cs.primary),
                title: Text(l10n.settingsTheme),
                subtitle: Text(l10n.settingsThemeSubtitle),
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (value) {
                    final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
                    final current = themeModeNotifier.value;
                    final effectiveIsDark = current == ThemeMode.dark ||
                        (current == ThemeMode.system && platformBrightness == Brightness.dark);
                    themeModeNotifier.value = effectiveIsDark ? ThemeMode.light : ThemeMode.dark;
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Notifications
            // Notifications
            Card(
              child: ListTile(
                leading: Icon(Icons.notifications, color: cs.primary),
                title: Text(l10n.settingsNotifications),
                subtitle: Text(l10n.settingsNotificationsSubtitle),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationSettingsPage()),
                  );
                },
              ),
            ),


            const SizedBox(height: 12),

            // ✅ NUEVO: Language selector (System / ES / EN)
            ValueListenableBuilder<Locale?>(
              valueListenable: localeNotifier,
              builder: (context, currentLocale, _) {
                final selected = currentLocale?.languageCode ?? 'system';
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.language, color: cs.primary),
                        title: Text(l10n.settingsLanguage),
                        subtitle: Text(
                          switch (selected) {
                            'es' => l10n.settingsLanguageValueEs,
                            'en' => l10n.settingsLanguageValueEn,
                            _    => l10n.settingsLanguageValueSystem,
                          },
                        ),
                      ),
                      const Divider(height: 0),

                      RadioListTile<String>(
                        value: 'system',
                        groupValue: selected,
                        title: Text(l10n.settingsLanguageValueSystem),
                        onChanged: (_) async {
                          await useSystemLanguage();
                          _ok(context);
                        },
                      ),
                      RadioListTile<String>(
                        value: 'es',
                        groupValue: selected,
                        title: Text(l10n.settingsLanguageValueEs),
                        onChanged: (_) async {
                          await setAppLanguage('es');
                          _ok(context);
                        },
                      ),
                      RadioListTile<String>(
                        value: 'en',
                        groupValue: selected,
                        title: Text(l10n.settingsLanguageValueEn),
                        onChanged: (_) async {
                          await setAppLanguage('en');
                          _ok(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            // Developer Tools (solo en desarrollo)
            if (!const bool.fromEnvironment('dart.vm.product')) ...[
              const SizedBox(height: 24),
              Text(
                'Developer Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),

              // Database Viewer
              Card(
                child: ListTile(
                  leading: Icon(Icons.storage, color: cs.primary),
                  title: const Text('Database Viewer'),
                  subtitle: const Text('View and manage local database'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DatabaseService().isInitialized
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DatabaseViewerScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // ✅ NUEVO: Insert Test Health Data
              Card(
                child: ListTile(
                  leading: Icon(Icons.science, color: cs.primary),
                  title: const Text('Insert Test Health Data'),
                  subtitle: const Text('Populate Health Connect with sample data'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final healthService = HealthDataService();

                    // Mostrar loading
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Inserting test data...'),
                          ],
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );

                    try {
                      await healthService.insertTestHealthData();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Test data inserted successfully!'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 8),

              // ✅ NUEVO: Clear Test Data
              Card(
                child: ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Clear Test Data'),
                  subtitle: const Text('Remove all test health data'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Test Data?'),
                        content: const Text(
                          'This will delete all test health data from Health Connect. '
                              'Your habits and other app data will remain safe.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      try {
                        final healthService = HealthDataService();
                        await healthService.clearTestHealthData();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🗑️ Test data cleared'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.save, color: Colors.blue),
                  title: const Text('Force Save Metrics'),
                  subtitle: const Text('Save current health data to database'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final healthService = HealthDataService();
                    await healthService.forceSaveMetrics();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Check logs for details'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const _SettingsBottomNav(),
    );
  }

  void _ok(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.languageUpdated)),
    );
  }
}

class DatabaseViewerScreen extends StatelessWidget {
  const DatabaseViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dbViewer),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: const DatabaseStatusView(),
    );
  }
}

class DatabaseStatusView extends StatefulWidget {
  const DatabaseStatusView({super.key});

  @override
  State<DatabaseStatusView> createState() => _DatabaseStatusViewState();
}

class _DatabaseStatusViewState extends State<DatabaseStatusView> {
  final dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Database Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    dbService.isInitialized ? Icons.check_circle : Icons.error,
                    color: dbService.isInitialized ? Colors.green : Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dbService.isInitialized
                              ? 'Database Initialized'
                              : 'Database Not Initialized',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${dbService.isInitialized ? "Connected" : "Error"}',
                          style: TextStyle(
                            fontSize: 14,
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Tables Summary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Tables List
          Expanded(
            child: ListView(
              children: [
                _buildTableSummaryCard('Doctors', Icons.medical_services, cs,
                        () => dbService.database.getAllDoctors()),
                _buildTableSummaryCard('Patients', Icons.people, cs,
                        () => dbService.database.getAllPatients()),
                _buildTableSummaryCard('Devices', Icons.devices, cs,
                        () => dbService.database.getAllDevices()),
                _buildTableSummaryCard('Habits', Icons.task_alt, cs,
                        () => dbService.database.getTodaysHabits()),
                _buildTableSummaryCard('Habit Completions', Icons.history, cs, // ✅ NUEVA TABLA
                        () => dbService.database.select(dbService.database.habitCompletions).get()),
                _buildTableSummaryCard('Health Metrics', Icons.analytics, cs,
                        () => dbService.database.select(dbService.database.healthMetrics).get()),
                _buildTableSummaryCard('Routines', Icons.fitness_center, cs,
                        () async => []),
                _buildTableSummaryCard('Care Plans', Icons.medical_information, cs,
                        () async => []),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _insertTestData(context),
              icon: const Icon(Icons.data_usage),
              label: const Text('Insert Test Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTableSummaryCard(String tableName, IconData icon, ColorScheme cs, Future<List> Function() getCount) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: cs.primary, size: 24),
        title: Text(
          tableName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: FutureBuilder<List>(
          future: getCount(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Row(
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  ),
                  SizedBox(width: 8),
                  Text('Loading...'),
                ],
              );
            }
            return Text(
              '${snapshot.data?.length ?? 0} records',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            );
          },
        ),
        children: [
          FutureBuilder<List>(
            future: getCount(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No data in this table',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...data.take(5).map((item) => _buildDataItem(item, tableName, cs)),
                    if (data.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'And ${data.length - 5} more...',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(dynamic item, String tableName, ColorScheme cs) {
    switch (tableName) {
      case 'Doctors':
        final doctor = item as Doctor;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (doctor.specialty != null)
                Text(
                  'Specialty: ${doctor.specialty}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              Text(
                'Email: ${doctor.email}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (doctor.phone != null)
                Text(
                  'Phone: ${doctor.phone}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        );

      case 'Patients':
        final patient = item as Patient;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Email: ${patient.email}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (patient.birthDate != null)
                Text(
                  'Age: ${DateTime.now().year - patient.birthDate!.year} years',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              if (patient.gender != null)
                Text(
                  'Gender: ${patient.gender}',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        );

      case 'Habits':
        final habit = item as Habit;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      habit.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: habit.completedToday
                          ? const Color(0xFF22D3A6).withOpacity(0.1)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: habit.completedToday
                            ? const Color(0xFF22D3A6)
                            : cs.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      habit.completedToday ? 'Completed' : 'Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: habit.completedToday
                            ? const Color(0xFF22D3A6)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${habit.durationMinutes} min',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.local_fire_department,
                    size: 14,
                    color: habit.currentStreak > 0
                        ? Colors.orange
                        : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${habit.currentStreak} day streak',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'Habit Completions':
        final completion = item as HabitCompletion;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF22D3A6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF22D3A6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habit ID: ${completion.habitId}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Duration: ${completion.durationCompleted} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Completed: ${_formatDate(completion.completedDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 'Health Metrics':
        final metric = item as HealthMetric;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric.metricType,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Value: ${metric.value.toStringAsFixed(1)} ${metric.unit}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Source: ${metric.source ?? "unknown"}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Time: ${_formatDate(metric.timestamp)}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
          ),
          child: Text(
            'Record: ${item.toString()}',
            style: const TextStyle(fontSize: 12),
          ),
        );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'medical_services':
        return Icons.medical_services;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'spa':
        return Icons.spa;
      default:
        return Icons.task_alt;
    }
  }

  Future<void> _insertTestData(BuildContext context) async {
    try {
      final db = dbService.database;

      await db.insertDoctor(
        DoctorsCompanion.insert(
          name: 'Dr. María González',
          specialty: const drift.Value('Cardiology'),
          email: 'maria.gonzalez@wellq.com',
          phone: const drift.Value('+56987654321'),
        ),
      );

      await db.insertPatient(
        PatientsCompanion.insert(
          name: 'Juan Pérez',
          email: 'juan.perez@email.com',
          birthDate: drift.Value(DateTime(1990, 5, 15)),
          gender: const drift.Value('Male'),
          phone: const drift.Value('+56912345678'),
          doctorId: 1,
        ),
      );

      await db.insertHabit(
        HabitsCompanion.insert(
          title: 'Morning Meditation',
          durationMinutes: 10,
          iconName: 'spa',
          colorHex: '#8B5CF6',
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test data inserted successfully ✅'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SettingsBottomNav extends StatefulWidget {
  const _SettingsBottomNav();

  @override
  State<_SettingsBottomNav> createState() => _SettingsBottomNavState();
}

class _SettingsBottomNavState extends State<_SettingsBottomNav> {
  int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CommitScreen()),
            );
            break;
          case 4:
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

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _enabled = true;
  bool _permissionGranted = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notif_enabled') ?? true;

    final status = await Permission.notification.status;
    setState(() {
      _enabled = enabled;
      _permissionGranted = status.isGranted || status.isLimited;
      _loading = false;
    });
  }

  Future<void> _setEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_enabled', v);
    setState(() => _enabled = v);

    if (v) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final req = await Permission.notification.request();
        setState(() => _permissionGranted = req.isGranted || req.isLimited);
      } else {
        setState(() => _permissionGranted = true);
      }
    }
  }

  Future<void> _testNotification() async {
    if (!_enabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activa las notificaciones para probar.')),
        );
      }
      return;
    }

    final status = await Permission.notification.status;
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permiso denegado. Abre los ajustes del sistema para habilitarlo.'),
            action: SnackBarAction(label: 'Ajustes', onPressed: openAppSettings),
          ),
        );
      }
      return;
    }

    // Canal de alta importancia (por si acaso; en main() ya se llama también)
    await NativeNotifyBridge.ensureHighImportanceChannel(
      id: 'wellq_high_v1',
      name: 'Recordatorios (WellQ)',
      description: 'Recordatorios y hábitos',
    );

    try {
      await NativeNotifyBridge.showTestNow(
        id: 'wellq_high_v1',                 // <-- REQUERIDO
        title: 'WellQ',
        body: '🔔 Notificación de prueba (heads-up)',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enviando notificación de prueba…')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al mostrar: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cs.surface,
            child: SwitchListTile(
              title: const Text('Activar notificaciones'),
              subtitle: Text(
                _permissionGranted
                    ? 'Permiso del sistema: concedido'
                    : 'Permiso del sistema: denegado',
              ),
              value: _enabled,
              onChanged: _setEnabled,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Ajustes del sistema'),
            subtitle: const Text(
                'Abrir configuración de notificaciones del dispositivo'),
            onTap: openAppSettings,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _testNotification,
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text('Probar notificación (5s)'),
          ),
          const SizedBox(height: 12),
          Text(
            'Las notificaciones programadas se mostrarán aunque la app esté cerrada, si el permiso está concedido.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

