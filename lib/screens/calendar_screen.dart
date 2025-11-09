import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert'; // <-- NUEVO (persistencia)
import 'package:shared_preferences/shared_preferences.dart'; // <-- NUEVO
import '../l10n/app_localizations.dart';

import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'commit_screen.dart';
import 'settings_screen.dart';
import '../services/notification_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentDate;
  DateTime? _selectedDate;

  // ====== EVENTOS ============================================================
  // Guardamos por fecha completa (YYYY-MM-DD) para evitar mezclar meses/años.
  final Map<DateTime, List<Event>> _events = {};

  // ====== RECORDATORIOS ======================================================
  // Los de ejemplo que ya mostrabas (persisten como "plantilla")
  late final List<ReminderTemplate> _reminders;
  // Recordatorios creados por el usuario (con check de completado)
  final List<UserReminder> _userReminders = [];
  final Map<String, Timer> _reminderTimers = {}; // id -> timer

  // --- CLAVES de almacenamiento ---
  static const _kEventsKey = 'calendar_events_v1';
  static const _kUserRemindersKey = 'calendar_user_reminders_v1';

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = DateTime.now();

    // Plantillas mostradas en la tarjeta (como antes)
    _reminders = [
      ReminderTemplate('takeMedication', const Duration(minutes: 18), Colors.orange),
      ReminderTemplate('iceTherapy', const Duration(hours: 1, minutes: 2), Colors.blue),
      ReminderTemplate('logPain', const Duration(hours: 2), Colors.red, showAsDueIn: true),
    ];

    // Cargar persistencia; si no hay, inyectar ejemplos
    _loadPersistedData();
  }

  @override
  void dispose() {
    for (final t in _reminderTimers.values) {
      t.cancel();
    }
    _reminderTimers.clear();
    super.dispose();
  }

  // ===================== PERSISTENCIA (Eventos/Recordatorios) =================

  Future<void> _loadPersistedData() async {
    final prefs = await SharedPreferences.getInstance();

    // --- Eventos ---
    final jsonEvents = prefs.getString(_kEventsKey);
    if (jsonEvents != null && jsonEvents.isNotEmpty) {
      try {
        final Map<String, dynamic> raw = json.decode(jsonEvents);
        _events.clear();
        raw.forEach((k, v) {
          final date = _parseDateKeyStr(k);
          final list = (v as List).map((e) {
            // 🗂 soporta start/end opcionales si vienen guardados
            final startMs = e['startMs'] as int?;
            final endMs = e['endMs'] as int?;
            return Event(
              e['title'] as String,
              e['time'] as String,
              Color(e['color'] as int),
              start: startMs != null ? DateTime.fromMillisecondsSinceEpoch(startMs) : null,
              end: endMs != null ? DateTime.fromMillisecondsSinceEpoch(endMs) : null,
            );
          }).toList();
          _events[date] = list;
        });
      } catch (_) {
        // si falla, no rompemos la UI; dejamos vacío
      }
    } else {
      // Seed: los mismos ejemplos que tenías, pero mapeados al mes actual
      final now = DateTime.now();
      void seed(int day, Event e) {
        final key = _dateKey(DateTime(now.year, now.month, day));
        _events.putIfAbsent(key, () => []).add(e);
      }

      seed(3,  Event('Morning Stretches', '6:00 AM - 6:30 AM', Colors.blue));
      seed(7,  Event('Physical Therapy', '10:00 AM - 11:00 AM', Colors.green));
      seed(7,  Event('Evening Walk', '6:00 PM - 6:30 PM', Colors.orange));
      seed(12, Event('Doctor Appointment', '2:00 PM - 3:00 PM', Colors.red));
      seed(15, Event('Gym Session', '7:00 AM - 8:00 AM', Colors.purple));
      seed(20, Event('Yoga Class', '5:00 PM - 6:00 PM', Colors.teal));
      seed(24, Event('Nutrition Consultation', '11:00 AM - 12:00 PM', Colors.indigo));
      seed(28, Event('Physical Check-up', '9:00 AM - 10:00 AM', Colors.pink));
      await _saveEvents();
    }

    // --- Recordatorios de usuario ---
    final jsonRems = prefs.getString(_kUserRemindersKey);
    _userReminders.clear();
    if (jsonRems != null && jsonRems.isNotEmpty) {
      try {
        final List raw = json.decode(jsonRems);
        for (final r in raw) {
          final item = UserReminder(
            id: r['id'] as String,
            title: r['title'] as String,
            when: DateTime.parse(r['when'] as String),
            done: r['done'] as bool,
          );
          _userReminders.add(item);
        }
      } catch (_) {
        // ignora errores de parsing
      }
    }

    // Reprogramar timers (sólo los pendientes)
    for (final r in _userReminders) {
      if (!r.done && r.when.isAfter(DateTime.now())) {
        _scheduleLocalReminder(r);
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, List<Map<String, dynamic>>> raw = {};
    _events.forEach((date, list) {
      final k = _dateKeyStr(date);
      raw[k] = list
          .map((e) => {
        'title': e.title,
        'time': e.time,
        'color': e.color.value,
        // 🗂 guardamos start/end si existen
        if (e.start != null) 'startMs': e.start!.millisecondsSinceEpoch,
        if (e.end != null) 'endMs': e.end!.millisecondsSinceEpoch,
      })
          .toList();
    });
    await prefs.setString(_kEventsKey, json.encode(raw));
  }

  Future<void> _saveUserReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _userReminders
        .map((r) => {
      'id': r.id,
      'title': r.title,
      'when': r.when.toIso8601String(),
      'done': r.done,
    })
        .toList();
    await prefs.setString(_kUserRemindersKey, json.encode(raw));
  }

  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: const HomeHeader(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.calendarTitle,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.calendarSubtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              _buildCalendarCard(cs, l10n),

              const SizedBox(height: 24),

              _buildEventsCard(cs, l10n),

              const SizedBox(height: 16),

              _buildRemindersCard(cs, l10n),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _CalendarBottomNav(),
    );
  }

  // ====================== CALENDARIO =========================================

  Widget _buildCalendarCard(ColorScheme cs, AppLocalizations l10n) {
    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _monthYearText(_currentDate, l10n),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
                        });
                      },
                      icon: Icon(Icons.chevron_left, color: cs.onSurface),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
                        });
                      },
                      icon: Icon(Icons.chevron_right, color: cs.onSurface),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: _localizedWeekdays(l10n).map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            _buildCalendarGrid(cs, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(ColorScheme cs, AppLocalizations l10n) {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        final isCurrentMonth = date.month == _currentDate.month;
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
        final hasEvents = _events.containsKey(_dateKey(date)) && isCurrentMonth;

        return GestureDetector(
          onTap: () async {
            setState(() => _selectedDate = date);
            // Abrir diálogo para crear evento
            await _openCreateEventDialog(date, l10n, cs);
          },
          child: Container(
            decoration: BoxDecoration(
              color: hasEvents
                  ? cs.primary
                  : isSelected
                  ? cs.primary.withOpacity(0.2)
                  : isToday
                  ? cs.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: !isCurrentMonth
                      ? cs.onSurfaceVariant.withOpacity(0.3)
                      : hasEvents
                      ? cs.onPrimary
                      : isToday
                      ? cs.onPrimaryContainer
                      : cs.onSurface,
                  fontWeight: isToday || hasEvents ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCreateEventDialog(
      DateTime date, AppLocalizations l10n, ColorScheme cs) async {
    final titleCtrl = TextEditingController();
    TimeOfDay? from;
    TimeOfDay? to;

    Future<void> pickFrom() async {
      final res = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (res != null) setState(() => from = res);
    }

    Future<void> pickTo() async {
      final res = await showTimePicker(
        context: context,
        initialTime: (from ?? TimeOfDay.now()),
      );
      if (res != null) setState(() => to = res);
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(DateFormat.yMMMMd(l10n.localeName).format(date)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: l10n.reminders, // reutilizamos clave; si tienes una para "Título", cámbiala aquí
                hintText: 'Ej: Sesión de fisioterapia',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickFrom,
                    child: Text(from == null
                        ? 'Desde'
                        : _formatTimeOfDay(from!, l10n)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickTo,
                    child:
                    Text(to == null ? 'Hasta' : _formatTimeOfDay(to!, l10n)),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) {
                Navigator.pop(context);
                return;
              }

              // 🔔 combinamos fecha + hora para programar notificación del evento
              DateTime? startDt;
              DateTime? endDt;
              if (from != null) {
                startDt = DateTime(date.year, date.month, date.day, from!.hour, from!.minute);
              }
              if (to != null) {
                endDt = DateTime(date.year, date.month, date.day, to!.hour, to!.minute);
              }

              final key = _dateKey(date);
              final timeStr = (from == null && to == null)
                  ? 'Todo el día'
                  : '${from != null ? _formatTimeOfDay(from!, l10n) : ''}'
                  '${(from != null && to != null) ? ' - ' : ''}'
                  '${to != null ? _formatTimeOfDay(to!, l10n) : ''}';

              _events.putIfAbsent(key, () => []);
              _events[key]!.add(Event(title, timeStr, cs.primary,
                  start: startDt, end: endDt));
              await _saveEvents(); // <-- guarda

              // ⚠️ SOLO agenda la notificación genérica si NO hay hora de inicio
              if (startDt == null) {
                try {
                  await NotificationService().schedule(
                    title: title,
                    body: timeStr.isEmpty ? 'Tienes un evento programado' : timeStr,
                    when: DateTime(date.year, date.month, date.day, 9, 0), // heurística si es "todo el día"
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se pudo agendar notificación: $e')),
                    );
                  }
                }
              }

              if (mounted) setState(() {});

              // 🔔 Programa notificación si tiene hora "Desde" y es futura
              if (startDt != null && startDt.isAfter(DateTime.now())) {
                try {
                  await NotificationService().schedule(
                    title: 'Evento: $title',
                    body: 'Comienza a las ${DateFormat('HH:mm').format(startDt)}',
                    when: startDt,
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No se pudo agendar notificación: $e')),
                    );
                  }
                }
              }

              Navigator.pop(context);

              // Si creaste para hoy, muestra feedback
              if (_isSameDay(date, DateTime.now()) && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Evento creado para hoy: $title')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // ====================== TARJETA EVENTOS ====================================

  Widget _buildEventsCard(ColorScheme cs, AppLocalizations l10n) {
    final dateForEvents = _selectedDate ?? DateTime.now();
    final isToday = _isSameDay(dateForEvents, DateTime.now());
    final title = isToday
        ? l10n.todaysEvents
        : '${l10n.todaysEvents} • ${DateFormat.yMd(l10n.localeName).format(dateForEvents)}';

    return Card(
      color: cs.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: cs.onPrimaryContainer, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEventsForDate(cs, l10n, dateForEvents),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsForDate(ColorScheme cs, AppLocalizations l10n, DateTime date) {
    final items = _events[_dateKey(date)] ?? [];

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            l10n.noEventsToday,
            style: TextStyle(
              color: cs.onPrimaryContainer.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: items.map((event) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        )),
                    const SizedBox(height: 4),
                    Text(event.time,
                        style: TextStyle(
                          color: cs.onPrimaryContainer.withOpacity(0.7),
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ====================== TARJETA RECORDATORIOS ==============================

  Widget _buildRemindersCard(ColorScheme cs, AppLocalizations l10n) {
    return Card(
      color: cs.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_outlined, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.reminders,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Botón para crear recordatorio
                TextButton.icon(
                  onPressed: _openCreateReminderDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Plantillas (como antes)
            Column(
              children: _reminders.map((rem) {
                final title = switch (rem.key) {
                  'takeMedication' => l10n.reminderTakeMedication,
                  'iceTherapy'     => l10n.reminderIceTherapy,
                  'logPain'        => l10n.reminderLogPainLevels,
                  _                => rem.key,
                };

                final timeText = rem.showAsDueIn
                    ? l10n.dueIn(_formatDuration(rem.when))
                    : _formatDuration(rem.when);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: rem.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                )),
                            const SizedBox(height: 2),
                            Text(timeText,
                                style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
                    ],
                  ),
                );
              }).toList(),
            ),

            if (_userReminders.isNotEmpty) ...[
              const SizedBox(height: 12),
              Divider(color: cs.outlineVariant),
              const SizedBox(height: 12),
              Text('Tus recordatorios', style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(height: 8),
              Column(
                children: _userReminders.map((r) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: r.done,
                          onChanged: (v) async {
                            setState(() => r.done = v ?? false);
                            if (r.done) {
                              _cancelTimer(r.id);
                            }
                            await _saveUserReminders(); // <-- guarda cambio de estado
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.title,
                                style: TextStyle(
                                  decoration: r.done ? TextDecoration.lineThrough : null,
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Para: ${DateFormat('dd/MM HH:mm', l10n.localeName).format(r.when)}',
                                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            _cancelTimer(r.id);
                            setState(() {
                              _userReminders.removeWhere((e) => e.id == r.id);
                            });
                            await _saveUserReminders(); // <-- guarda eliminación
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateReminderDialog() async {
    final titleCtrl = TextEditingController();
    DateTime when = DateTime.now().add(const Duration(minutes: 10));

    Future<void> pickDate() async {
      final d = await showDatePicker(
        context: context,
        initialDate: when,
        firstDate: DateTime.now().subtract(const Duration(days: 0)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (d != null) {
        when = DateTime(d.year, d.month, d.day, when.hour, when.minute);
        setState(() {});
      }
    }

    // 🔇 (se quitó un schedule de prueba que se ejecutaba siempre al abrir el diálogo)

    Future<void> pickTime() async {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(when),
      );
      if (t != null) {
        when = DateTime(when.year, when.month, when.day, t.hour, t.minute);
        setState(() {});
      }
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nuevo recordatorio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Tomar medicamento',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickDate,
                    child: Text(DateFormat('dd/MM/yyyy').format(when)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickTime,
                    child: Text(DateFormat('HH:mm').format(when)),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) {
                Navigator.pop(context);
                return;
              }
              final item = UserReminder(
                id: UniqueKey().toString(),
                title: title,
                when: when,
              );
              setState(() => _userReminders.add(item));
              _scheduleLocalReminder(item); // feedback en primer plano
              // 🔔 programa notificación nativa para el horario indicado
              try {
                await NotificationService().schedule(
                  title: item.title,
                  body: 'Tienes un compromiso programado.',
                  when: item.when,
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo agendar notificación: $e')),
                  );
                }
              }
              await _saveUserReminders(); // <-- guarda
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recordatorio creado para ${DateFormat('dd/MM HH:mm').format(when)}')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Simulación de notificación local (en primer plano) con Timer.
  // Para push reales, integra flutter_local_notifications en un servicio
  // y reemplaza este método manteniendo la firma.
  void _scheduleLocalReminder(UserReminder r) {
    final diff = r.when.difference(DateTime.now());
    if (diff.isNegative) return;

    _reminderTimers[r.id]?.cancel();
    _reminderTimers[r.id] = Timer(diff, () {
      if (!mounted) return;
      if (r.done) return; // si ya lo marcó como hecho, no avisar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔔 ${r.title}'),
          action: SnackBarAction(
            label: 'Marcar hecho',
            onPressed: () async {
              setState(() => r.done = true);
              await _saveUserReminders(); // <-- persistir cambio si lo marca desde el SnackBar
            },
          ),
        ),
      );
    });
  }

  void _cancelTimer(String id) {
    _reminderTimers[id]?.cancel();
    _reminderTimers.remove(id);
  }

  // ====================== UTILIDADES =========================================

  List<String> _localizedWeekdays(AppLocalizations l10n) {
    final locale = l10n.localeName;
    final start = DateTime(2025, 1, 5); // domingo
    return List<String>.generate(7, (i) {
      final d = start.add(Duration(days: i));
      return DateFormat.E(locale).format(d).toLowerCase();
    });
  }

  String _monthYearText(DateTime date, AppLocalizations l10n) {
    final locale = l10n.localeName;
    return toBeginningOfSentenceCase(DateFormat.yMMMM(locale).format(date))!;
  }

  String _formatDuration(Duration d) {
    final l10n = AppLocalizations.of(context);
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes % 60;
      if (m == 0) return l10n.timeHours(h);
      return '${l10n.timeHours(h)} ${l10n.timeMinutes(m)}';
    }
    return l10n.timeMinutes(d.inMinutes);
  }

  String _formatTimeOfDay(TimeOfDay t, AppLocalizations l10n) {
    final dt = DateTime(0, 1, 1, t.hour, t.minute);
    return DateFormat.jm(l10n.localeName).format(dt);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);

  String _dateKeyStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _parseDateKeyStr(String s) {
    final parts = s.split('-').map((e) => int.tryParse(e) ?? 1).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }
}

// ====== MODELOS ===============================================================

class Event {
  final String title;
  final String time;
  final Color color;

  // 🔔 NUEVO: soporta hora de inicio/fin para programar notificación
  final DateTime? start;
  final DateTime? end;

  Event(this.title, this.time, this.color, {this.start, this.end});
}

class ReminderTemplate {
  final String key;
  final Duration when;
  final Color color;
  final bool showAsDueIn;
  ReminderTemplate(this.key, this.when, this.color, {this.showAsDueIn = false});
}

class UserReminder {
  final String id;
  final String title;
  final DateTime when;
  bool done;
  UserReminder({required this.id, required this.title, required this.when, this.done = false});
}

// ====== NAV BAR ===============================================================

class _CalendarBottomNav extends StatefulWidget {
  const _CalendarBottomNav();

  @override
  State<_CalendarBottomNav> createState() => _CalendarBottomNavState();
}

class _CalendarBottomNavState extends State<_CalendarBottomNav> {
  int _currentIndex = 2;

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
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
            break;
          case 1:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
            break;
          case 2:
            break;
          case 3:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CommitScreen()));
            break;
          case 4:
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
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






