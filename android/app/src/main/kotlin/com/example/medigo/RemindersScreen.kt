package com.example.medigo

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*

class RemindersScreen(carContext: CarContext) : Screen(carContext) {
    
    override fun onGetTemplate(): Template {
        return MessageTemplate.Builder("Recordatorios pendientes")
            .setHeaderAction(Action.BACK)
            .addAction(
                Action.Builder()
                    .setTitle("Volver")
                    .setOnClickListener {
                        screenManager.pop()
                    }
                    .build()
            )
            .build()
    }
}