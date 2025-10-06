// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import 'commit_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- Lógica original ---
  final Health health = Health();

  bool _isAuthorized = false;
  bool _permissionsGranted = false;
  bool _isLoading = true;

  int _steps = 0;
  int _heartRate = 0;
  double _weight = 0;
  double _sleepHours = 0.0;

  static const int _dailyStepsGoal = 10000;

  // --- NUEVO: control del slider Vitals/Metrics ---
  final PageController _metricsPager = PageController(initialPage: 0); // Vitals primero
  int _pageIndex = 0;
  String get _metricsTitle => _pageIndex == 0 ? 'Health Vitals' : 'Health Metrics';

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }


  @override
  void dispose() {
    _metricsPager.dispose();
    super.dispose();
  }

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
    if (allGranted) _requestAuthorization();
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
    } catch (_) {
      _loadMockData();
    }
  }

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
      final data = await health.getHealthDataFromTypes(
        startTime: weekAgo,
        endTime: now,
        types: types,
      );
      final totalSteps = data
          .where((e) => e.type == HealthDataType.STEPS)
          .fold<int>(0, (sum, e) => sum + ((e.value as NumericHealthValue).numericValue?.toInt() ?? 0));
      final lastHr = data
          .where((e) => e.type == HealthDataType.HEART_RATE)
          .map((e) => (e.value as NumericHealthValue).numericValue?.toInt())
          .whereType<int>()
          .lastOrNull ??
          0;
      final lastW = data
          .where((e) => e.type == HealthDataType.WEIGHT)
          .map((e) => (e.value as NumericHealthValue).numericValue?.toDouble())
          .whereType<double>()
          .lastOrNull ??
          0.0;
      final sleepSecs = data
          .where((e) => e.type == HealthDataType.SLEEP_ASLEEP)
          .map((e) => (e.value as NumericHealthValue).numericValue?.toDouble())
          .whereType<double>()
          .fold(0.0, (a, b) => a + b);

      setState(() {
        _steps = totalSteps;
        _heartRate = lastHr;
        _weight = lastW;
        _sleepHours = sleepSecs / 3600.0;
      });

      if (_steps == 0 && _heartRate == 0 && _weight == 0 && _sleepHours == 0) {
        _loadMockData();
      }
    } catch (_) {
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

  void _openAppSettings() => openAppSettings();

  // --- UI nueva  ---

  @override
  Widget build(BuildContext context) {

    final cs = Theme.of(context).colorScheme;
    const _kCardH = 140.0;
    const _kGap = 12.0;
    final pagerHeight = _kCardH * 2 + _kGap; // altura estable para evitar overflow

    return Scaffold(
      appBar: const HomeHeader(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF22D3A6)))
          : SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                _Breadcrumb(text: 'Lower Back Recovery • Day 23'),
                const Spacer(),
                _Chip(
                  text: '+8% this week',
                  color: cs.primary.withValues(alpha: 0.20),
                  icon: Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _RecoveryCard(percent: 0.84),
            const SizedBox(height: 16),
            const _SectionHeader(title: 'Recovery Optimization'),
            const SizedBox(height: 8),

            // Sleep & Exercise
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.78,
                    child: _InfoTile(
                      title: '${_sleepHours.toStringAsFixed(1)}h',
                      subtitle: 'Sleep',
                      status: _sleepHours >= 7 ? 'Optimal' : 'Low',
                      gradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                      icon: Icons.nightlight_round,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.78,
                    child: _InfoTile(
                      title: '${(_steps / 60).round()}min',
                      subtitle: 'Exercise',
                      status: _steps >= 6000 ? 'Moderate' : 'Light',
                      gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.78,
                    child: const _RecoveryStatusCard(
                      levelText: 'Moderate',
                      title: 'Stress',
                      caption: 'Moderate',
                    ),
                  ),
                ],
              ),
            ),

            // --- Vitals / Health Metrics (slider) ---
            const SizedBox(height: 16),
            Row(
              children: [
                _SectionHeader(title: _metricsTitle),
                const Spacer(),
                _MetricsSegmented(
                  index: _pageIndex,
                  onChanged: (i) {
                    _metricsPager.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                    );
                    setState(() => _pageIndex = i);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Altura fija para evitar overflow en ListView + PageView
            SizedBox(
              height: pagerHeight,
              child: PageView(
                controller: _metricsPager,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                children: [
                  // Página 0: Vitals
                  _GridCards(children: [
                    _MetricRingCard(
                      color: const Color(0xFF8B5CF6),
                      value: (_heartRate.clamp(0, 100)) / 100.0,
                      valueText: _heartRate.toString(),
                      title: 'Heart',
                      subtitle: 'Rate',
                    ),
                    _MetricRingCard(
                      color: const Color(0xFFF59E0B),
                      value: ((_steps / _dailyStepsGoal).clamp(0, 1)).toDouble(),
                      valueText: ((_steps / _dailyStepsGoal) * 100).clamp(0, 100).round().toString(),
                      title: 'Steps',
                      subtitle: _steps.toString(),
                    ),
                    _MetricRingCard(
                      color: const Color(0xFF10B981),
                      value: ((_sleepHours / 8).clamp(0, 1)).toDouble(),
                      valueText: ((_sleepHours / 8) * 100).clamp(0, 100).round().toString(),
                      title: 'Sleep',
                      subtitle: '${_sleepHours.toStringAsFixed(1)} h',
                    ),
                    _MetricRingCard(
                      color: const Color(0xFFEF4444),
                      value: 0.91,
                      valueText: '91',
                      title: 'Weight',
                      subtitle: '${_weight.toStringAsFixed(1)} kg',
                    ),
                  ]),
                  // Página 1: Health Metrics
                  _GridCards(children: [
                    _MetricRingCard(
                      color: const Color(0xFF8B5CF6),
                      value: 0.88,
                      valueText: '88',
                      title: 'Bone',
                      subtitle: 'Density',
                    ),
                    _MetricRingCard(
                      color: const Color(0xFFF59E0B),
                      value: 0.76,
                      valueText: '76',
                      title: 'Muscle',
                      subtitle: 'Strength',
                    ),
                    _MetricRingCard(
                      color: const Color(0xFF10B981),
                      value: 0.82,
                      valueText: '82',
                      title: 'Joint',
                      subtitle: 'Mobility',
                    ),
                    _MetricRingCard(
                      color: const Color(0xFFEF4444),
                      value: 0.91,
                      valueText: '91',
                      title: 'Cardio',
                      subtitle: 'VO2 Max',
                    ),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _PillButtonDark(
                    label: 'Actualizar datos',
                    onPressed: _fetchHealthData,
                  ),
                ),
                const SizedBox(width: 12),
                if (!_isAuthorized)
                  Expanded(
                    child: _PillButtonDark(
                      label: 'Conectar con Google Fit',
                      onPressed: _requestAuthorization,
                      secondary: true,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Banner AI con brillo
            const AiOptimizedSessionCard(),
            const SizedBox(height: 16),
            const TodaysHabitsSection(),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ---------- Widgets ----------
class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Row(
                children: [
                  _LogoDiamond(size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'WellQ',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFF9A825)),
                    SizedBox(width: 6),
                    Text('15-day streak', style: TextStyle(color: cs.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _IconPill(
                icon: Icons.wb_sunny_rounded,
                onTap: () {
                  final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
                  final current = themeModeNotifier.value;
                  final effectiveIsDark = current == ThemeMode.dark ||
                      (current == ThemeMode.system && platformBrightness == Brightness.dark);
                  themeModeNotifier.value = effectiveIsDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
              const SizedBox(width: 10),
              Builder(
                builder: (context) => CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2DA9FF),
                  child: Icon(Icons.person, color: Theme.of(context).colorScheme.surface, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Grid 2x2 sin scroll interno
class _GridCards extends StatelessWidget {
  final List<Widget> children;
  const _GridCards({required this.children});
  @override
  Widget build(BuildContext context) {
    // Padding externo del ListView: 16 a cada lado → 32 en total
    const listHPad = 16.0;
    const gridHPad = 12.0;
    const gap = 12.0;

    // Ancho real de la pantalla menos padding del ListView
    final total = MediaQuery.of(context).size.width - (listHPad * 2);
    // Ancho útil interno del grid: menos su propio padding y el gap entre columnas
    final available = total - (gridHPad * 2) - gap;
    final itemW = available / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: gridHPad, vertical: 12),
      child: Wrap(
        spacing: gap,
        runSpacing: gap,
        children: children.take(4).map((e) => SizedBox(width: itemW, height: 140, child: e)).toList(),
      ),
    );
  }
}

class _MetricRingCard extends StatelessWidget {
  final Color color;
  final double value; // 0..1
  final String valueText;
  final String title;
  final String subtitle;
  const _MetricRingCard({
    required this.color,
    required this.value,
    required this.valueText,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.18)),
                    backgroundColor: Colors.transparent,
                  ),
                  CircularProgressIndicator(
                    value: value.clamp(0, 1),
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    backgroundColor: Colors.transparent,
                  ),
                  Text(valueText, style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconPill({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Icon(icon, size: 18, color: cs.onSurface),
      ),
    );
  }
}

class _LogoDiamond extends StatelessWidget {
  final double size;
  const _LogoDiamond({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.785398, // 45°
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF15C492),
                borderRadius: BorderRadius.circular(size * 0.18),
              ),
            ),
          ),
          const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
        ],
      ),
    );
  }
}


class _Breadcrumb extends StatelessWidget {
  final String text;
  const _Breadcrumb({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.folder_open_rounded, size: 18, color: Color(0xFF9AA4B2)),
        SizedBox(width: 6),
        Text('Lower Back Recovery • Day 23', style: TextStyle(fontSize: 13, color: Color(0xFFC7D0DD))),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const _Chip({required this.text, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ]),
    );
  }
}

class _RecoveryCard extends StatelessWidget {
  final double percent;
  const _RecoveryCard({required this.percent});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clamped = percent.clamp(0.0, 1.0);

    return Card(
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Recovery Optimization',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _Ring(
              value: clamped,
              size: 190,
              thickness: 14,
              trackColor: Theme.of(context).brightness == Brightness.dark
                  ? cs.surfaceContainerHighest
                  : const Color(0xFFE6EDF5),
              progressColor: cs.primary,
              startAngle: -3.14 / 2,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _RecoveryStatusCard extends StatelessWidget {
  final String levelText;
  final String title;
  final String caption;

  const _RecoveryStatusCard({
    required this.levelText,
    required this.title,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withValues(alpha: 0.40),
              cs.primary.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 12,
              child: Icon(
                Icons.security_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Icon(
                Icons.tips_and_updates_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Moderate',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Stress', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('Moderate', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsSegmented extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _MetricsSegmented({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240, // o MediaQuery.of(context).size.width * 0.58
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Vitals')),
          ButtonSegment(value: 1, label: Text('Metrics')),
        ],
        selected: {index},
        onSelectionChanged: (set) => onChanged(set.first),
        style: const ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity(horizontal: -3, vertical: -3),
          minimumSize: WidgetStatePropertyAll(Size(0, 36)), // altura compacta
          padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double value;
  final double size;
  final double thickness;
  final Color trackColor;
  final Color progressColor;
  final double startAngle;

  const _Ring({
    required this.value,
    required this.size,
    required this.thickness,
    required this.trackColor,
    required this.progressColor,
    required this.startAngle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final v = value.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              value: v,
              thickness: thickness,
              trackColor: trackColor,
              progressColor: progressColor,
              startAngle: startAngle,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children:  [
              Text('84%', style: TextStyle(color: cs.onSurface, fontSize: 36, fontWeight: FontWeight.w800, height: 1.0)),
              SizedBox(height: 4),
              Text('Recovery', style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double thickness;
  final Color trackColor;
  final Color progressColor;
  final double startAngle;

  _RingPainter({
    required this.value,
    required this.thickness,
    required this.trackColor,
    required this.progressColor,
    required this.startAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - thickness) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * 3.14159265,
      false,
      trackPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      (2 * 3.14159265) * value,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value ||
          oldDelegate.thickness != thickness ||
          oldDelegate.trackColor != trackColor ||
          oldDelegate.progressColor != progressColor ||
          oldDelegate.startAngle != startAngle;
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final List<Color> gradient;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SizedBox(
          height: 140,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white.withOpacity(0.85)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                    Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
      ],
    );
  }
}

class _PillButtonDark extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool secondary;
  const _PillButtonDark({required this.label, required this.onPressed, this.secondary = false});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: secondary ? Colors.transparent : cs.primary,
        foregroundColor: secondary ? cs.primary : cs.onPrimary,
        side: secondary ? BorderSide(color: cs.primary, width: 1) : BorderSide.none,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
// Banner con brillo animado estilo mock
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});
  final double slidePercent;
  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
class AiOptimizedSessionCard extends StatefulWidget {
  const AiOptimizedSessionCard({super.key});
  @override
  State<AiOptimizedSessionCard> createState() => _AiOptimizedSessionCardState();
}

class _AiOptimizedSessionCardState extends State<AiOptimizedSessionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Gradiente base del panel
    const baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF7C83FF), Color(0xFF8E56C9)],
    );

    // Brillo diagonal animado
    const shine = LinearGradient(
      begin: Alignment(-1.0, -0.2),
      end: Alignment(1.0, 0.2),
      colors: [
        Color(0x00FFFFFF),
        Color(0x33FFFFFF),
        Color(0x66FFFFFF),
        Color(0x33FFFFFF),
        Color(0x00FFFFFF),
      ],
      stops: [0.0, 0.35, 0.5, 0.65, 1.0],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),

      child: Stack(
        children: [
          // Fondo degradado
          Container(
            height: 120,
            decoration: const BoxDecoration(gradient: baseGradient),
          ),
          // “Shimmer” con ShaderMask animando la posición del gradiente
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                //print('Animation value: ${_ctrl.value}'); // debería cambiar de 0→1
                final sweep = -1.5 + 3.0 * _ctrl.value;
                return ShaderMask(
                  blendMode: BlendMode.srcATop, // suma luz, muy visible
                  shaderCallback: (rect) {
                    final dx = rect.width * sweep;
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: const [
                        Colors.transparent,
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 0.55, 1.0],
                    ).createShader(rect.shift(Offset(dx, 0)));
                  },
                    child: Container(color: Colors.white.withValues(alpha: 0.3)),

                );
              },
            ),
          ),
          // Contenido
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icono + textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.9), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'AI-Optimized Session',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mobility focus • 18 min',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Based on your recovery data',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón Start con leve glassmorphism
                _StartButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Start', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

//PARTE DE HABITOS

// Modelo de datos
class HabitData {
  final String title;
  final String duration;
  final HabitStatus status;
  final IconData icon;
  final Color iconColor;

  const HabitData({
    required this.title,
    required this.duration,
    required this.status,
    required this.icon,
    required this.iconColor,
  });
}
enum HabitStatus { completed, pending }

class TodaysHabitsSection extends StatelessWidget {
  const TodaysHabitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Datos de ejemplo
    final habits = [
      HabitData(
        title: 'Morning Stretches',
        duration: '15 minutes',
        status: HabitStatus.completed,
        icon: Icons.self_improvement,
        iconColor: const Color(0xFF22D3A6),
      ),
      HabitData(
        title: 'Physical Therapy',
        duration: '30 minutes',
        status: HabitStatus.pending,
        icon: Icons.medical_services,
        iconColor: const Color(0xFFF59E0B),
      ),
      HabitData(
        title: 'Evening Walk',
        duration: '20 minutes',
        status: HabitStatus.pending,
        icon: Icons.directions_walk,
        iconColor: const Color(0xFFEF4444),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Today\'s Habits'),
        const SizedBox(height: 12),
        ...habits.map((habit) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HabitCard(habit: habit),
        )),
      ],
    );
  }
}

class _HabitCard extends StatelessWidget {
  final HabitData habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCompleted = habit.status == HabitStatus.completed;

    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icono con estado
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF22D3A6).withOpacity(0.15)
                    : habit.iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Color(0xFF22D3A6), size: 20)
                  : Icon(habit.icon, color: habit.iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            // Texto principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${habit.duration} • ${isCompleted ? 'Completed' : 'Pending'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Botón Start (solo si no está completado)
            if (!isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.primary.withOpacity(0.3)),
                ),
                child: Text(
                  'Start',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



//---MODO OSCURO/MODO CLARO

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          themeMode: mode,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          home: const DashboardScreen(),
        );
      },
    );
  }
}

