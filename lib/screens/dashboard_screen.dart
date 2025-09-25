import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart'; // 👈 importa el themeModeNotifier

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Lógica
  final Health health = Health();
  bool _isAuthorized = false;
  bool _permissionsGranted = false;
  bool _isLoading = true;

  // Datos
  int _steps = 0;
  int _heartRate = 0;
  double _weight = 0;
  double _sleepHours = 0.0;

  // Config “demo”
  static const int _dailyStepsGoal = 10000;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  // --- Permisos y autorización ---

  Future<void> _checkPermissions() async {
    final statuses = await [
      Permission.activityRecognition,
      Permission.sensors,
      Permission.locationWhenInUse,
    ].request();

    final allGranted = statuses.values.every((s) => s.isGranted);
    setState(() {
      _permissionsGranted = allGranted;
      _isLoading = false;
    });

    if (allGranted) {
      _requestAuthorization();
    }
  }

  Future<void> _requestAuthorization() async {
    if (!_permissionsGranted) return;

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.WEIGHT,
      HealthDataType.SLEEP_ASLEEP,
    ];

    try {
      final ok = await health.requestAuthorization(types);
      setState(() => _isAuthorized = ok);
      if (ok) {
        _fetchHealthData();
      } else {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error en autorización: $e');
      _loadMockData();
    }
  }

  // --- Lectura de datos reales o mock ---

  Future<void> _fetchHealthData() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.WEIGHT,
      HealthDataType.SLEEP_ASLEEP,
    ];

    try {
      final healthData = await health.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: types,
      );

      final totalSteps = healthData
          .where((e) => e.type == HealthDataType.STEPS)
          .fold<int>(
          0,
              (sum, e) =>
          sum +
              ((e.value as NumericHealthValue).numericValue?.toInt() ??
                  0));

      final lastHeartRate = healthData
          .where((e) => e.type == HealthDataType.HEART_RATE)
          .map((e) =>
          (e.value as NumericHealthValue).numericValue?.toInt())
          .whereType<int>()
          .lastOrNull ??
          0;

      final lastWeight = healthData
          .where((e) => e.type == HealthDataType.WEIGHT)
          .map((e) =>
          (e.value as NumericHealthValue).numericValue?.toDouble())
          .whereType<double>()
          .lastOrNull ??
          0.0;

      final totalSleepSeconds = healthData
          .where((e) => e.type == HealthDataType.SLEEP_ASLEEP)
          .map(
              (e) => (e.value as NumericHealthValue).numericValue?.toDouble())
          .whereType<double>()
          .fold(0.0, (a, b) => a + b);

      setState(() {
        _steps = totalSteps;
        _heartRate = lastHeartRate;
        _weight = lastWeight;
        _sleepHours = totalSleepSeconds / 3600.0;
      });

      if (_steps == 0 && _heartRate == 0 && _weight == 0 && _sleepHours == 0) {
        _loadMockData();
      }
    } catch (e) {
      debugPrint('Error al obtener datos de salud: $e');
      _loadMockData();
    }
  }

  void _loadMockData() {
    setState(() {
      _steps = 8245;
      _heartRate = 72;
      _weight = 80.5;
      _sleepHours = 7.5;
    });
  }

  void _openAppSettings() {
    openAppSettings();
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: bg.withOpacity(0.98),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        title: const Text(
          'WellQ',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          // Toggle Sol/Luna
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeModeNotifier,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(
                  mode == ThemeMode.dark
                      ? Icons.wb_sunny // sol cuando está oscuro
                      : Icons.nights_stay, // luna cuando está claro
                ),
                tooltip: 'Cambiar tema',
                onPressed: () {
                  final newMode = mode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                  themeModeNotifier.value = newMode;
                },
              );
            },
          ),

          // Ajustes de permisos
          if (!_permissionsGranted)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Abrir configuración',
              onPressed: _openAppSettings,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Subtitle('Your Vitals'),
              const SizedBox(height: 12),
              // Grid estilo Figma
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                children: [
                  _VitalCard(
                    title: 'Heart Rate',
                    value: '$_heartRate bpm',
                    icon: Icons.favorite,
                    gradient: const [
                      Color(0xFFff9a9e),
                      Color(0xFFfad0c4),
                    ],
                  ),
                  _VitalCard(
                    title: 'Steps',
                    value: _steps.toString(),
                    icon: Icons.directions_walk,
                    gradient: const [
                      Color(0xFFa1c4fd),
                      Color(0xFFc2e9fb),
                    ],
                    child: _StepsProgress(
                      steps: _steps,
                      goal: _dailyStepsGoal,
                    ),
                  ),
                  _VitalCard(
                    title: 'Sleep',
                    value: '${_sleepHours.toStringAsFixed(1)} h',
                    icon: Icons.nights_stay,
                    gradient: const [
                      Color(0xFFb3ffab),
                      Color(0xFF12fff7),
                    ],
                  ),
                  _VitalCard(
                    title: 'Weight',
                    value: '${_weight.toStringAsFixed(1)} kg',
                    icon: Icons.monitor_weight,
                    gradient: const [
                      Color(0xFFf6d365),
                      Color(0xFFfda085),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      label: 'Actualizar datos',
                      onPressed: _fetchHealthData,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!_isAuthorized)
                    Expanded(
                      child: _PillButton(
                        label: 'Conectar con Google Fit',
                        onPressed: _requestAuthorization,
                        variant: PillButtonVariant.secondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const _Subtitle('Today’s Activity'),
              const SizedBox(height: 12),
              _ActivityRow(
                items: [
                  ActivityItem(
                    label: 'Walking',
                    value: '45 min',
                    icon: Icons.directions_walk,
                  ),
                  ActivityItem(
                    label: 'Strength',
                    value: '30 min',
                    icon: Icons.fitness_center,
                  ),
                  ActivityItem(
                    label: 'Yoga',
                    value: '20 min',
                    icon: Icons.self_improvement,
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

// --- Widgets auxiliares (los mismos que tenías) ---

class _Subtitle extends StatelessWidget {
  final String text;
  const _Subtitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final Widget? child;

  const _VitalCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            if (child != null) ...[
              const SizedBox(height: 8),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}

class _StepsProgress extends StatelessWidget {
  final int steps;
  final int goal;
  const _StepsProgress({required this.steps, required this.goal});

  @override
  Widget build(BuildContext context) {
    final pct = (steps / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: pct),
        const SizedBox(height: 6),
        Text(
          '${(pct * 100).toStringAsFixed(0)}% of $goal',
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

enum PillButtonVariant { primary, secondary }

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final PillButtonVariant variant;

  const _PillButton({
    required this.label,
    required this.onPressed,
    this.variant = PillButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == PillButtonVariant.primary;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: isPrimary ? const Color(0xFF6750A4) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF6750A4),
        side: isPrimary
            ? BorderSide.none
            : const BorderSide(color: Color(0xFF6750A4), width: 1),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class ActivityItem {
  final String label;
  final String value;
  final IconData icon;
  ActivityItem({required this.label, required this.value, required this.icon});
}

class _ActivityRow extends StatelessWidget {
  final List<ActivityItem> items;
  const _ActivityRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (e) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(e.icon, color: Colors.black87),
                const SizedBox(height: 8),
                Text(
                  e.value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  e.label,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

// Extensión utilitaria
extension LastOrNull<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}



