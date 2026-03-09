package com.alfahrel.threshold

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AppBlockerAccessibilityService : AccessibilityService() {

    private val lastOverlayShownTimes = mutableMapOf<String, Long>()
    private val OVERLAY_SHOW_COOLDOWN_MS = 1000L
    private var lastHomeActionTime = 0L
    private val HOME_ACTION_COOLDOWN_MS = 500L

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                val packageName = event.packageName?.toString()
                if (packageName != null && packageName != "com.alfahrel.threshold") {
                    if (isAppLimitExceeded(packageName)) {
                        blockApp(packageName)
                    }
                }
            }
        }
    }

    private fun isAppLimitExceeded(packageName: String): Boolean {
        return try {
            val timerPrefs = getSharedPreferences("app_timers", Context.MODE_PRIVATE)
            val limitMinutes = timerPrefs.getInt(packageName, -1)

            if (limitMinutes <= 0) return false

            val usageMs = getTodayUsage(packageName)
            val usageMinutes = usageMs / (1000 * 60)

            usageMinutes >= limitMinutes
        } catch (e: Exception) {
            false
        }
    }

    private fun getTodayUsage(packageName: String): Long {
        return try {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE)
                    as android.app.usage.UsageStatsManager

            val calendar = java.util.Calendar.getInstance()
            calendar.set(java.util.Calendar.HOUR_OF_DAY, 0)
            calendar.set(java.util.Calendar.MINUTE, 0)
            calendar.set(java.util.Calendar.SECOND, 0)
            val start = calendar.timeInMillis
            val end = System.currentTimeMillis()

            val stats = usageStatsManager.queryUsageStats(
                android.app.usage.UsageStatsManager.INTERVAL_DAILY,
                start,
                end
            )

            var totalTime = 0L
            for (stat in stats) {
                if (stat.packageName == packageName) {
                    totalTime += stat.totalTimeInForeground
                }
            }

            totalTime
        } catch (e: Exception) {
            0L
        }
    }

    private fun blockApp(packageName: String) {
        val now = System.currentTimeMillis()
        if (now - lastHomeActionTime > HOME_ACTION_COOLDOWN_MS) {
            performGlobalAction(GLOBAL_ACTION_HOME)
            lastHomeActionTime = now
        }

        val lastOverlayTime = lastOverlayShownTimes[packageName] ?: 0L
        if (now - lastOverlayTime > OVERLAY_SHOW_COOLDOWN_MS) {
            showBlockOverlay(packageName)
            lastOverlayShownTimes[packageName] = now
        }
    }

    private fun showBlockOverlay(packageName: String) {
        val intent = Intent(this, BlockOverlayService::class.java)
        intent.putExtra("packageName", packageName)
        startService(intent)
    }

    override fun onInterrupt() {}

    override fun onServiceConnected() {
        super.onServiceConnected()
    }

    override fun onDestroy() {
        super.onDestroy()
        lastOverlayShownTimes.clear()
    }
}