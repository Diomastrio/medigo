package com.example.medigo

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.car.app.notification.CarAppExtender

object CarNotificationHandler {

    private const val MEDICATION_CHANNEL_ID = "medication_reminders_car"
    private const val MEDICATION_REMINDER_NOTIFICATION_ID = 101

    fun setupNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Recordatorios de Medicamentos (Auto)"
            val descriptionText = "Notificaciones para recordatorios de medicamentos en Android Auto"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(MEDICATION_CHANNEL_ID, name, importance).apply {
                description = descriptionText
                setSound(null, null) // Sounds are handled by the car system
            }

            val notificationManager: NotificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun showMedicationReminder(context: Context, medicineName: String, time: String) {
        val title = "Hora de tu medicina"
        val content = "$medicineName a las $time"

        // Intent to open the app when the notification is tapped
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            putExtra("AUTOMOTIVE_MODE", true)
        }
        val openAppPendingIntent: PendingIntent = PendingIntent.getActivity(context, 0, openAppIntent, PendingIntent.FLAG_IMMUTABLE)

        // Build the notification for the car
        val builder = NotificationCompat.Builder(context, MEDICATION_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_icon)
            .setContentTitle(title)
            .setContentText(content)
            .setContentIntent(openAppPendingIntent)
            .setCategory(Notification.CATEGORY_REMINDER)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .extend(CarAppExtender.Builder()
                .setContentTitle(title)
                .setContentText(content)
                .setImportance(NotificationManager.IMPORTANCE_HIGH)
                .build())

        with(NotificationManagerCompat.from(context)) {
            notify(MEDICATION_REMINDER_NOTIFICATION_ID, builder.build())
        }
    }
}