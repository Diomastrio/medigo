package com.example.medigo

import android.content.Intent
import androidx.car.app.Screen
import androidx.car.app.Session

class MediGoSession : Session() {
    override fun onCreateScreen(intent: Intent): Screen {
        return TodayMedicationsScreen(carContext)
    }
}