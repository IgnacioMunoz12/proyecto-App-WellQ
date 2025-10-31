package com.example.app_wellq

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.work.*
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {

    private val CHANNEL = "wellq/notify"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NativeNotifyBridge.attach(flutterEngine, this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "showNow" -> {
                        val id = (call.argument<Int>("id") ?: 1001)
                        val title = (call.argument<String>("title") ?: "WellQ")
                        val body = (call.argument<String>("body") ?: "Toca para abrir WellQ")
                        NotificationHelper.showNow(this, id, title, body)
                        result.success(null)
                    }
                    "scheduleInMs" -> {
                        val id = (call.argument<Int>("id") ?: 1002)
                        val title = (call.argument<String>("title") ?: "WellQ")
                        val body = (call.argument<String>("body") ?: "Recordatorio")
                        val delayMs = (call.argument<Long>("delayMs") ?: 5000L)

                        val data = workDataOf(
                            "id" to id,
                            "title" to title,
                            "body" to body
                        )

                        val request = OneTimeWorkRequestBuilder<ReminderWorker>()
                            .setInputData(data)
                            .setInitialDelay(delayMs, TimeUnit.MILLISECONDS)
                            .build()

                        WorkManager.getInstance(this)
                            .enqueueUniqueWork(
                                "wellq_reminder_$id",
                                ExistingWorkPolicy.REPLACE,
                                request
                            )
                        result.success(null)
                    }
                    "cancelAll" -> {
                        WorkManager.getInstance(this).cancelAllWork()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
