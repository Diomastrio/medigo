package com.example.medigo

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*

class HistoryScreen(carContext: CarContext) : Screen(carContext) {
    
    override fun onGetTemplate(): Template {
        return MessageTemplate.Builder("Historial de medicamentos")
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