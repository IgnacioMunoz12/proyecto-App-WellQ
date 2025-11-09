package com.example.app_wellq

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class NotificationPublisher : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        val channelId = intent.getStringExtra("channelId") ?: "wellq_high_v1"
        val title = intent.getStringExtra("title") ?: "WellQ"
        val body  = intent.getStringExtra("body") ?: ""
        val notifId = intent.getIntExtra("notifId", System.currentTimeMillis().toInt())

        val smallIcon = ctx.applicationInfo.icon
        val notification = NotificationCompat.Builder(ctx, channelId)
            .setSmallIcon(smallIcon)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat.from(ctx).notify(notifId, notification)
    }
}
