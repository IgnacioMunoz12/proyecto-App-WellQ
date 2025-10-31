package com.example.app_wellq

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object NativeNotifyBridge {

    private const val CHANNEL_NAME = "wellq/native_notify"

    fun attach(flutterEngine: FlutterEngine, context: Context) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // Crea/eleva el canal de alta prioridad
                    "ensureHighImportanceChannel" -> {
                        val id = call.argument<String>("id") ?: "wellq_high_v1"
                        val name = call.argument<String>("name") ?: "Recordatorios (WellQ)"
                        val description = call.argument<String>("description") ?: "Recordatorios y hábitos"
                        ensureHighChannel(context.applicationContext, id, name, description)
                        result.success(null)
                    }

                    // Notificación inmediata (test)
                    "showTestNow" -> {
                        val id = call.argument<String>("id") ?: "wellq_high_v1"
                        showTest(context.applicationContext, id)
                        result.success(null)
                    }

                    // Programar notificación exacta con AlarmManager + BroadcastReceiver
                    "schedule" -> {
                        val channelId = call.argument<String>("channelId") ?: "wellq_high_v1"
                        val title = call.argument<String>("title") ?: "WellQ"
                        val body  = call.argument<String>("body") ?: ""
                        val whenEpochMs = call.argument<Long>("whenEpochMs") ?: 0L
                        val notifId = call.argument<Int>("notifId") ?: System.currentTimeMillis().toInt()

                        if (whenEpochMs <= 0L) {
                            result.error("bad_time", "Invalid whenEpochMs", null)
                            return@setMethodCallHandler
                        }

                        val ctx = context.applicationContext
                        val intent = Intent(ctx, NotificationPublisher::class.java).apply {
                            putExtra("channelId", channelId)
                            putExtra("title", title)
                            putExtra("body", body)
                            putExtra("notifId", notifId)
                        }

                        val flags =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                            else
                                PendingIntent.FLAG_UPDATE_CURRENT

                        val pi = PendingIntent.getBroadcast(ctx, notifId, intent, flags)

                        val alarmMgr = ctx.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            alarmMgr.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, whenEpochMs, pi)
                        } else {
                            alarmMgr.setExact(AlarmManager.RTC_WAKEUP, whenEpochMs, pi)
                        }

                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    // ===== Helpers privados =====

    private fun ensureHighChannel(ctx: Context, id: String, name: String, description: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val existing = nm.getNotificationChannel(id)

            if (existing == null || existing.importance != NotificationManager.IMPORTANCE_HIGH) {
                if (existing != null) nm.deleteNotificationChannel(id)

                val ch = NotificationChannel(id, name, NotificationManager.IMPORTANCE_HIGH).apply {
                    this.description = description
                    enableVibration(true)
                    vibrationPattern = longArrayOf(0, 200, 100, 200)
                    setShowBadge(true)
                    enableLights(true)
                    lightColor = Color.GREEN
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                }
                nm.createNotificationChannel(ch)
            }
        }
    }

    private fun notifyNow(
        ctx: Context,
        channelId: String,
        title: String,
        body: String,
        notifId: Int
    ) {
        val nm = NotificationManagerCompat.from(ctx)
        val smallIcon = ctx.applicationInfo.icon
        val n = NotificationCompat.Builder(ctx, channelId)
            .setSmallIcon(smallIcon)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setAutoCancel(true)
            .build()
        nm.notify(notifId, n)
    }

    private fun showTest(ctx: Context, channelId: String) {
        notifyNow(ctx, channelId, "WellQ", "🔔 Notificación de prueba (heads-up)", 9991)
    }
}


