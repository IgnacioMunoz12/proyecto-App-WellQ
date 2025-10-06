import 'package:flutter/material.dart';
import '../database/database.dart';

class DatabaseService extends ChangeNotifier {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  AppDatabase? _database;
  AppDatabase get database {
    if (_database == null) {
      throw Exception('Base de datos no inicializada. Llama a initialize() primero.');
    }
    return _database!;
  }

  bool get isInitialized => _database != null;

  Future<void> initialize() async {
    if (_database != null) return; // Ya está inicializada

    try {
      _database = AppDatabase();
      print('Base de datos ta joya');
    } catch (e) {
      print('Error inicializando base de datos: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _database?.close();
    _database = null;
    super.dispose();
  }

  // Metodo para verificar la salud de la base de datos
  Future<bool> healthCheck() async {
    try {
      if (!isInitialized) return false;

      // Hacer una consulta simple para verificar conectividad
      await _database!.getAllMedicos();
      return true;
    } catch (e) {
      print('Health check: $e');
      return false;
    }
  }
}
