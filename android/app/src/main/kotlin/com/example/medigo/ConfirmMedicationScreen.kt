package com.example.medigo

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*

class ConfirmMedicationScreen(
    carContext: CarContext,
    private val medication: TodayMedicationsScreen.MedicationInfo
) : Screen(carContext) {
    
    override fun onGetTemplate(): Template {
        return MessageTemplate.Builder("¿Confirmar toma de ${medication.name}?")
            .setHeaderAction(Action.BACK)
            .addAction(
                Action.Builder()
                    .setTitle("Confirmar")
                    .setOnClickListener {
                        confirmMedicationTaken()
                    }
                    .build()
            )
            .addAction(
                Action.Builder()
                    .setTitle("Recordar más tarde")
                    .setOnClickListener {
                        snoozeReminder()
                    }
                    .build()
            )
            .build()
    }
    
    private fun confirmMedicationTaken() {
        // Mark medication as taken in database
        // Navigate to a success screen
        screenManager.push(SuccessScreen(carContext, "✓ Medicación confirmada"))
    }
    
    private fun snoozeReminder() {
        // Schedule reminder for later
        screenManager.pop()
    }
}