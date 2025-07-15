package com.example.medigo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MedicationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val medicationName = intent.getStringExtra("medication_name") ?: return
        
        when (intent.action) {
            "CONFIRM_MEDICATION" -> {
                // Handle medication confirmation
                // You can integrate with your Flutter app's database here
                handleMedicationConfirmation(context, medicationName)
            }
            "SNOOZE_MEDICATION" -> {
                // Handle snooze request
                handleMedicationSnooze(context, medicationName)
            }
        }
    }
    
    private fun handleMedicationConfirmation(context: Context, medicationName: String) {
        // Mark medication as taken in your database
        // Clear the notification
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        notificationManager.cancel(1001)
        
        // Show confirmation toast or update app state
    }
    
    private fun handleMedicationSnooze(context: Context, medicationName: String) {
        // Schedule reminder for later (e.g., 15 minutes)
        // Clear current notification
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        notificationManager.cancel(1001)
        
        // Schedule new reminder
    }
}