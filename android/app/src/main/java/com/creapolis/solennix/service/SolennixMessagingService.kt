package com.creapolis.solennix.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.creapolis.solennix.MainActivity
// import com.google.firebase.messaging.FirebaseMessagingService
// import com.google.firebase.messaging.RemoteMessage

// class SolennixMessagingService : FirebaseMessagingService() {
class SolennixMessagingService {

    // override fun onMessageReceived(message: RemoteMessage) {
    //     super.onMessageReceived(message)
    //     
    //     message.notification?.let {
    //         showNotification(it.title ?: "Solennix", it.body ?: "")
    //     }
    // }

    // override fun onNewToken(token: String) {
    //     super.onNewToken(token)
    // }

    private fun showNotification(context: Context, title: String, body: String) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "solennix_notifications"

        val channel = NotificationChannel(channelId, "Solennix Notifications", NotificationManager.IMPORTANCE_DEFAULT)
        notificationManager.createNotificationChannel(channel)

        val intent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        notificationManager.notify(0, notification)
    }
}
