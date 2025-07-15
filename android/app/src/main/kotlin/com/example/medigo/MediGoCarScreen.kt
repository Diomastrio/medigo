package com.example.medigo

import android.content.Intent
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.Action
import androidx.car.app.model.MessageTemplate
import androidx.car.app.model.Template

class MediGoCarScreen(carContext: CarContext) : Screen(carContext) {
    override fun onGetTemplate(): Template {
        return MessageTemplate.Builder("Toca para abrir la aplicación de medicamentos")
            .setTitle("MediGO - Gestión de Medicamentos")
            .setHeaderAction(Action.APP_ICON)
            .addAction(
                Action.Builder()
                    .setTitle("Abrir MediGO")
                    .setOnClickListener {
                        // Launch the main Flutter activity
                        val intent = Intent(carContext, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                            putExtra("AUTOMOTIVE_MODE", true)
                        }
                        carContext.startActivity(intent)
                    }
                    .build()
            )
            .build()
    }
}