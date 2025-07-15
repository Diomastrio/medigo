package com.example.medigo

import androidx.car.app.CarAppService
import androidx.car.app.Session
import androidx.car.app.validation.HostValidator

class MyCarAppService : CarAppService() {

    override fun createHostValidator(): HostValidator {
        return HostValidator.ALLOW_ALL_HOSTS_VALIDATOR
    }

    override fun onCreateSession(): Session {
        // Setup the channel when the service is created
        CarNotificationHandler.setupNotificationChannel(applicationContext)

        // For demonstration, show a notification when the session starts
        // In a real app, this would be triggered by a background service at the correct time
        CarNotificationHandler.showMedicationReminder(
            applicationContext,
            "Aspirina 100mg",
            "08:00 AM"
        )

        return MediGoSession()
    }
}