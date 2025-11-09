// lib/services/database_service.dart
import 'package:flutter/material.dart';
import '../database/database.dart';

class DatabaseService extends ChangeNotifier {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  AppDatabase? _database;

  /// Obtiene la instancia de la base de datos
  /// Lanza una excepción si no está inicializada
  AppDatabase get database {
    if (_database == null) {
      throw Exception('Base de datos no inicializada. Llama a initialize() primero.');
    }
    return _database!;
  }

  /// Verifica si la base de datos está inicializada
  bool get isInitialized => _database != null;

  /// Inicializa la base de datos
  /// Solo se ejecuta una vez, llamadas subsecuentes son ignoradas
  Future<void> initialize() async {
    if (_database != null) return; // Ya está inicializada

    try {
      _database = AppDatabase();
      print('Base de datos inicializada correctamente');

      // OPCIONAL: Inicializar datos de ejemplo para habits
      await _initializeSampleHabits();
    } catch (e) {
      print('Error inicializando base de datos: $e');
      rethrow;
    }
  }

  /// Inicializa habitos de ejemplo si la tabla esta vacia

  Future<void> _initializeSampleHabits() async {
    try {
      final habits = await _database!.getTodaysHabits();

      if (habits.isEmpty) {
        print('Creando hábitos de ejemplo...');


        // 1. Estiramiento matutino (10 min - óptimo para flexibilidad)
        await _database!.insertHabit(HabitsCompanion.insert(
          title: 'Morning Stretches',
          durationMinutes: 10,
          iconName: 'self_improvement',
          colorHex: '#22D3A6',
        ));

        // 2. Fisioterapia/Ejercicio (20 min - sesión estándar)
        await _database!.insertHabit(HabitsCompanion.insert(
          title: 'Physical Therapy',
          durationMinutes: 20,
          iconName: 'medical_services',
          colorHex: '#F59E0B',
        ));

        // 3. Caminata nocturna (15 min - mínimo efectivo)
        await _database!.insertHabit(HabitsCompanion.insert(
          title: 'Evening Walk',
          durationMinutes: 15,
          iconName: 'directions_walk',
          colorHex: '#EF4444',
        ));

        // 4. Meditación/Respiración (5 min - manejo de estrés)
        await _database!.insertHabit(HabitsCompanion.insert(
          title: 'Meditation',
          durationMinutes: 5,
          iconName: 'spa',
          colorHex: '#8B5CF6',
        ));

        print('Hábitos de ejemplo creados');
      }
    } catch (e) {
      print('Error inicializando hábitos de ejemplo: $e');
    }
  }


  /// Verifica la salud/conectividad de la base de datos
  Future<bool> healthCheck() async {
    try {
      if (!isInitialized) {
        print('⚠Health check fallido: Base de datos no inicializada');
        return false;
      }

      // Hacer consultas simples para verificar conectividad
      await _database!.getAllDoctors(); // Cambiado de getAllMedicos a getAllDoctors
      await _database!.getTodaysHabits(); // Verificar tabla de hábitos también

      print('Health check exitoso');
      return true;
    } catch (e) {
      print('Health check fallido: $e');
      return false;
    }
  }

  /// Resetea todos los habitos al inicio del dia
  /// Este mtodo deberia llamarse a medianoche
  Future<void> resetDailyHabits() async {
    try {
      if (!isInitialized) return;

      await _database!.resetDailyHabits();
    } catch (e) {
      // Error al resetear hábitos
    }
  }

  /// Cierra la conexion a la base de datos
  @override
  void dispose() {
    _database?.close();
    _database = null;
    print('Base de datos cerrada');
    super.dispose();
  }

  /// OPCIONAL: Metodo para limpiar/resetear toda la base de datos
  /// Util para desarrollo y testing
  Future<void> clearAllData() async {
    try {
      if (!isInitialized) return;

      // Eliminar todos los hábitos
      final habits = await _database!.getTodaysHabits();
      for (final habit in habits) {
        await _database!.deleteHabit(habit.id);
      }

      print('🗑Todos los datos han sido eliminados');
    } catch (e) {
      print('Error limpiando datos: $e');
    }
  }

  /// OPCIONAL: Obtener estadísticas de uso
  Future<Map<String, dynamic>> getStats() async {
    try {
      if (!isInitialized) return {};

      final habits = await _database!.getTodaysHabits();
      final completed = habits.where((h) => h.completedToday).length;

      return {
        'totalHabits': habits.length,
        'completedHabits': completed,
        'completionRate': habits.isEmpty ? 0.0 : (completed / habits.length) * 100,
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }
}
