package com.example.app_wellq

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object NotificationHelper {
    const val CHANNEL_ID = "wellq_reminders_native_v1"
    private const val CHANNEL_NAME = "Recordatorios (WellQ)"
    private const val CHANNEL_DESC = "Alertas de hábitos y salud"

    fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH // 🔥 heads-up
            val channel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance).apply {
                description = CHANNEL_DESC
                enableVibration(true)
            }
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    fun showNow(context: Context, id: Int, title: String, body: String) {
        ensureChannel(context)

        // Intent para abrir la app al tocar la notificación
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val contentIntent = PendingIntent.getActivity(
            context, id, launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher) // usa tu ícono
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)         // 🔥 heads-up
            .setCategory(NotificationCompat.CATEGORY_REMINDER)     // 🔥 heads-up
            .setAutoCancel(true)
            .setContentIntent(contentIntent)

        with(NotificationManagerCompat.from(context)) {
            notify(id, builder.build())
        }
    }
}
