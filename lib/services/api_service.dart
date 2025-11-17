import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base de tu API Node.js (usa 10.0.2.2 para emulador Android)
  static const String baseUrl = 'http://10.0.2.2:3000';

  // -------------------------------------------------------------
  // 1) Registrar datos de salud
  // -------------------------------------------------------------
  static Future<bool> sendHealthRegister(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/health-register');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (res.statusCode == 201) {
      print('✅ Health data sent: ${res.body}');
      return true;
    } else {
      print('❌ Error sending health data: ${res.body}');
      return false;
    }
  }

  // -------------------------------------------------------------
  // 2) Enviar feedback del doctor
  // -------------------------------------------------------------
  static Future<bool> sendDoctorFeedback(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/api/doctor-feedback');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (res.statusCode == 201) {
      print('✅ Feedback sent: ${res.body}');
      return true;
    } else {
      print('❌ Error sending feedback: ${res.body}');
      return false;
    }
  }
}
