package com.example.app_wellq

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

class ReminderWorker(appContext: Context, workerParams: WorkerParameters)
    : Worker(appContext, workerParams) {

    override fun doWork(): Result {
        val id = inputData.getInt("id", 1001)
        val title = inputData.getString("title") ?: "WellQ"
        val body = inputData.getString("body") ?: "Toca para abrir WellQ"

        NotificationHelper.showNow(applicationContext, id, title, body)
        return Result.success()
    }
}