ThemeData buildDarkTheme() {
  const seed = Color(0xFF22D3A6);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
    surface: const Color(0xFF141A22),
  );
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primary.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStatePropertyAll(
        IconThemeData(color: scheme.onSurface),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF131C26),
      selectedColor: scheme.primary,
      labelStyle: TextStyle(color: scheme.onSurface),
      side: const BorderSide(color: Color(0xFF223042)),
      shape: const StadiumBorder(),
    ),
    iconTheme: IconThemeData(color: scheme.onSurface),
    textTheme: const TextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
  );
}

ThemeData buildLightTheme() {
  const seed = Color(0xFF22D3A6);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    surface: Colors.white,
  );
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primary.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.surface,
      selectedColor: scheme.primary,
      labelStyle: TextStyle(color: scheme.onSurface),
      side: BorderSide(color: scheme.outlineVariant),
      shape: const StadiumBorder(),
    ),
    iconTheme: IconThemeData(color: scheme.onSurface),
    textTheme: const TextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
  );
}
//BOTTOM NAVBAR PARA CAMBIAR DE PANTALLA
class _BottomNav extends StatefulWidget {
  const _BottomNav();

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _currentIndex = 0; // Dashboard es índice 0

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

        // Navegación correcta
        switch (index) {
          case 0:
          // Dashboard - no hacer nada, ya estás aquí
            break;
          case 1:
          // Analytics
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
            );
            break;
          case 2:
          // Calendar
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CalendarScreen()),
            );
            break;
          case 3:
          // Commit
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CommitScreen()),
            );
            break;
          case 4:
          // Settings
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
// Utilidad
extension LastOrNull<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
