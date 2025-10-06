import 'package:drift/drift.dart';

// Tabla Médicos
class Medicos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombres => text()();
  TextColumn get apellidos => text()();
  TextColumn get rut => text().unique()();
  TextColumn get email => text()();
  TextColumn get telefono => text()();
  TextColumn get especialidades => text()(); // JSON array como string
  TextColumn get estado => text().withDefault(const Constant('activo'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabla Pacientes
class Pacientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombres => text()();
  TextColumn get apellidos => text()();
  TextColumn get rut => text().unique()();
  TextColumn get direccion => text()();
  TextColumn get telefono => text()();
  TextColumn get email => text()();
  DateTimeColumn get fechaNacimiento => dateTime()();
  TextColumn get sexo => text()(); // M/F/X
  RealColumn get alturaCm => real()();
  RealColumn get pesoKg => real()();
  IntColumn get doctorCabeceraId => integer().nullable().references(Medicos, #id)();
  TextColumn get estado => text().withDefault(const Constant('activo'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabla Dispositivos
class Dispositivos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pacienteId => integer().references(Pacientes, #id)();
  TextColumn get tipo => text()(); // watch, banda, app
  TextColumn get proveedor => text()(); // samsung_health, google_fit, etc.
  TextColumn get modelo => text()();
  TextColumn get deviceUid => text().unique()();
  TextColumn get estado => text().withDefault(const Constant('activo'))();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  DateTimeColumn get deliverAt => dateTime()();
}

// Tabla Consentimientos
class Consentimientos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pacienteId => integer().references(Pacientes, #id)();
  TextColumn get version => text()();
  TextColumn get estado => text()(); // vigente, revocado, expirado
  TextColumn get scopes => text()(); // JSON array como string
  DateTimeColumn get firmadoAt => dateTime()();
  DateTimeColumn get revocadoAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabla Rutinas
class Rutinas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text()();
  TextColumn get descripcion => text()();
  TextColumn get dificultad => text()(); // baja, media, alta
  RealColumn get duracionMin => real()();
  TextColumn get assets => text()(); // JSON array de objetos
  TextColumn get estado => text().withDefault(const Constant('activo'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabla Planes de Cuidado
class PlanesCuidado extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pacienteId => integer().references(Pacientes, #id)();
  IntColumn get medicoId => integer().references(Medicos, #id)();
  TextColumn get estado => text().withDefault(const Constant('activo'))(); // activo, pausado, cerrado
  TextColumn get objetivos => text()(); // JSON array
  TextColumn get items => text()(); // JSON array de objetos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabla Métricas de Salud
class MetricasSalud extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get ts => dateTime()(); // timestamp de la medición
  IntColumn get pacienteId => integer().references(Pacientes, #id)();
  IntColumn get medicoId => integer().nullable().references(Medicos, #id)();
  IntColumn get dispositivoId => integer().nullable().references(Dispositivos, #id)();
  TextColumn get source => text()(); // samsung_health, google_fit, manual
  TextColumn get metric => text()(); // fc, bp, glucosa, pasos
  TextColumn get unidad => text()();
  RealColumn get value => real().nullable()(); // valor simple
  TextColumn get valueMap => text().nullable()(); // JSON para valores compuestos
  TextColumn get notes => text().nullable()();
}
