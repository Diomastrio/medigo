package com.example.medigo

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*

class SuccessScreen(carContext: CarContext, private val message: String) : Screen(carContext) {
    
    override fun onGetTemplate(): Template {
        return MessageTemplate.Builder(message)
            .setHeaderAction(Action.BACK)
            .addAction(
                Action.Builder()
                    .setTitle("Volver")
                    .setOnClickListener {
                        screenManager.popToRoot()
                    }
                    .build()
            )
            .build()
    }
}