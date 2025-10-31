// lib/services/streak_initializer.dart
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';

DateTime _startOfDayLocal(DateTime now) {
  final l = now.toLocal();
  return DateTime(l.year, l.month, l.day);
}

class StreakInitializer {
  final AppDatabase db;
  StreakInitializer(this.db);

  // Idempotente: corrige “hecho hoy” y actualiza racha si ya hay completion hoy.
  Future<void> normalizeTodayOnDashboardOpen({DateTime? now}) async {
    final nowLocal = (now ?? DateTime.now()).toLocal();
    final today = _startOfDayLocal(nowLocal);
    final yesterday = today.subtract(const Duration(days: 1));

    // Trae hábitos; en tu diseño no filtras por activos/paciente aquí.
    final habits = await db.getTodaysHabits(); // ya existe en tu AppDatabase

    for (final h in habits) {
      // Normaliza campos por fecha local
      final last = h.lastCompletedDate == null
          ? null
          : DateTime(h.lastCompletedDate!.year, h.lastCompletedDate!.month, h.lastCompletedDate!.day);

      // Si la UI quedó con completedToday=true pero ya cambió el día, limpiar completedToday sin tocar racha aquí.
      final isStaleCompletedToday = h.completedToday && (last == null || last != today);

      if (isStaleCompletedToday) {
        await (db.update(db.habits)..where((t) => t.id.equals(h.id))).write(const HabitsCompanion(
          completedToday: Value(false),
        ));
      }

      // Si lastCompletedDate es hoy pero completedToday==false por cualquier razón, alinear flags y racha.
      if (last == today && !h.completedToday) {
        // Recalcular racha según tu cálculo existente (_calculateStreak).
        final newStreak = _recalculateStreakFromModel(h, today, yesterday);
        final newLongest = newStreak > h.longestStreak ? newStreak : h.longestStreak;

        await (db.update(db.habits)..where((t) => t.id.equals(h.id))).write(HabitsCompanion(
          completedToday: const Value(true),
          currentStreak: Value(newStreak),
          longestStreak: Value(newLongest),
          lastUpdated: Value(nowLocal),
        ));
      }
    }
  }

  // Mapea tu _calculateStreak (yesterday -> +1, si no -> 1)
  int _recalculateStreakFromModel(Habit h, DateTime today, DateTime yesterday) {
    if (h.lastCompletedDate == null) return 1;
    final last = DateTime(h.lastCompletedDate!.year, h.lastCompletedDate!.month, h.lastCompletedDate!.day);
    return (last == yesterday) ? (h.currentStreak + 1) : 1;
  }
}
