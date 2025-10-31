// lib/services/health_data_service.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:health/health.dart' as health;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import 'database_service.dart';
import 'dart:async'; // <- para Timer del polling

class HealthDataService extends ChangeNotifier {
  static final HealthDataService _instance = HealthDataService._internal();

  factory HealthDataService() => _instance;
  Timer? _hrPollingTimer;
  bool _registeredAsSource = false; // marcamos si ya escribimos algo como WellQ

  // NEW: bandera global para bloquear escrituras a Health Connect
  static const bool kWriteToHC = false;

  HealthDataService._internal();
  final health.Health _health = health.Health();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  double heartRateNow = 0;
  double heartRateMin24h = 0;
  double heartRateMax24h = 0;
  List<health.HealthDataPoint> heartRateSamples = [];
  double restingHeartRate = 0;

  AppDatabase? _database;

  // Estado
  bool isLoading = true;
  bool hasPermissions = false;
  DateTime? lastUpdate;
  bool usingMockData = false;
  int? currentPatientId;
  String? currentUserEmail;
  String? currentUserName;

  // Datos de salud actuales
  int steps = 0;
  int heartRate = 0;
  double weight = 0;
  double sleepHours = 0.0;
  double waterIntake = 0.0;
  int caloriesIntake = 0;

  // Objetivos
  static const int stepsGoal = 10000;
  static const double waterGoal = 2.0;
  static const double sleepGoal = 8.0;
  static const int caloriesGoal = 2000;

  // Mock data
  static const _mockData = {
    'steps': 0,
    'heartRate': 0,
    'weight': 0,
    'sleepHours': 0,
    'waterIntake': 0,
    'caloriesIntake': 0,
  };

