package alfahrel.my.id.threshold.service

import alfahrel.my.id.threshold.R
import alfahrel.my.id.threshold.ui.widget.BlockActivity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder

class BlockOverlayService : Service() {

    companion object {
        private const val CHANNEL_ID = "block_overlay_channel"
        private const val NOTIFICATION_ID = 1001
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val packageName = intent?.getStringExtra("packageName") ?: ""

        createNotificationChannel()

        val activityIntent = Intent(this, BlockActivity::class.java).apply {
            putExtra("packageName", packageName)
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
            )
        }

        val pendingIntent = PendingIntent.getActivity(
            this, 0, activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("App Limit Reached")
                .setContentText("Tap to see your screen time summary.")
                .setSmallIcon(R.drawable.ic_rounded_timer_24)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .setFullScreenIntent(pendingIntent, true)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
                .setContentTitle("App Limit Reached")
                .setContentText("Tap to see your screen time summary.")
                .setSmallIcon(R.drawable.ic_rounded_timer_24)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .setPriority(Notification.PRIORITY_MAX)
                .build()
        }

        startForeground(NOTIFICATION_ID, notification)
        startActivity(activityIntent)
        stopForeground(true)
        stopSelf()

        return START_NOT_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "App Block Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Shown when an app time limit is reached"
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }
}