import 'dart:async';
import 'package:flutter/services.dart';

class NativeNotifyBridge {
  static const MethodChannel _ch = MethodChannel('wellq/native_notify');

  /// Crea/eleva el canal de alta importancia en Android (no-op en iOS).
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
      // swallow para no romper UI
    }
  }

  /// Muestra una notificación inmediata (prueba).
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

  /// Programa una notificación exacta usando AlarmManager en Android.
  /// Importante: el **nombre** del parámetro que espera el bridge nativo es
  /// `whenEpochMs` (epoch en milisegundos).
  static Future<void> schedule({
    required String channelId,
    required String title,
    required String body,
    required int whenEpochMs, // <-- este nombre DEBE existir
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
