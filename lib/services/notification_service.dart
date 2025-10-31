import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'native_notify_bridge.dart';

class NotificationService {
  static final NotificationService _i = NotificationService._();
  factory NotificationService() => _i;
  NotificationService._();

  bool _inited = false;

  Future<void> ensureTimezoneInitialized() async {
    try {
      tz.initializeTimeZones();
    } catch (_) {
      // idempotente
    }
  }

  Future<void> init() async {
    if (_inited) return;
    // crea/eleva el canal de alta importancia en Android
    if (Platform.isAndroid) {
      await NativeNotifyBridge.ensureHighImportanceChannel(
        id: 'wellq_high_v1',
        name: 'Recordatorios (WellQ)',
        description: 'Recordatorios, calendario y hábitos',
      );
    }
    _inited = true;
  }

  /// Programa una notificación **exacta** usando el bridge nativo (Android).
  /// En iOS/macOS aquí podrías integrar su scheduler local si lo necesitas.
  Future<void> schedule({
    required String title,
    required String body,
    required DateTime when,
    int? notifId,
  }) async {
    await init();

    // Si la hora está en el pasado, empújala unos segundos al futuro para evitar errores.
    final DateTime whenSafe =
    when.isAfter(DateTime.now()) ? when : DateTime.now().add(const Duration(seconds: 5));

    if (Platform.isAndroid) {
      // convertimos a epoch ms (hora local)
      final int whenMs = whenSafe.millisecondsSinceEpoch;

      // Asegura un ID estable y **positivo** (no-cero)
      int stableId = notifId ?? _stableId('$title|$body|$whenMs');
      if (stableId <= 0) {
        stableId = (whenMs % 0x7fffffff).toInt();
        if (stableId == 0) stableId = 9999;
      }

      try {
        await NativeNotifyBridge.schedule(
          channelId: 'wellq_high_v1',
          title: title,
          body: body,
          whenEpochMs: whenMs, // <-- clave exacta que espera Kotlin
          notifId: stableId,
        );
      } catch (e) {
        // Re-lanza para que la UI (SnackBar/diálogo) pueda mostrar el error
        rethrow;
      }
      return;
    }

    // Otros SO: por ahora no-ops (no rompe)
    if (kDebugMode) {
      // print('schedule() no implementado para esta plataforma');
    }
  }

  int _stableId(String s) {
    // hash sencillo pero estable para id de noti, y lo forzamos a positivo
    final h = s.hashCode & 0x7fffffff;
    return h == 0 ? 7777 : h;
  }

  /// Permiso solo aplica Android 13+; el bridge ya lo maneja desde Settings.
  Future<void> requestPermissionIfNeeded() async {
    // si luego integras permisos iOS, hazlo aquí
  }
}



