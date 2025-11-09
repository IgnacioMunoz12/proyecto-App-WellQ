import 'dart:async';
import 'package:flutter/services.dart';

class NativeNotifyBridge {
  static const MethodChannel _ch = MethodChannel('wellq/native_notify');

  static Future<void> ensureHighImportanceChannel({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      await _ch.invokeMethod('ensureHighImportanceChannel', {
        'id': id,
        'name': name,
        'description': description,
      });
    } on PlatformException {
      // no romper UI
    }
  }

  static Future<void> showTestNow({
    required String id,
    String? title,
    String? body,
  }) async {
    try {
      await _ch.invokeMethod('showTestNow', {
        'id': id,
        'title': title,
        'body': body,
      });
    } on PlatformException {
      // swallow
    }
  }

  /// ✅ NUEVO: consulta al nativo si se pueden programar alarmas exactas.
  /// Si [openSettingsIfDenied] es true, intenta abrir Ajustes (Android 12+).
  static Future<bool> canScheduleExactAlarms({bool openSettingsIfDenied = false}) async {
    try {
      final ok = await _ch.invokeMethod<bool>('canScheduleExactAlarms', {
        'openSettings': openSettingsIfDenied,
      });
      return ok ?? true;
    } on PlatformException {
      // Si falla el canal, asumimos true para no bloquear la UX.
      return true;
    }
  }

  static Future<void> schedule({
    required String channelId,
    required String title,
    required String body,
    required int whenEpochMs,
    int? notifId,
  }) async {
    await _ch.invokeMethod('schedule', {
      'channelId': channelId,
      'title': title,
      'body': body,
      'whenEpochMs': whenEpochMs,
      'notifId': notifId,
    });
  }
}


