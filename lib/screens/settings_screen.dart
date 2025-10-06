import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import 'commit_screen.dart';
import '../main.dart';
import '../services/database_service.dart';
import '../database/database.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: Icon(Icons.wb_sunny_rounded, color: cs.primary),
                title: const Text('Theme'),
                subtitle: const Text('Light/Dark mode'),
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
            Card(
              child: ListTile(
                leading: Icon(Icons.notifications, color: cs.primary),
                title: const Text('Notifications'),
                subtitle: const Text('Configure alerts'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
            ),

            // (solo en desarrollo)
            if (!const bool.fromEnvironment('dart.vm.product')) ...[
              const SizedBox(height: 24),
              Text(
                'Developer Tools',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(Icons.storage, color: cs.primary),
                  title: const Text('Database Viewer'),
                  subtitle: const Text('View and manage local database'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Estado de la DB
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
            ],
          ],
        ),
      ),
      bottomNavigationBar: const _SettingsBottomNav(),
    );
  }
}

class DatabaseViewerScreen extends StatelessWidget {
  const DatabaseViewerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer'),
        backgroundColor: cs.surface,
        elevation: 0,
      ),
      body: const DatabaseStatusView(),
    );
  }
}

class DatabaseStatusView extends StatefulWidget {
  const DatabaseStatusView({Key? key}) : super(key: key);

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
          // Estado de la DB
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
                              ? 'Base de datos inicializada'
                              : 'Base de datos no inicializada',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estado: ${dbService.isInitialized ? "Conectada" : "Error"}',
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

          // Título de tablas
          Text(
            'Resumen de Tablas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Lista de tablas
          Expanded(
            child: ListView(
              children: [
                _buildTableSummaryCard('Médicos', Icons.medical_services, cs,
                        () => dbService.database.getAllMedicos()),
                _buildTableSummaryCard('Pacientes', Icons.people, cs,
                        () => dbService.database.getAllPacientes()),
                _buildTableSummaryCard('Dispositivos', Icons.devices, cs,
                        () async => []),
                _buildTableSummaryCard('Consentimientos', Icons.assignment, cs,
                        () async => []),
                _buildTableSummaryCard('Rutinas', Icons.fitness_center, cs,
                        () async => []),
                _buildTableSummaryCard('Planes de Cuidado', Icons.medical_information, cs,
                        () async => []),
                _buildTableSummaryCard('Métricas de Salud', Icons.analytics, cs,
                        () async => []),
              ],
            ),
          ),

          // Botón para insertar datos de prueba
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _insertTestData(context),
              icon: const Icon(Icons.data_usage),
              label: const Text('Insertar Datos de Prueba'),
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
                  Text('Cargando...'),
                ],
              );
            }
            return Text(
              '${snapshot.data?.length ?? 0} registros',
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
                    'No hay datos en esta tabla',
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
                          'Y ${data.length - 5} más...',
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
      case 'Médicos':
        final medico = item as Medico;
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
                '${medico.nombres} ${medico.apellidos}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'RUT: ${medico.rut}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Email: ${medico.email}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tel: ${medico.telefono}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: medico.estado == 'activo'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      medico.estado.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: medico.estado == 'activo' ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'Pacientes':
        final paciente = item as Paciente;
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
                '${paciente.nombres} ${paciente.apellidos}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'RUT: ${paciente.rut}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Email: ${paciente.email}',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Edad: ${DateTime.now().year - paciente.fechaNacimiento.year} años',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Sexo: ${paciente.sexo}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Altura: ${paciente.alturaCm.toInt()}cm',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Peso: ${paciente.pesoKg.toInt()}kg',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
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
            'ID: ${item.toString()}',
            style: const TextStyle(fontSize: 12),
          ),
        );
    }
  }

  Future<void> _insertTestData(BuildContext context) async {
    try {
      final db = dbService.database;

      // Insertar médico de prueba
      await db.insertMedico(
        MedicosCompanion.insert(
          nombres: 'Dr. María',
          apellidos: 'González',
          rut: '${DateTime.now().millisecondsSinceEpoch}-9',
          email: 'maria.gonzalez@wellq.com',
          telefono: '+56987654321',
          especialidades: '["cardiología", "medicina general"]',
        ),
      );

      // Insertar paciente de prueba
      await db.insertPaciente(
        PacientesCompanion.insert(
          nombres: 'Juan',
          apellidos: 'Pérez',
          rut: '${DateTime.now().millisecondsSinceEpoch}-1',
          direccion: 'Av. Principal 123',
          telefono: '+56912345678',
          email: 'juan.perez@email.com',
          fechaNacimiento: DateTime(1990, 5, 15),
          sexo: 'M',
          alturaCm: 175.0,
          pesoKg: 75.0,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos de prueba insertados correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refrescar los contadores
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
  int _currentIndex = 4; // Settings es índice 4

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CommitScreen()),
            );
            break;
          case 4:

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
