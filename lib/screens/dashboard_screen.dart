import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/streak_badge.dart';
import '../services/health_data_service.dart';
import '../services/database_service.dart';
import '../services/streak_initializer.dart';
import '../services/recovery_tips_service.dart';
import 'analytics_screen.dart';
import '../Widgets/todays_habits_section.dart';
import '../widgets/recovery_tips_modal.dart';
import 'calendar_screen.dart';
import 'commit_screen.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  final healthService = HealthDataService();

  // inicializador de estado diario/rachas
  late final StreakInitializer _streakInit;

  // Control del slider Vitals/Metrics
  final PageController _metricsPager = PageController(initialPage: 0);
  int _pageIndex = 0;

  VoidCallback? _svcListener;

  String _metricsTitle(AppLocalizations l10n) =>
      _pageIndex == 0 ? l10n.healthVitals : l10n.healthMetrics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _streakInit = StreakInitializer(DatabaseService().database);

    // Escucha cambios del servicio para refrescar UI automáticamente
    _svcListener = () {
      if (mounted) setState(() {});
    };
    healthService.addListener(_svcListener!);

    _initializeData();
  }

  Future<void> _initializeData() async {
    // Normalizar estado diario ANTES de cargar datos del dashboard
    await _streakInit.normalizeTodayOnDashboardOpen();

    // Inicializar el servicio (pide permisos, carga datos, etc.)
    await healthService.initialize();

    // HR (24h: actual/min/max/reposo)
    await healthService.fetchHeartRate();

    // Asegura polling automático de HR (lectura + escritura cada tick)
    healthService.startHeartRatePolling(
      interval: const Duration(seconds: 15),
      writeEachTick: true,
    );

    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reanuda/pausa el monitoreo para ahorrar batería
    if (state == AppLifecycleState.resumed) {
      _normalizeForToday();
      healthService.startHeartRatePolling(writeEachTick: false);
    } else if (state == AppLifecycleState.paused) {
      healthService.stopHeartRatePolling();
    }
  }

  Future<void> _normalizeForToday() async {
    await _streakInit.normalizeTodayOnDashboardOpen();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _metricsPager.dispose();
    // Detén el polling y quita el listener para evitar fugas de memoria
    healthService.stopHeartRatePolling();
    if (_svcListener != null) {
      healthService.removeListener(_svcListener!);
      _svcListener = null;
    }
    super.dispose();
  }

  // ====== Diálogo para actualizar el peso ======
  void _showUpdateWeightDialog() {
    final controller = TextEditingController(
      text: healthService.weight > 0 ? healthService.weight.toStringAsFixed(1) : '',
    );
    bool writeToHC = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Actualizar peso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: 'Ej: 70.5',
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: writeToHC,
                    onChanged: (v) => setState(() => writeToHC = v ?? false),
                  ),
                  const Expanded(child: Text('Escribir también en Health Connect')),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final txt = controller.text.replaceAll(',', '.').trim();
                final kg = double.tryParse(txt);
                if (kg == null || kg <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa un peso válido (ej: 70.5)')),
                  );
                  return;
                }
                await healthService.updateWeight(kg, writeToHealthConnect: writeToHC);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Peso actualizado: ${kg.toStringAsFixed(1)} kg')),
                  );
                  setState(() {}); // refresca la UI
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
  // ====== fin diálogo ======

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    const kCardH = 140.0;
    const kGap = 12.0;
    final pagerHeight = kCardH * 2 + kGap;

    return Scaffold(
      appBar: const HomeHeader(),
      body: healthService.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF22D3A6)))
          : SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _normalizeForToday();
            await healthService.fetchAllHealthData();
            await healthService.fetchHeartRate();
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Indicador de mock data (solo desarrollo)
              if (healthService.usingMockData && !const bool.fromEnvironment('dart.vm.product'))
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(l10n.usingMockData, style: TextStyle(fontSize: 12, color: cs.onSurface)),
                      const Spacer(),
                      if (healthService.lastUpdate != null)
                        Text(
                          l10n.updatedAgo(_formatTimeSince(healthService.lastUpdate!, l10n)),
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),

              Row(
                children: [
                  _Breadcrumb(text: l10n.recoveryBreadcrumb('Lower Back Recovery', 23)),
                  const Spacer(),
                  _Chip(
                    text: l10n.weeklyChange('+8%'),
                    color: cs.primary.withOpacity(0.20),
                    icon: Icons.trending_up,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recovery Card con datos reales
              _RecoveryCard(
                percent: healthService.stepsProgress,
                message: healthService.getMotivationalMessage(),
              ),

              const SizedBox(height: 16),
              _SectionHeader(title: l10n.recoveryOptimization),
              const SizedBox(height: 8),

              // Recovery progress carousel
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final cardWidth = MediaQuery.of(context).size.width * 0.68;

                    if (index == 0) {
                      // SLEEP
                      return SizedBox(
                        width: cardWidth,
                        child: GestureDetector(
                          onTap: () {
                            final tip = RecoveryTipsService.getSleepTips(healthService.sleepHours);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => SizedBox(
                                height: MediaQuery.of(context).size.height * 0.85,
                                child: RecoveryTipsModal(
                                  tip: tip,
                                  icon: Icons.nightlight_round,
                                  gradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                                ),
                              ),
                            );
                          },
                          child: _InfoTile(
                            title: '${healthService.sleepHours.toStringAsFixed(1)}h',
                            subtitle: l10n.sleepLabel,
                            status: healthService.sleepHours >= 7 ? l10n.statusOptimal : l10n.statusLow,
                            gradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                            icon: Icons.nightlight_round,
                          ),
                        ),
                      );
                    }

                    if (index == 1) {
                      // EXERCISE
                      return SizedBox(
                        width: cardWidth,
                        child: GestureDetector(
                          onTap: () {
                            final tip = RecoveryTipsService.getExerciseTips(healthService.steps);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => SizedBox(
                                height: MediaQuery.of(context).size.height * 0.85,
                                child: RecoveryTipsModal(
                                  tip: tip,
                                  icon: Icons.local_fire_department_rounded,
                                  gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                                ),
                              ),
                            );
                          },
                          child: _InfoTile(
                            title: '${(healthService.steps / 60).round()}min',
                            subtitle: l10n.exerciseLabel,
                            status: healthService.steps >= 6000 ? l10n.statusModerate : l10n.statusLight,
                            gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                            icon: Icons.local_fire_department_rounded,
                          ),
                        ),
                      );
                    }

                    // STRESS
                    return SizedBox(
                      width: cardWidth,
                      child: GestureDetector(
                        onTap: () {
                          final tip = RecoveryTipsService.getStressTips(
                            healthService.isHealthy ? l10n.statusLow : l10n.statusModerate,
                          );
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.85,
                              child: RecoveryTipsModal(
                                tip: tip,
                                icon: Icons.security_rounded,
                                gradient: const [Color(0xFF22D3A6), Color(0xFF1DB89C)],
                              ),
                            ),
                          );
                        },
                        child: _RecoveryStatusCard(
                          levelText: healthService.isHealthy ? l10n.statusLow : l10n.statusModerate,
                          title: l10n.stressLabel,
                          caption: healthService.isHealthy ? l10n.statusLow : l10n.statusModerate,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Vitals / Health Metrics
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, c) {
                  final inline = c.maxWidth >= 380;
                  if (inline) {
                    return Row(
                      children: [
                        Expanded(child: _SectionHeader(title: _metricsTitle(l10n))),
                        const SizedBox(width: 8),
                        Flexible(
                          child: _MetricsSegmented(
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
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: _metricsTitle(l10n)),
                      const SizedBox(height: 8),
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
                  );
                },
              ),

              SizedBox(
                height: pagerHeight,
                child: PageView(
                  controller: _metricsPager,
                  onPageChanged: (i) => setState(() => _pageIndex = i),
                  children: [
                    // Página 0: Vitals con datos reales
                    _GridCards(children: [
                      // Heart Rate - mini
                      _buildSimpleVitalCard(
                        context,
                        icon: Icons.favorite,
                        label: l10n.heartRateLabel,
                        value: healthService.heartRate > 0 ? healthService.heartRate.toString() : '--',
                        unit: 'bpm',
                        color: const Color(0xFFFF6B6B),
                        subtitle: healthService.heartRate > 0
                            ? _getHeartRateStatus(healthService.heartRate, l10n)
                            : l10n.noData,
                      ),

                      // Steps - Con anillo
                      _MetricRingCard(
                        color: const Color(0xFFF59E0B),
                        value: healthService.stepsProgress,
                        valueText: (healthService.stepsProgress * 100).clamp(0, 100).round().toString(),
                        title: l10n.stepsLabel,
                        subtitle: healthService.steps.toString(),
                      ),

                      // Sleep - Con anillo
                      _MetricRingCard(
                        color: const Color(0xFF10B981),
                        value: healthService.sleepProgress,
                        valueText: (healthService.sleepProgress * 100).clamp(0, 100).round().toString(),
                        title: l10n.sleepLabel,
                        subtitle: '${healthService.sleepHours.toStringAsFixed(1)} h',
                      ),

                      // Weight - con botón editar
                      Stack(
                        children: [
                          _buildSimpleVitalCard(
                            context,
                            icon: Icons.monitor_weight,
                            label: l10n.weightLabel,
                            value: healthService.weight > 0
                                ? healthService.weight.toStringAsFixed(1)
                                : '--',
                            unit: l10n.weightUnitKg,
                            color: const Color(0xFF8B5CF6),
                            subtitle: l10n.currentLabel,
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: IconButton(
                              tooltip: 'Actualizar peso',
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: _showUpdateWeightDialog,
                            ),
                          ),
                        ],
                      ),
                    ]),

                    // Página 1: Health Metrics (mock UI)
                    _GridCards(children: [
                      _MetricRingCard(
                        color: const Color(0xFF8B5CF6),
                        value: 0.88,
                        valueText: '88',
                        title: l10n.boneLabel,
                        subtitle: l10n.densityLabel,
                      ),
                      _MetricRingCard(
                        color: const Color(0xFFF59E0B),
                        value: 0.76,
                        valueText: '76',
                        title: l10n.muscleLabel,
                        subtitle: l10n.strengthLabel,
                      ),
                      _MetricRingCard(
                        color: const Color(0xFF10B981),
                        value: 0.82,
                        valueText: '82',
                        title: l10n.jointLabel,
                        subtitle: l10n.mobilityLabel,
                      ),
                      _MetricRingCard(
                        color: const Color(0xFFEF4444),
                        value: 0.91,
                        valueText: '91',
                        title: l10n.cardioLabel,
                        subtitle: l10n.vo2maxLabel,
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
                      label: l10n.refreshData,
                      onPressed: () async {
                        await healthService.fetchAllHealthData();
                        await healthService.fetchHeartRate();
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!healthService.hasPermissions)
                    Expanded(
                      child: _PillButtonDark(
                        label: l10n.connectHealth,
                        onPressed: () async {
                          await healthService.requestPermissions();
                          if (healthService.hasPermissions) {
                            await healthService.fetchAllHealthData();
                            await healthService.fetchHeartRate();
                            healthService.startHeartRatePolling(writeEachTick: false);
                          }
                          setState(() {});
                        },
                        secondary: true,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              const AiOptimizedSessionCard(),

              const SizedBox(height: 16),
              const TodaysHabitsSection(),

              // ===== Botones extra del PRIMER script (rutas ya definidas en main.dart) =====
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.fitness_center_rounded),
                  label: const Text('Register Health Data', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/healthRegisterEnglish'),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Doctor Feedback', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/doctorFeedback'),
                ),
              ),
              // ============================================================================

            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }

  String _formatTimeSince(DateTime time, AppLocalizations l10n) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHours(diff.inHours);
    return l10n.timeDays(diff.inDays);
  }

  String _getHeartRateStatus(int bpm, AppLocalizations l10n) {
    if (bpm < 60) return l10n.statusLow;
    if (bpm >= 60 && bpm <= 100) return l10n.statusNormal;
    return l10n.statusHigh;
  }

  Widget _buildSimpleVitalCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required String unit,
        required Color color,
        required String subtitle,
      }) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
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
              // Logo WellQ
              Row(
                children: [
                  const _LogoDiamond(size: 22),
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
              // Streak badge
              const StreakBadge(),
              const SizedBox(width: 10),
              // Botón de tema
              _IconPill(
                icon: Icons.wb_sunny_rounded,
                onTap: () {
                  final platformBrightness =
                      WidgetsBinding.instance.platformDispatcher.platformBrightness;
                  final current = themeModeNotifier.value;
                  final effectiveIsDark = current == ThemeMode.dark ||
                      (current == ThemeMode.system && platformBrightness == Brightness.dark);
                  themeModeNotifier.value = effectiveIsDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
              const SizedBox(width: 10),
              // Avatar
              Builder(
                builder: (context) => CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2DA9FF),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.surface,
                    size: 18,
                  ),
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
    const listHPad = 16.0;
    const gridHPad = 12.0;
    const gap = 12.0;

    final total = MediaQuery.of(context).size.width - (listHPad * 2);
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
      children: [
        const Icon(Icons.folder_open_rounded, size: 18, color: Color(0xFF9AA4B2)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Color(0xFFC7D0DD)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
  final String? message;

  const _RecoveryCard({
    required this.percent,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final clamped = percent.clamp(0.0, 1.0);
    final pctText = '${(clamped * 100).round()}%';

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
              l10n.recoveryOptimization,
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
              centerLabelBuilder: () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pctText,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.recoveryLabel,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
                  Text(
                    levelText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w700),
                      ),
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
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<int>(
      segments: [
        ButtonSegment(
          value: 0,
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(l10n.vitalsTab, overflow: TextOverflow.ellipsis),
          ),
        ),
        ButtonSegment(
          value: 1,
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(l10n.metricsTab, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      selected: {index},
      onSelectionChanged: (set) => onChanged(set.first),
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity(horizontal: -3, vertical: -3),
        minimumSize: WidgetStatePropertyAll(Size(0, 36)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
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
  final Widget Function()? centerLabelBuilder;

  const _Ring({
    required this.value,
    required this.size,
    required this.thickness,
    required this.trackColor,
    required this.progressColor,
    required this.startAngle,
    this.centerLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              value: value.clamp(0.0, 1.0),
              thickness: thickness,
              trackColor: trackColor,
              progressColor: progressColor,
              startAngle: startAngle,
            ),
          ),
          if (centerLabelBuilder != null) centerLabelBuilder!(),
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
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value ||
          old.thickness != thickness ||
          old.trackColor != trackColor ||
          old.progressColor != progressColor ||
          old.startAngle != startAngle;
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
    return Card(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
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
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Colors.white70)),
                    Text(status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
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
    final l10n = AppLocalizations.of(context);

    const baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF7C83FF), Color(0xFF8E56C9)],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(gradient: baseGradient),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final sweep = -1.5 + 3.0 * _ctrl.value;
                return ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (rect) {
                    final dx = rect.width * sweep;
                    return const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.45, 0.55, 1.0],
                    ).createShader(rect.shift(Offset(dx, 0)));
                  },
                  child: Container(color: Colors.white.withValues(alpha: 0.3)),
                );
              },
            ),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white.withValues(alpha: 0.9), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.aiSessionTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.aiSessionSubtitle(18),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.basedOnRecovery,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const _StartButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(l10n.start, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

//===========================================================
// BOTTOM NAVBAR PARA CAMBIAR DE PANTALLA
//===========================================================
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

        // Navegación correcta
        switch (index) {
          case 0:
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
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

// Utilidad
extension LastOrNull<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}






