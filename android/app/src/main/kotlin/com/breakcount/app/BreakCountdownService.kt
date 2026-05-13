package com.breakcount.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import androidx.core.app.NotificationCompat
import es.antonborri.home_widget.HomeWidgetPlugin

class BreakCountdownService : Service() {

    companion object {
        private const val TAG = "BreakCountdown"
        private const val CHANNEL_ID = "breakcount_countdown"
        private const val NOTIF_ID = 9001
        private const val REFRESH_INTERVAL_MS = 15L * 60 * 1000 // 15 min

        @Volatile
        var isRunning = false
            private set
    }

    private val handler = Handler(Looper.getMainLooper())
    private val refreshRunnable = Runnable { refreshNotification() }

    override fun onCreate() {
        super.onCreate()
        createChannel()
        isRunning = true
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIF_ID, buildNotification())
        scheduleRefresh()
        return START_STICKY
    }

    override fun onDestroy() {
        handler.removeCallbacks(refreshRunnable)
        isRunning = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Break Countdown",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Persistent break countdown on lock screen"
            setShowBadge(false)
        }
        val nm = getSystemService(NotificationManager::class.java)
        nm.createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val prefs = HomeWidgetPlugin.getData(this)
        val days = prefs.getInt("days_until_break", -1)
        val breakName = prefs.getString("next_break_name", null) ?: "Next Break"
        val isOnBreak = prefs.getBoolean("is_on_break", false)

        val contentText = when {
            isOnBreak -> "You're on break! Enjoy 🎉"
            days < 0 -> "No break data available"
            days == 0 -> "Break starts today!"
            days == 1 -> "1 day remaining"
            else -> "$days days remaining"
        }

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(breakName)
            .setContentText(contentText)
            .setOngoing(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_STATUS)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        // Use Chronometer for a live tick when days > 0 and not on break
        if (!isOnBreak && days > 0) {
            builder.setUsesChronometer(true)
            builder.setChronometerCountDown(true)
            builder.setWhen(System.currentTimeMillis() + days.toLong() * 86_400_000L)
        }

        return builder.build()
    }

    private fun refreshNotification() {
        try {
            val nm = getSystemService(NotificationManager::class.java)
            nm.notify(NOTIF_ID, buildNotification())
        } catch (e: Exception) {
            Log.e(TAG, "refresh failed", e)
        }
        scheduleRefresh()
    }

    private fun scheduleRefresh() {
        handler.removeCallbacks(refreshRunnable)
        handler.postDelayed(refreshRunnable, REFRESH_INTERVAL_MS)
    }
}
