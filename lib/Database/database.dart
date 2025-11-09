import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Doctors,
  Patients,
  Devices,
  Consents,
  Routines,
  CarePlans,
  HealthMetrics,
  Habits,
  HabitCompletions,
  WorkoutSessions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'appwellq_db.db'));

      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
        final cachebase = (await getTemporaryDirectory()).path;
        sqlite3.tempDirectory = cachebase;
      }

      return NativeDatabase(file);
    });
  }

  // ========== DOCTORS ==========
  Future<List<Doctor>> getAllDoctors() => select(doctors).get();

  Future<Doctor?> getDoctorById(int id) =>
      (select(doctors)..where((d) => d.id.equals(id))).getSingleOrNull();

  Future<int> insertDoctor(DoctorsCompanion doctor) =>
      into(doctors).insert(doctor);

  Future<bool> updateDoctor(Doctor doctor) =>
      update(doctors).replace(doctor);

  Future<int> deleteDoctor(int id) =>
      (delete(doctors)..where((d) => d.id.equals(id))).go();

  // ========== PATIENTS ==========
  Future<List<Patient>> getAllPatients() => select(patients).get();

  Future<Patient?> getPatientById(int id) =>
      (select(patients)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertPatient(PatientsCompanion patient) =>
      into(patients).insert(patient);

  Future<bool> updatePatient(Patient patient) =>
      update(patients).replace(patient);

  Future<int> deletePatient(int id) =>
      (delete(patients)..where((p) => p.id.equals(id))).go();

  // ========== DEVICES ==========
  Future<List<Device>> getAllDevices() => select(devices).get();

  Future<List<Device>> getDevicesByPatient(int patientId) =>
      (select(devices)..where((d) => d.patientId.equals(patientId))).get();

  Future<int> insertDevice(DevicesCompanion device) =>
      into(devices).insert(device);

  Future<bool> updateDevice(Device device) =>
      update(devices).replace(device);

  Future<int> deleteDevice(int id) =>
      (delete(devices)..where((d) => d.id.equals(id))).go();

  // ========== CONSENTS ==========
  Future<List<Consent>> getConsentsByPatient(int patientId) =>
      (select(consents)..where((c) => c.patientId.equals(patientId))).get();

  Future<int> insertConsent(ConsentsCompanion consent) =>
      into(consents).insert(consent);

  Future<bool> updateConsent(Consent consent) =>
      update(consents).replace(consent);

  // ========== ROUTINES ==========
  Future<List<Routine>> getRoutinesByPatient(int patientId) =>
      (select(routines)..where((r) => r.patientId.equals(patientId))).get();

  Future<int> insertRoutine(RoutinesCompanion routine) =>
      into(routines).insert(routine);

  Future<bool> updateRoutine(Routine routine) =>
      update(routines).replace(routine);

  Future<int> deleteRoutine(int id) =>
      (delete(routines)..where((r) => r.id.equals(id))).go();

  // ========== CARE PLANS ==========
  Future<List<CarePlan>> getCarePlansByPatient(int patientId) =>
      (select(carePlans)..where((c) => c.patientId.equals(patientId))).get();

  Future<int> insertCarePlan(CarePlansCompanion carePlan) =>
      into(carePlans).insert(carePlan);

  Future<bool> updateCarePlan(CarePlan carePlan) =>
      update(carePlans).replace(carePlan);

  Future<int> deleteCarePlan(int id) =>
      (delete(carePlans)..where((c) => c.id.equals(id))).go();

  // ========== HEALTH METRICS ==========
  Future<List<HealthMetric>> getMetricsByPatient(int patientId, {int? limit}) {
    final query = select(healthMetrics)
      ..where((m) => m.patientId.equals(patientId))
      ..orderBy([(m) => OrderingTerm.desc(m.timestamp)]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.get();
  }

  Future<int> insertMetric(HealthMetricsCompanion metric) =>
      into(healthMetrics).insert(metric);

  Stream<List<HealthMetric>> watchMetricsByPatient(int patientId) {
    return (select(healthMetrics)
      ..where((m) => m.patientId.equals(patientId))
      ..orderBy([(m) => OrderingTerm.desc(m.timestamp)]))
        .watch();
  }

  Future<int> deleteMetric(int id) =>
      (delete(healthMetrics)..where((m) => m.id.equals(id))).go();

  // ========== HABITS ==========
  Future<List<Habit>> getTodaysHabits({int? patientId}) {
    final query = select(habits);

    if (patientId != null) {
      query.where((h) => h.patientId.equals(patientId));
    }

    return query.get();
  }

  Stream<List<Habit>> watchTodaysHabits({int? patientId}) {
    final query = select(habits);

    if (patientId != null) {
      query.where((h) => h.patientId.equals(patientId));
    }

    return query.watch();
  }

  Future<Habit?> getHabitById(int id) =>
      (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();

  Future<int> insertHabit(HabitsCompanion habit) =>
      into(habits).insert(habit);

  Future<bool> updateHabit(Habit habit) =>
      update(habits).replace(habit);

  Future<int> deleteHabit(int id) =>
      (delete(habits)..where((h) => h.id.equals(id))).go();

  Future<void> resetDailyHabits() async {
    await (update(habits)..where((h) => h.completedToday.equals(true)))
        .write(const HabitsCompanion(
      completedToday: Value(false),
    ));
  }

  // ========== HABIT STREAKS ==========

  /// Completa un hábito y actualiza la racha
  Future<void> completeHabitWithStreak(int habitId) async {
    final habit = await getHabitById(habitId);
    if (habit == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Verificar si ya se completó hoy
    if (habit.lastCompletedDate != null) {
      final lastDate = DateTime(
        habit.lastCompletedDate!.year,
        habit.lastCompletedDate!.month,
        habit.lastCompletedDate!.day,
      );

      if (lastDate == today) return;
    }

    // Calcular nueva racha
    final newStreak = _calculateStreak(habit, today);
    final newLongestStreak = newStreak > habit.longestStreak ? newStreak : habit.longestStreak;

    // Actualizar el hábito
    await (update(habits)..where((h) => h.id.equals(habitId)))
        .write(HabitsCompanion(
      completedToday: const Value(true),
      currentStreak: Value(newStreak),
      longestStreak: Value(newLongestStreak),
      lastCompletedDate: Value(now),
      lastUpdated: Value(now),
    ));

    // Registrar en el historial
    await into(habitCompletions).insert(
      HabitCompletionsCompanion.insert(
        habitId: habitId,
        completedDate: now,
        durationCompleted: habit.durationMinutes,
      ),
    );
  }

  /// Calcula la nueva racha basada en el último completado
  int _calculateStreak(Habit habit, DateTime today) {
    if (habit.lastCompletedDate == null) return 1;

    final lastDate = DateTime(
      habit.lastCompletedDate!.year,
      habit.lastCompletedDate!.month,
      habit.lastCompletedDate!.day,
    );
    final yesterday = today.subtract(const Duration(days: 1));

    return lastDate == yesterday ? habit.currentStreak + 1 : 1;
  }

  /// Obtener racha global (máxima de todos los hábitos)
  Future<Map<String, int>> getGlobalStreak() async {
    final allHabits = await select(habits).get();

    if (allHabits.isEmpty) {
      return {'current': 0, 'longest': 0};
    }

    final currentMax = allHabits
        .map((h) => h.currentStreak)
        .reduce((a, b) => a > b ? a : b);
    final longestMax = allHabits
        .map((h) => h.longestStreak)
        .reduce((a, b) => a > b ? a : b);

    return {
      'current': currentMax,
      'longest': longestMax,
    };
  }

  /// Verificar y actualizar rachas rotas
  Future<void> checkAndUpdateStreaks() async {
    final allHabits = await select(habits).get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final habit in allHabits) {
      if (_shouldResetStreak(habit, today)) {
        await (update(habits)..where((h) => h.id.equals(habit.id)))
            .write(const HabitsCompanion(
          currentStreak: Value(0),
        ));
      }
    }
  }

  /// Verifica si una racha debe resetearse
  bool _shouldResetStreak(Habit habit, DateTime today) {
    if (habit.lastCompletedDate == null || habit.currentStreak == 0) {
      return false;
    }

    final lastDate = DateTime(
      habit.lastCompletedDate!.year,
      habit.lastCompletedDate!.month,
      habit.lastCompletedDate!.day,
    );

    return today.difference(lastDate).inDays > 1;
  }

  // ========== HABIT COMPLETIONS ==========

  Future<List<HabitCompletion>> getHabitHistory(int habitId, {int? limit}) {
    final query = select(habitCompletions)
      ..where((c) => c.habitId.equals(habitId))
      ..orderBy([(c) => OrderingTerm.desc(c.completedDate)]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.get();
  }

  Future<int> getTotalCompletions(int habitId) async {
    final completions = await (select(habitCompletions)
      ..where((c) => c.habitId.equals(habitId)))
        .get();
    return completions.length;
  }

  Future<int> deleteHabitCompletion(int id) =>
      (delete(habitCompletions)..where((c) => c.id.equals(id))).go();

  //===============WorkoutSessions============================

  Future<int> insertWorkoutSession({
    required String category,
    required String categoryName,
    required int painLevel,
    required int stiffness,
    String? notes,
    required DateTime completedAt,
  }) async {
    return await into(workoutSessions).insert(
      WorkoutSessionsCompanion.insert(
        category: category,
        categoryName: categoryName,
        painLevel: painLevel,
        stiffness: stiffness,
        notes: Value(notes),
        completedAt: completedAt,
      ),
    );
  }
}

// --- NUEVO: Eventos y Recordatorios ---
class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get dateKey => integer()(); // yyyymmdd
  TextColumn get title => text()();
  TextColumn get time => text().withDefault(const Constant(''))(); // "10:00 - 11:00" (como usas hoy)
  IntColumn get color => integer().withDefault(const Constant(0))(); // Color.value
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get dueAt => dateTime()();       // cuándo “vence”
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get color => integer().withDefault(const Constant(0))();
  IntColumn get notificationId => integer().nullable()(); // id notificación local (si la programaste)
}