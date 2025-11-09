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
    } catch (_) {}
  }

  Future<void> init() async {
    if (_inited) return;
    if (Platform.isAndroid) {
      await NativeNotifyBridge.ensureHighImportanceChannel(
        id: 'wellq_high_v1',
        name: 'Recordatorios (WellQ)',
        description: 'Recordatorios, calendario y hábitos',
      );
    }
    _inited = true;
  }

  Future<void> schedule({
    required String title,
    required String body,
    required DateTime when,
    int? notifId,
  }) async {
    await init();

    final whenSafe =
    when.isAfter(DateTime.now()) ? when : DateTime.now().add(const Duration(seconds: 5));

    if (Platform.isAndroid) {
      // 🔎 (opcional) validar permiso de alarmas exactas y abrir Ajustes si hace falta
      final can = await NativeNotifyBridge.canScheduleExactAlarms(openSettingsIfDenied: true);
      if (!can) {
        throw Exception('Exact alarms deshabilitadas por el sistema.');
      }

      final int whenMs = whenSafe.millisecondsSinceEpoch;
      int stableId = notifId ?? _stableId('$title|$body|$whenMs');
      if (stableId <= 0) {
        stableId = (whenMs % 0x7fffffff).toInt();
        if (stableId == 0) stableId = 9999;
      }

      await NativeNotifyBridge.schedule(
        channelId: 'wellq_high_v1',
        title: title,
        body: body,
        whenEpochMs: whenMs,
        notifId: stableId,
      );
      return;
    }

    if (kDebugMode) {
      // print('schedule() no implementado para esta plataforma');
    }
  }

  int _stableId(String s) {
    final h = s.hashCode & 0x7fffffff;
    return h == 0 ? 7777 : h;
  }

  Future<void> requestPermissionIfNeeded() async {
    // Android 13+: POST_NOTIFICATIONS se maneja en Settings de sistema/canal (ya creado).
    // Si quisieras, aquí podrías mostrar un diálogo educativo antes de abrir Ajustes.
    if (Platform.isAndroid) {
      await NativeNotifyBridge.canScheduleExactAlarms(openSettingsIfDenied: false);
    }
  }
}





