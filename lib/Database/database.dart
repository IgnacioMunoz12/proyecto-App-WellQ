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
  Medicos,
  Pacientes,
  Dispositivos,
  Consentimientos,
  Rutinas,
  PlanesCuidado,
  MetricasSalud,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      // Carpeta de documentos de la app
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'appwellq_db.db'));

      // Workaround para Android antiguo
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
        final cachebase = (await getTemporaryDirectory()).path;
        sqlite3.tempDirectory = cachebase;
      }

      return NativeDatabase(file);
    });
  }

  // Métodos CRUD para cada tabla

  // Médicos
  Future<List<Medico>> getAllMedicos() => select(medicos).get();
  Future<Medico?> getMedicoById(int id) =>
      (select(medicos)..where((m) => m.id.equals(id))).getSingleOrNull();
  Future<int> insertMedico(MedicosCompanion medico) =>
      into(medicos).insert(medico);
  Future<bool> updateMedico(Medico medico) =>
      update(medicos).replace(medico);

  // Pacientes
  Future<List<Paciente>> getAllPacientes() => select(pacientes).get();
  Future<Paciente?> getPacienteById(int id) =>
      (select(pacientes)..where((p) => p.id.equals(id))).getSingleOrNull();
  Future<int> insertPaciente(PacientesCompanion paciente) =>
      into(pacientes).insert(paciente);

  // Dispositivos
  Future<List<Dispositivo>> getDispositivosByPaciente(int pacienteId) =>
      (select(dispositivos)..where((d) => d.pacienteId.equals(pacienteId))).get();
  Future<int> insertDispositivo(DispositivosCompanion dispositivo) =>
      into(dispositivos).insert(dispositivo);

  // Métricas de Salud
  Future<List<MetricasSaludData>> getMetricasByPaciente(int pacienteId, {int? limit}) {
    final query = select(metricasSalud)
      ..where((m) => m.pacienteId.equals(pacienteId))
      ..orderBy([(m) => OrderingTerm.desc(m.ts)]);

    if (limit != null) {
      query.limit(limit);
    }

    return query.get();
  }

  Future<int> insertMetrica(MetricasSaludCompanion metrica) =>
      into(metricasSalud).insert(metrica);

// Stream reactivo para métricas en tiempo real
  Stream<List<MetricasSaludData>> watchMetricasByPaciente(int pacienteId) {
    return (select(metricasSalud)
      ..where((m) => m.pacienteId.equals(pacienteId))
      ..orderBy([(m) => OrderingTerm.desc(m.ts)]))
        .watch();
  }
}