  /// Inicializar el servicio con base de datos
  Future<void> initialize({int? patientId}) async {
    isLoading = true;
    notifyListeners();

    // Obtener base de datos
    _database = DatabaseService().database;

    // Obtener información del usuario de Firebase
    await _loadFirebaseUser();

    // Obtener o crear paciente
    currentPatientId = patientId ?? await _getOrCreatePatientFromFirebase();
    final isHC = await _health.isHealthConnectAvailable();
    debugPrint('🩺 Health Connect disponible: $isHC');

    // Cargar últimos datos de la BD
    await _loadLatestMetricsFromDB();

    // Verificar permisos
    await requestPermissions();

    // Mantener función pero neutralizar escritura según bandera
    if (hasPermissions && kWriteToHC) {
      await ensureWellQRegisteredInHC();
    }

    // Intentar obtener datos reales
    if (hasPermissions) {
      await fetchAllHealthData();
    }
    if (hasPermissions) {
      // Para ver HR “vivo” en tu Dashboard
      startHeartRatePolling(
        // NEW: si no queremos escribir, dejamos false
        writeEachTick: kWriteToHC,
      );
    }
    // Si no hay datos, usar mock
    if (_isDataEmpty()) {
      _loadMockData();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFirebaseUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        currentUserEmail = user.email;
        currentUserName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
        debugPrint('Firebase user loaded: $currentUserEmail');
      } else {
        debugPrint('⚠No Firebase user logged in');
        currentUserEmail = 'guest@wellq.com';
        currentUserName = 'Guest User';
      }
    } catch (e) {
      debugPrint('Error loading Firebase user: $e');
      currentUserEmail = 'guest@wellq.com';
      currentUserName = 'Guest User';
    }
  }

  /// Obtener o crear paciente desde Firebase Auth
  Future<int> _getOrCreatePatientFromFirebase() async {
    try {
      // Buscar paciente por email
      final patients = await _database!.getAllPatients();

      // Buscar paciente existente con el email actual
      final existingPatient =
          patients.where((p) => p.email.toLowerCase() == currentUserEmail?.toLowerCase()).firstOrNull;

      if (existingPatient != null) {
        debugPrint('Found existing patient: ${existingPatient.name} (ID: ${existingPatient.id})');
        return existingPatient.id;
      }

      // Si no existe, crear nuevo paciente con datos de Firebase
      final doctorId = await _getOrCreateDefaultDoctor();

      final patientId = await _database!.insertPatient(
        PatientsCompanion.insert(
          name: currentUserName ?? 'User',
          email: currentUserEmail ?? 'user@wellq.com',
          doctorId: doctorId,
          birthDate: drift.Value(DateTime.now().subtract(const Duration(days: 365 * 25))),
          // 25 años por defecto
          gender: const drift.Value(null),
          phone: const drift.Value(null),
        ),
      );

      debugPrint('Created new patient from Firebase: $currentUserName (ID: $patientId)');
      return patientId;
    } catch (e) {
      debugPrint('Error getting/creating patient from Firebase: $e');
      return 1; // Fallback
    }
  }

  /// Obtener o crear doctor por defecto
  Future<int> _getOrCreateDefaultDoctor() async {
    try {
      final doctors = await _database!.getAllDoctors();

      if (doctors.isEmpty) {
        final doctorId = await _database!.insertDoctor(
          DoctorsCompanion.insert(
            name: 'Dr. Sarah Williams',
            email: 'dr.williams@wellq.com',
            specialty: const drift.Value('General Practitioner'),
            phone: const drift.Value('+56912345678'),
          ),
        );
        debugPrint('Created default doctor (ID: $doctorId)');
        return doctorId;
      } else {
        return doctors.first.id;
      }
    } catch (e) {
      debugPrint('Error getting/creating doctor: $e');
      return 1; // Fallback
    }
  }

  /// Obtener o crear paciente por defecto
  Future<int> _getOrCreateDefaultPatient() async {
    try {
      final patients = await _database!.getAllPatients();

      if (patients.isEmpty) {
        // Crear paciente de prueba
        final patientId = await _database!.insertPatient(
          PatientsCompanion.insert(
            name: 'Default User',
            email: 'user@wellq.com',
            doctorId: 1, // Asume que hay un doctor con ID 1
          ),
        );
        debugPrint('Created default patient with ID: $patientId');
        return patientId;
      } else {
        return patients.first.id;
      }
    } catch (e) {
      debugPrint('Error getting/creating patient: $e');
      return 1; // Fallback a ID 1
    }
  }

  /// Cargar últimas métricas desde la base de datos
  Future<void> _loadLatestMetricsFromDB() async {
    if (_database == null || currentPatientId == null) return;

    final latestHR = await getLatestHeartRate();
    if (latestHR != null) {
      heartRateNow = latestHR;
      // NEW: implementamos _saveMetricToDB (faltaba en tu código original)
      await _saveMetricToDB('heart_rate', latestHR, 'bpm');
      notifyListeners();
    } else {
      debugPrint('No se encontró frecuencia cardíaca reciente');
    }
    try {
      final metrics = await _database!.getMetricsByPatient(
        currentPatientId!,
        limit: 10,
      );

      if (metrics.isEmpty) {
        debugPrint('No previous metrics found in database');
        return;
      }

      // Cargar las métricas más recientes de cada tipo
      for (final metric in metrics) {
        switch (metric.metricType) {
          case 'steps':
            steps = metric.value.toInt();
            break;
          case 'heart_rate':
            heartRate = metric.value.toInt();
            break;
          case 'weight':
            weight = metric.value;
            break;
          case 'sleep':
            sleepHours = metric.value;
            break;
          case 'water':
            waterIntake = metric.value;
            break;
          case 'calories':
            caloriesIntake = metric.value.toInt();
            break;
        }
      }

      debugPrint('Loaded latest metrics from database');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading metrics from DB: $e');
    }
  }

  // NEW: helper genérico para guardar 1 métrica puntual
  Future<void> _saveMetricToDB(String metricType, double value, String unit) async {
    if (_database == null || currentPatientId == null) return;
    try {
      await _database!.insertMetric(
        HealthMetricsCompanion.insert(
          patientId: currentPatientId!,
          metricType: metricType,
          value: value,
          unit: unit,
          timestamp: drift.Value(DateTime.now()),
          source: drift.Value(usingMockData ? 'mock' : 'health_connect'),
        ),
      );
    } catch (e) {
      debugPrint('Error in _saveMetricToDB($metricType): $e');
    }
  }

  /// Guardar métricas en la base de datos
  Future<void> _saveMetricsToDB() async {
    if (_database == null || currentPatientId == null) return;

    try {
      final now = DateTime.now();

      // Guardar cada métrica
      await _database!.insertMetric(
        HealthMetricsCompanion.insert(
          patientId: currentPatientId!,
          metricType: 'steps',
          value: steps.toDouble(),
          unit: 'steps',
          timestamp: drift.Value(now),
          source: drift.Value(usingMockData ? 'mock' : 'health_connect'),
        ),
      );

      if (heartRate > 0) {
        await _database!.insertMetric(
          HealthMetricsCompanion.insert(
            patientId: currentPatientId!,
            metricType: 'heart_rate',
            value: heartRate.toDouble(),
            unit: 'bpm',
            timestamp: drift.Value(now),
            source: drift.Value(usingMockData ? 'mock' : 'health_connect'),
          ),
        );
      }

      if (weight > 0) {
        await _database!.insertMetric(
          HealthMetricsCompanion.insert(
            patientId: currentPatientId!,
            metricType: 'weight',
            value: weight,
            unit: 'kg',
            timestamp: drift.Value(now),
            source: drift.Value(usingMockData ? 'mock' : 'health_connect'),
          ),
        );
      }

      if (sleepHours > 0) {
        await _database!.insertMetric(
          HealthMetricsCompanion.insert(
            patientId: currentPatientId!,
            metricType: 'sleep',
            value: sleepHours,
            unit: 'hours',
            timestamp: drift.Value(now),
            source: drift.Value(usingMockData ? 'mock' : 'health_connect'),
          ),
        );
      }

      if (waterIntake > 0) {
        await _database!.insertMetric(
          HealthMetricsCompanion.insert(
            patientId: currentPatientId!,
            metricType: 'water',
            value: waterIntake,
            unit: 'liters',
            timestamp: drift.Value(now),
            source: drift.Value(usingMockData ? 'mock' : 'health_connect'),
          ),
        );
      }

      if (caloriesIntake > 0) {
        await _database!.insertMetric(
          HealthMetricsCompanion.insert(
            patientId: currentPatientId!,
            metricType: 'calories',
            value: caloriesIntake.toDouble(),
            unit: 'kcal',
            timestamp: drift.Value(now),
            source: drift.Value(usingMockData ? 'mock' : 'health_connect'),
          ),
        );
      }

      debugPrint('Health metrics saved to database');
    } catch (e) {
      debugPrint('Error saving metrics to DB: $e');
    }
  }

  /// Solicitar permisos de Health Connect
  Future<bool> requestPermissions() async {
    final types = [
      health.HealthDataType.STEPS,
      health.HealthDataType.DISTANCE_DELTA,
      health.HealthDataType.ACTIVE_ENERGY_BURNED,
      health.HealthDataType.SPEED,
      health.HealthDataType.HEART_RATE,
      health.HealthDataType.RESTING_HEART_RATE,
      health.HealthDataType.WATER,
      health.HealthDataType.SLEEP_ASLEEP,
      health.HealthDataType.SLEEP_LIGHT,
      health.HealthDataType.SLEEP_DEEP,
      health.HealthDataType.SLEEP_REM,
      health.HealthDataType.SLEEP_AWAKE,
      health.HealthDataType.SLEEP_IN_BED,
      // 👇 añadido para poder leer/escribir peso
      health.HealthDataType.WEIGHT,
    ];

    try {
      final permissions = List.generate(
        types.length,
            (index) => health.HealthDataAccess.READ_WRITE,
      );

      final granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      hasPermissions = granted ?? false;
      debugPrint('Health permissions granted: $hasPermissions');

      // WORKAROUND: Si falla en emulador, verificar manualmente
      if (!hasPermissions) {
        debugPrint('Permission launcher failed, checking manually...');

        // Intentar leer datos para verificar si tiene permisos
        try {
          final now = DateTime.now();
          await _health.getHealthDataFromTypes(
            types: [health.HealthDataType.STEPS],
            startTime: now.subtract(const Duration(hours: 1)),
            endTime: now,
          );

          // Si puede leer, tiene permisos
          hasPermissions = true;
          debugPrint('Permisos verificados manualmente');
        } catch (e) {
          debugPrint('No puede leer datos: $e');
          hasPermissions = false;
        }
      }

      notifyListeners();
      return hasPermissions;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');

      try {
        final now = DateTime.now();
        await _health.getHealthDataFromTypes(
          types: [health.HealthDataType.STEPS],
          startTime: now.subtract(const Duration(hours: 1)),
          endTime: now,
        );

        hasPermissions = true;
        debugPrint('Permisos verificados mediante lectura');
      } catch (e2) {
        hasPermissions = false;
        debugPrint('No hay permisos: $e2');
      }

      notifyListeners();
      return hasPermissions;
    }
  }

  /// Obtener todos los datos de salud
  Future<void> fetchAllHealthData() async {
    if (!hasPermissions) {
      debugPrint('No health permissions, loading from database');
      await _loadLatestMetricsFromDB();
      return;
    }

    isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    // Ventana “noche”: desde las 18:00 del día anterior hasta ahora
    final nightStart = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(hours: 6)); // 18:00 del día anterior

    try {
      // Fetch en paralelo
      await Future.wait([
        _fetchSteps(midnight, now),
        _fetchHeartRate(midnight, now),
        _fetchWeight(now),
        _fetchSleep(nightStart, now), // ⬅️ cambio aquí
        _fetchWater(midnight, now),
        _fetchNutrition(midnight, now),
      ]);

      // Si todos los datos son 0, cargar desde BD o usar mock
      if (_isDataEmpty()) {
        debugPrint('No health data found, loading from database');
        await _loadLatestMetricsFromDB();

        if (_isDataEmpty()) {
          _loadMockData();
        }
      } else {
        // Guardar en base de datos
        await _saveMetricsToDB();
        usingMockData = false;
      }

      lastUpdate = DateTime.now();
    } catch (e) {
      debugPrint('Error fetching health data: $e');
      await _loadLatestMetricsFromDB();

      if (_isDataEmpty()) {
        _loadMockData();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSteps(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [health.HealthDataType.STEPS],
        startTime: start,
        endTime: end,
      );

      int totalSteps = 0;
      for (final point in data) {
        if (point.value is health.NumericHealthValue) {
          totalSteps += (point.value as health.NumericHealthValue).numericValue.toInt();
        }
      }
      steps = totalSteps;

      // NOTE: antes sumabas pasos a caloriesIntake, lo quité porque distorsiona calorías
      debugPrint('Steps loaded (HC total): $steps');
    } catch (e) {
      debugPrint('Error fetching steps: $e');
    }
  }

  Future<double?> getLatestHeartRate() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));

      // ✅ API nueva: parámetros nombrados
      final heartRateData = await _health.getHealthDataFromTypes(
        types: [health.HealthDataType.HEART_RATE],
        startTime: yesterday,
        endTime: now,
      );

      if (heartRateData.isEmpty) {
        debugPrint('⚠️ No se encontraron datos de frecuencia cardíaca en Health Connect');
        return null;
      }

      heartRateData.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
      final latest = heartRateData.first;

      debugPrint('❤️ Última FC registrada: ${latest.value} ${latest.unit} (${latest.dateFrom})');

      // Maneja NumericHealthValue u otros tipos
      final v = _asDouble(latest.value);
      return v;
    } catch (e) {
      debugPrint('⚠️ Error leyendo frecuencia cardíaca: $e');
      return null;
    }
  }

  // Refrescar frecuencia cardíaca del “día”
  Future<void> _fetchHeartRate(DateTime start, DateTime end) async {
    try {
      var data = await _health.getHealthDataFromTypes(
        types: [health.HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );

      if (data.isNotEmpty) {
        final lastVal = data.last.value;
        if (lastVal is health.NumericHealthValue) {
          heartRate = lastVal.numericValue.toInt();
        } else {
          heartRate = _asDouble(lastVal)?.round() ?? 0;
        }
      } else {
        heartRate = 0;
      }

      // Además, actualizar ventana de 24h para now/min/max/reposo
      await fetchHeartRate(window: const Duration(hours: 24));
    } catch (e) {
      debugPrint('Error fetching heart rate: $e');
    }
  }

  // Usar parámetros nombrados para compatibilidad
  Future<void> fetchHeartRate({Duration window = const Duration(hours: 24)}) async {
    final end = DateTime.now();
    final start = end.subtract(window);

    var points = await _health.getHealthDataFromTypes(
      types: [health.HealthDataType.HEART_RATE],
      startTime: start,
      endTime: end,
    );

    points = _dedup(points);
    points = _filterOutSentinelHR(points);
    heartRateSamples = points..sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

    if (heartRateSamples.isNotEmpty) {
      final lastBpm = _asDouble(heartRateSamples.last.value);
      heartRateNow = lastBpm ?? 0;

      final vals = heartRateSamples.map((e) => _asDouble(e.value)).whereType<double>().toList();

      if (vals.isNotEmpty) {
        heartRateMin24h = vals.reduce((a, b) => math.min(a, b));
        heartRateMax24h = vals.reduce((a, b) => math.max(a, b));
      } else {
        heartRateMin24h = 0;
        heartRateMax24h = 0;
      }
    } else {
      heartRateNow = 0;
      heartRateMin24h = 0;
      heartRateMax24h = 0;
    }

    var resting = await _health.getHealthDataFromTypes(
      types: [health.HealthDataType.RESTING_HEART_RATE],
      startTime: start,
      endTime: end,
    );
    resting = _dedup(resting);
    restingHeartRate = resting.isNotEmpty ? (_asDouble(resting.last.value) ?? 0) : 0;
  }


  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse('$v');
  }

  List<health.HealthDataPoint> _dedup(List<health.HealthDataPoint> points) {
    final seen = <String>{};
    final out = <health.HealthDataPoint>[];
    for (final p in points) {
      final key =
          '${p.typeString}-${p.dateFrom.millisecondsSinceEpoch}-${p.dateTo.millisecondsSinceEpoch}-${p.value}';
      if (seen.add(key)) out.add(p);
    }
    return out;
  }

  Future<void> _fetchWeight(DateTime now) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [health.HealthDataType.WEIGHT],
        startTime: now.subtract(const Duration(days: 30)),
        endTime: now,
      );

      if (data.isNotEmpty) {
        final lastWeightData = data.last.value;

        if (lastWeightData is health.NumericHealthValue) {
          weight = lastWeightData.numericValue.toDouble();
          debugPrint('Weight loaded: $weight kg');
        } else {
          debugPrint('Weight value type: ${lastWeightData.runtimeType}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching weight: $e');
    }
  }

  Future<void> _fetchSleep(DateTime start, DateTime end) async {
    // Muchas apps registran el sueño "entre días". Para capturar la última noche,
    // conviene usar una ventana amplia. Respetamos [start, end] que le pasas,
    // pero si no hay datos, ampliamos a 36h.
    Future<double> _readSleepMinutes(DateTime s, DateTime e) async {
      // Leemos por tipo para evitar fallos si alguna variante no está soportada
      final asleepTypes = <health.HealthDataType>[
        health.HealthDataType.SLEEP_ASLEEP,
        health.HealthDataType.SLEEP_LIGHT,
        health.HealthDataType.SLEEP_DEEP,
        health.HealthDataType.SLEEP_REM,
      ];

      double minutes = 0;

      for (final t in asleepTypes) {
        try {
          final pts = await _health.getHealthDataFromTypes(
            types: [t],
            startTime: s,
            endTime: e,
          );

          for (final p in pts) {
            // Algunas integraciones guardan "minutos" en el value,
            // otras sólo el intervalo. Cubrimos ambos casos.
            final v = p.value;
            if (v is health.NumericHealthValue) {
              minutes += v.numericValue.toDouble();
            } else {
              minutes += p.dateTo.difference(p.dateFrom).inMinutes.toDouble();
            }
          }
        } catch (_) {
          // Si un tipo no está soportado en el dispositivo/fuente, lo ignoramos
        }
      }

      return minutes;
    }

    try {
      // 1) Intento con la ventana que ya usas (p.ej. de medianoche a ahora)
      double asleepMin = await _readSleepMinutes(start, end);

      // 2) Si no hubo datos, ampliamos ventana para capturar noche anterior completa
      if (asleepMin == 0) {
        final now = DateTime.now();
        final wideStart = now.subtract(const Duration(hours: 36));
        final wideEnd = now;
        asleepMin = await _readSleepMinutes(wideStart, wideEnd);
      }

      sleepHours = (asleepMin / 60.0);
      debugPrint('Sleep loaded (sum stages): ${sleepHours.toStringAsFixed(2)} h');
    } catch (e) {
      debugPrint('Error fetching sleep: $e');
    }
  }

  Future<void> _fetchWater(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [health.HealthDataType.WATER],
        startTime: start,
        endTime: end,
      );

      waterIntake = 0;
      for (final point in data) {
        if (point.value is health.NumericHealthValue) {
          waterIntake +=
              (point.value as health.NumericHealthValue).numericValue.toDouble();
        }
      }
      debugPrint('Water loaded: $waterIntake L');
    } catch (e) {
      debugPrint('Error fetching water: $e');
    }
  }

  Future<void> _fetchNutrition(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [health.HealthDataType.NUTRITION],
        startTime: start,
        endTime: end,
      );

      caloriesIntake = 0;
      for (final point in data) {
        if (point.value is health.NumericHealthValue) {
          caloriesIntake +=
              (point.value as health.NumericHealthValue).numericValue.toInt();
        }
      }
      debugPrint('Nutrition loaded: $caloriesIntake kcal');
    } catch (e) {
      debugPrint('Error fetching nutrition: $e');
    }
  }

  /// NUEVO: actualizar peso (UI + BD + opcional Health Connect)
  Future<void> updateWeight(double kg, {bool writeToHealthConnect = false}) async {
    weight = kg;
    lastUpdate = DateTime.now();
    notifyListeners();

    // Guarda inmediato en BD
    await _saveMetricToDB('weight', kg, 'kg');

    // Opcional: escribir en Health Connect (si bandera global y usuario lo pidió)
    if (hasPermissions && kWriteToHC && writeToHealthConnect) {
      try {
        final now = DateTime.now();
        await _health.writeHealthData(
          value: kg,
          type: health.HealthDataType.WEIGHT,
          startTime: now.subtract(const Duration(minutes: 1)),
          endTime: now,
        );
        debugPrint('✔ Peso escrito en Health Connect: ${kg.toStringAsFixed(1)} kg');
      } catch (e) {
        debugPrint('⚠️ Error escribiendo peso en Health Connect: $e');
      }
    }
  }

  /// Obtener historial de métricas
  Future<List<HealthMetric>> getMetricHistory(String metricType, {int days = 7}) async {
    if (_database == null || currentPatientId == null) return [];

    try {
      final allMetrics = await _database!.getMetricsByPatient(currentPatientId!);

      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: days));

      return allMetrics
          .where((m) => m.metricType == metricType && m.timestamp.isAfter(cutoffDate))
          .toList();
    } catch (e) {
      debugPrint('Error getting metric history: $e');
      return [];
    }
  }

  /// Obtener estadísticas de una métrica
  Future<Map<String, double>> getMetricStats(String metricType, {int days = 7}) async {
    final history = await getMetricHistory(metricType, days: days);

    if (history.isEmpty) {
      return {'min': 0, 'max': 0, 'avg': 0};
    }

    final values = history.map((m) => m.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final avg = values.reduce((a, b) => a + b) / values.length;

    return {'min': min, 'max': max, 'avg': avg};
  }

  bool _isDataEmpty() {
    return steps == 0 &&
        heartRate == 0 &&
        weight == 0 &&
        sleepHours == 0 &&
        waterIntake == 0 &&
        caloriesIntake == 0;
  }

  void _loadMockData() {
    steps = _mockData['steps'] as int;
    heartRate = _mockData['heartRate'] as int;
    weight = _mockData['weight'] as double;
    sleepHours = _mockData['sleepHours'] as double;
    waterIntake = _mockData['waterIntake'] as double;
    caloriesIntake = _mockData['caloriesIntake'] as int;
    usingMockData = true;
    debugPrint('📊 Using mock data');
    notifyListeners();
  }

  bool needsRefresh() {
    if (lastUpdate == null) return true;
    return DateTime.now().difference(lastUpdate!) > const Duration(minutes: 5);
  }

  // Getters de progreso
  double get stepsProgress => (steps / stepsGoal).clamp(0.0, 1.0);
  double get waterProgress => (waterIntake / waterGoal).clamp(0.0, 1.0);
  double get sleepProgress => (sleepHours / sleepGoal).clamp(0.0, 1.0);
  double get caloriesProgress => (caloriesIntake / caloriesGoal).clamp(0.0, 1.0);

  bool get isHealthy {
    return heartRate >= 60 && heartRate <= 100 && sleepHours >= 6.0 && steps >= stepsGoal * 0.7;
  }

  String getMotivationalMessage() {
    if (stepsProgress >= 1.0) {
      return 'Amazing! You hit your steps goal!';
    } else if (stepsProgress >= 0.7) {
      return 'Almost there! Keep it up!';
    } else if (stepsProgress >= 0.5) {
      return 'Good progress! You\'re halfway!';
    } else {
      return 'Let\'s get moving today!';
    }
  }

  void reset() {
    steps = 0;
    heartRate = 0;
    weight = 0;
    sleepHours = 0;
    waterIntake = 0;
    caloriesIntake = 0;
    lastUpdate = null;
    usingMockData = false;
    notifyListeners();
  }

  /// ====================================================
  /// SECCION PARA CARGAR DATOS FICTICIOS A HEALTH CONNECT
  /// ====================================================
  Future<void> insertTestHealthData() async {
    if (!kWriteToHC) {
      debugPrint('insertTestHealthData(): escritura deshabilitada (kWriteToHC=false).');
      return;
    }
    if (!hasPermissions) {
      debugPrint('Solicitando permisos...');
      await requestPermissions();
      if (!hasPermissions) {
        debugPrint('No se pudieron obtener permisos');
        return;
      }
    }

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final random = math.Random();

      debugPrint('Insertando datos de prueba en Health Connect...');
      debugPrint('Hora actual: $now');

      final dataDay = today;
      final currentHour = now.hour;

      final startHour = currentHour < 8 ? 0 : 8;
      final endHour = currentHour < 8 ? currentHour : (currentHour > 20 ? 20 : currentHour);

      debugPrint('Insertando datos de HOY desde las $startHour:00 hasta las $endHour:00');

      // 1. Pasos realistas...
      int totalSteps = 0;
      if (endHour > startHour) {
        for (int i = 0; i < (endHour - startHour); i++) {
          final startTime = dataDay.add(Duration(hours: startHour + i));
          final endTime = startTime.add(const Duration(hours: 1));

          final hour = startHour + i;
          int baseSteps;

          if (hour >= 8 && hour <= 12) {
            baseSteps = 800 + random.nextInt(500);
          } else if (hour >= 17 && hour <= 20) {
            baseSteps = 700 + random.nextInt(600);
          } else if (hour >= 13 && hour <= 16) {
            baseSteps = 400 + random.nextInt(400);
          } else {
            baseSteps = 200 + random.nextInt(400);
          }

          await _health.writeHealthData(
            value: baseSteps.toDouble(),
            type: health.HealthDataType.STEPS,
            startTime: startTime,
            endTime: endTime,
          );

          totalSteps += baseSteps;
        }
        debugPrint('Pasos insertados: $totalSteps pasos');
      } else {
        debugPrint('Demasiado temprano para insertar pasos');
      }

      // 2. Frecuencia cardíaca realista...
      if (currentHour >= 0) {
        final measurements = <Map<String, dynamic>>[];

        measurements.add({'hour': currentHour > 0 ? currentHour - 1 : 0, 'bpm': 65 + random.nextInt(50)});

        if (currentHour >= 7) {
          measurements.add({'hour': 7, 'bpm': 60 + random.nextInt(8)});
        }
        if (currentHour >= 10) {
          measurements.add({'hour': 10, 'bpm': 70 + random.nextInt(10)});
        }
        if (currentHour >= 14) {
          measurements.add({'hour': 14, 'bpm': 68 + random.nextInt(8)});
        }
        if (currentHour >= 17) {
          measurements.add({'hour': 17, 'bpm': 85 + random.nextInt(10)});
        }
        if (currentHour >= 20) {
          measurements.add({'hour': 20, 'bpm': 65 + random.nextInt(8)});
        }

        for (final measurement in measurements) {
          final measureTime = dataDay.add(Duration(hours: measurement['hour']));
          if (measureTime.isBefore(now)) {
            await _health.writeHealthData(
              value: measurement['bpm'].toDouble(),
              type: health.HealthDataType.HEART_RATE,
              startTime: measureTime,
              endTime: measureTime.add(const Duration(minutes: 1)),
            );
          }
        }

        debugPrint('Frecuencia cardíaca insertada: ${measurements.length} mediciones');
      }

      // 3. Peso realista...
      final baseWeight = 70.0 + (random.nextDouble() * 1.0 - 0.5);
      final weightTime = dataDay.add(Duration(hours: 7));

      if (weightTime.isBefore(now)) {
        await _health.writeHealthData(
          value: double.parse(baseWeight.toStringAsFixed(1)),
          type: health.HealthDataType.WEIGHT,
          startTime: weightTime,
          endTime: weightTime.add(const Duration(minutes: 1)),
        );
        debugPrint('Peso insertado: ${baseWeight.toStringAsFixed(1)} kg');
      }

      // 4. Sueño realista...
      final sleepDurationHours = 6.5 + (random.nextDouble() * 2);
      final sleepMinutes = (sleepDurationHours * 60).round();

      final bedtimeHour = 22 + random.nextInt(3);
      final bedtimeMinute = random.nextInt(60);

      final sleepStart = today
          .subtract(Duration(days: bedtimeHour >= 24 ? 0 : 1))
          .add(Duration(hours: bedtimeHour % 24, minutes: bedtimeMinute));

      final sleepEnd = sleepStart.add(Duration(minutes: sleepMinutes));

      if (sleepEnd.isBefore(now)) {
        await _health.writeHealthData(
          value: 1.0,
          type: health.HealthDataType.SLEEP_ASLEEP,
          startTime: sleepStart,
          endTime: sleepEnd,
        );
        debugPrint(
            'Sueño insertado: ${sleepDurationHours.toStringAsFixed(1)} horas (${bedtimeHour % 24}:${bedtimeMinute.toString().padLeft(2, '0')} - ${sleepEnd.hour}:${sleepEnd.minute.toString().padLeft(2, '0')})');
      }

      // 5. Agua...
      int waterCount = 0;
      double totalWater = 0;
      final drinkTimes = [8, 10, 12, 15, 17, 19, 21];

      for (final hour in drinkTimes) {
        if (hour >= currentHour) break;

        final drinkTime = dataDay.add(Duration(hours: hour));
        if (drinkTime.isBefore(now)) {
          final amount = (200 + random.nextInt(201)) / 1000;
          await _health.writeHealthData(
            value: amount,
            type: health.HealthDataType.WATER,
            startTime: drinkTime,
            endTime: drinkTime.add(const Duration(minutes: 1)),
          );

          waterCount++;
          totalWater += amount;
        }
      }

      if (waterCount > 0) {
        debugPrint('Agua insertada: ${totalWater.toStringAsFixed(2)} litros en $waterCount ingestas');
      }

      // 6. Calorías (solo log)
      final meals = [
        {'hour': 8, 'name': 'Desayuno', 'calories': 350 + random.nextInt(200)},
        {'hour': 13, 'name': 'Almuerzo', 'calories': 550 + random.nextInt(250)},
        {'hour': 16, 'name': 'Snack', 'calories': 150 + random.nextInt(150)},
        {'hour': 20, 'name': 'Cena', 'calories': 450 + random.nextInt(250)},
      ];

      int totalCalories = 0;
      int mealsEaten = 0;

      for (final meal in meals) {
        final mealHour = meal['hour'] as int;
        if (mealHour >= currentHour) continue;

        final mealTime = dataDay.add(Duration(hours: mealHour));
        if (mealTime.isBefore(now)) {
          totalCalories += meal['calories'] as int;
          mealsEaten++;
          debugPrint('${meal['name']}: ${meal['calories']} kcal');
        }
      }

      if (mealsEaten > 0) {
        debugPrint('Total calorías: $totalCalories kcal ($mealsEaten comidas)');
      }

      debugPrint('Datos de HOY insertados exitosamente');

      // Recargar datos
      await fetchAllHealthData();
    } catch (e) {
      debugPrint('Error insertando datos de prueba: $e');
    }
  }

  /// Limpiar todos los datos de prueba
  Future<void> clearTestHealthData() async {
    if (!kWriteToHC) {
      debugPrint('clearRecentSentinelHeartRates(): escritura deshabilitada (kWriteToHC=false).');
      return;
    }
    if (!hasPermissions) {
      debugPrint('No hay permisos para limpiar datos');
      return;
    }

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      debugPrint('Limpiando datos de prueba...');

      final types = [
        health.HealthDataType.STEPS,
        health.HealthDataType.HEART_RATE,
        health.HealthDataType.WEIGHT,
        health.HealthDataType.SLEEP_ASLEEP,
        health.HealthDataType.WATER,
        health.HealthDataType.NUTRITION,
      ];

      for (final type in types) {
        try {
          await _health.delete(
            type: type,
            startTime: today.subtract(const Duration(days: 7)),
            endTime: now.add(const Duration(days: 1)),
          );
          debugPrint('Eliminados: ${type.name}');
        } catch (e) {
          debugPrint('Error eliminando ${type.name}: $e');
        }
      }

      debugPrint('Datos limpiados');

      steps = 0;
      heartRate = 0;
      weight = 0;
      sleepHours = 0;
      waterIntake = 0;
      caloriesIntake = 0;

      notifyListeners();

      await fetchAllHealthData();
    } catch (e) {
      debugPrint('Error limpiando datos: $e');
    }
  }

  /// Guarda una medición de FC (bpm) como WellQ (tu fuente)
  Future<void> writeOwnHeartRateSample(double bpm, DateTime when) async {
    if (!kWriteToHC) {
      debugPrint('writeOwnHeartRateSample(): escritura deshabilitada (kWriteToHC=false).');
      return;
    }
    if (!hasPermissions) return;
    try {
      await _health.writeHealthData(
        value: bpm,
        type: health.HealthDataType.HEART_RATE,
        startTime: when,
        endTime: when.add(const Duration(seconds: 10)),
      );
      _registeredAsSource = true;
      debugPrint('✔ HR escrito por WellQ: ${bpm.toStringAsFixed(0)} bpm');
    } catch (e) {
      debugPrint('Error al escribir HR: $e');
    }
  }

  /// Comienza un polling cada [interval] (por defecto 15s) para traer la última FC
  /// y opcionalmente escribirla en Health Connect en cada tick.
  void startHeartRatePolling({
    Duration interval = const Duration(seconds: 15),
    bool writeEachTick = false, // NEW: por defecto no escribir
  }) {
    if (!hasPermissions) {
      debugPrint('No permissions: HR polling not started');
      return;
    }

    _hrPollingTimer?.cancel();

    Future<void> _tick() async {
      final end = DateTime.now();
      final start = end.subtract(const Duration(minutes: 2));
      try {
        var points = await _health.getHealthDataFromTypes(
          types: [health.HealthDataType.HEART_RATE],
          startTime: start,
          endTime: end,
        );
        points = _filterOutSentinelHR(points);
        if (points.isNotEmpty) {
          final last = points.last.value;
          final v = _asDouble(last) ?? 0;
          heartRateNow = v;
          heartRate = v.round();
          lastUpdate = DateTime.now();

          // Mantén tracking simple para min/max en la ventana
          if (heartRateMin24h == 0 || v < heartRateMin24h) heartRateMin24h = v;
          if (v > heartRateMax24h) heartRateMax24h = v;

          // Escribir muestra propia si está habilitado y permitido por bandera
          if (writeEachTick && kWriteToHC && v > 0) {
            await writeOwnHeartRateSample(v, DateTime.now());
          }

          notifyListeners();
        }
      } catch (e) {
        debugPrint('Polling HR error: $e');
      }
    }

    // Primer tick inmediato para que se vea al tiro
    _tick();
    _hrPollingTimer = Timer.periodic(interval, (_) => _tick());
    debugPrint('⏱ HR polling iniciado (interval: ${interval.inSeconds}s, write: $writeEachTick).');
  }

  Future<void> clearRecentSentinelHeartRates({Duration lookback = const Duration(days: 3)}) async {
    if (!kWriteToHC) {
      debugPrint('clearRecentSentinelHeartRates(): escritura deshabilitada (kWriteToHC=false).');
      return;
    }
    if (!hasPermissions) return;
    try {
      final end = DateTime.now();
      final start = end.subtract(lookback);
      await _health.delete(
        type: health.HealthDataType.HEART_RATE,
        startTime: start,
        endTime: end,
      );
      debugPrint('HR recientes borrados (posibles 72 sentinela).');
      await fetchAllHealthData();
    } catch (e) {
      debugPrint('Error limpiando HR: $e');
    }
  }

  /// Detiene el polling
  void stopHeartRatePolling() {
    _hrPollingTimer?.cancel();
    _hrPollingTimer = null;
    debugPrint('⏹ HR polling detenido.');
  }

  /// Escribe un punto "inofensivo" para registrar a WellQ como fuente en Health Connect.
  /// Si ya escribimos hoy, no repite.
  Future<void> ensureWellQRegisteredInHC() async {
    if (!kWriteToHC) {
      debugPrint('ensureWellQRegisteredInHC(): escritura deshabilitada (kWriteToHC=false).');
      return;
    }
    if (!hasPermissions) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = 'wellq_registered_source_date';
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      // Evita repetir escritura el mismo día
      final last = prefs.getString(todayKey);
      if (last == todayStr) {
        _registeredAsSource = true;
        return;
      }

      final now = DateTime.now();

      // Escribimos un valor mínimo en cada tipo de dato para registrar WellQ como fuente
      final List<Map<String, dynamic>> metrics = [
        {'type': health.HealthDataType.STEPS, 'value': 1.0},
        {'type': health.HealthDataType.DISTANCE_DELTA, 'value': 0.01}, // en metros
        {'type': health.HealthDataType.ACTIVE_ENERGY_BURNED, 'value': 0.1}, // en kcal
        {'type': health.HealthDataType.SPEED, 'value': 0.01}, // m/s
        {'type': health.HealthDataType.HEART_RATE, 'value': 60.0}, // bpm
        {'type': health.HealthDataType.WATER, 'value': 0.01}, // litros
      ];

      for (var m in metrics) {
        await _health.writeHealthData(
          value: m['value'],
          type: m['type'],
          startTime: now.subtract(const Duration(minutes: 1)),
          endTime: now,
        );
      }

      _registeredAsSource = true;
      await prefs.setString(todayKey, todayStr);

      debugPrint('✅ WellQ registrado como fuente completa en Health Connect');
    } catch (e) {
      debugPrint('⚠ Error al registrar WellQ como fuente completa: $e');
    }
  }

  static final Set<double> _sentinelHrCandidates = {72.0};

  bool _isLikelySentinelHR(health.HealthDataPoint p) {
    // Si el valor es exactamente un candidato y el intervalo es muy corto, lo tratamos como sentinela
    final v = _asDouble(p.value);
    if (v == null) return false;
    final dur = p.dateTo.difference(p.dateFrom).abs();
    return _sentinelHrCandidates.contains(v) && dur.inMinutes <= 2;
  }

  List<health.HealthDataPoint> _filterOutSentinelHR(List<health.HealthDataPoint> points) {
    return points.where((p) => !_isLikelySentinelHR(p)).toList();
  }

  Future<void> forceSaveMetrics() async {
    debugPrint('FORCE SAVE - Current values:');
    debugPrint('   patientId: $currentPatientId');
    debugPrint('   database: ${_database != null ? "Connected" : "NULL"}');
    debugPrint('   steps: $steps');
    debugPrint('   heartRate: $heartRate');
    debugPrint('   weight: $weight');
    debugPrint('   sleepHours: $sleepHours');
    debugPrint('   waterIntake: $waterIntake');
    debugPrint('   caloriesIntake: $caloriesIntake');

    await _saveMetricsToDB();

    if (_database != null && currentPatientId != null) {
      final metrics = await _database!.getMetricsByPatient(currentPatientId!);
      debugPrint('Metrics in DB: ${metrics.length} records');
      for (final metric in metrics) {
        debugPrint('   - ${metric.metricType}: ${metric.value} ${metric.unit}');
      }
    }
  }
}




