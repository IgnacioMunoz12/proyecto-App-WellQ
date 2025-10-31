import 'package:drift/drift.dart';

// Doctors
class Doctors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get specialty => text().nullable()();
  TextColumn get email => text().unique()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Patients
class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get doctorId => integer().references(Doctors, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().unique()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Devices
class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  TextColumn get deviceType => text()(); // 'smartwatch', 'fitness_tracker', etc.
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get connectedAt => dateTime().withDefault(currentDateAndTime)();
}

// Consents
class Consents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  BoolColumn get dataSharing => boolean().withDefault(const Constant(false))();
  BoolColumn get medicalTreatment => boolean().withDefault(const Constant(false))();
  DateTimeColumn get acceptedAt => dateTime().withDefault(currentDateAndTime)();
}

// Routines
class Routines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get durationMinutes => integer()();
  TextColumn get routineType => text()(); // 'therapy', 'exercise', 'meditation'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Care Plans
class CarePlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  IntColumn get doctorId => integer().references(Doctors, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get objectives => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Health Metrics
class HealthMetrics extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  TextColumn get metricType => text()(); // 'heart_rate', 'steps', 'weight', 'sleep'
  RealColumn get value => real()();
  TextColumn get unit => text()(); // 'bpm', 'kg', 'steps', 'hours'
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get source => text().nullable()(); // 'manual', 'google_fit', 'device'
}

// Habits table
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id).nullable()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get durationMinutes => integer()();
  TextColumn get iconName => text()(); // Icon identifier
  TextColumn get colorHex => text()(); // Color in hex format
  BoolColumn get completedToday => boolean().withDefault(const Constant(false))();
  DateTimeColumn get scheduledTime => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastUpdated => dateTime().nullable()();
  //CAMPOS PARA STREAKS
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastCompletedDate => dateTime().nullable()();
}
// tabla para historial de completados
class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  DateTimeColumn get completedDate => dateTime()();
  IntColumn get durationCompleted => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// WorkoutSessions - Para ejercicios de recuperación
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()(); // 'A', 'B', 'C'
  TextColumn get categoryName => text()(); // 'Rotura de ligamento', etc.
  IntColumn get painLevel => integer()();
  IntColumn get stiffness => integer()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get completedAt => dateTime()();
}