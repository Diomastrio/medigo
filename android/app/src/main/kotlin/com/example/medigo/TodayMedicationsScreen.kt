package com.example.medigo

import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.*
import androidx.core.graphics.drawable.IconCompat
import java.text.SimpleDateFormat
import java.util.*

class TodayMedicationsScreen(carContext: CarContext) : Screen(carContext) {
    
    override fun onGetTemplate(): Template {
        return ListTemplate.Builder()
            .setSingleList(buildMedicationList())
            .setTitle("MediGO - Medicamentos de Hoy")
            .setHeaderAction(Action.APP_ICON)
            .setActionStrip(
                ActionStrip.Builder()
                    .addAction(
                        Action.Builder()
                            .setTitle("Actualizar")
                            .setIcon(
                                CarIcon.Builder(
                                    IconCompat.createWithResource(
                                        carContext, 
                                        android.R.drawable.ic_popup_sync
                                    )
                                ).build()
                            )
                            .setOnClickListener { 
                                invalidate() // Refresh the screen
                            }
                            .build()
                    )
                    .addAction(
                        Action.Builder()
                            .setTitle("Ver Todo")
                            .setOnClickListener {
                                screenManager.push(RemindersScreen(carContext))
                            }
                            .build()
                    )
                    .build()
            )
            .build()
    }

    private fun buildMedicationList(): ItemList {
        val builder = ItemList.Builder()
        
        // Get today's medications from database
        val todaysMedications = getTodaysMedications()
        
        if (todaysMedications.isEmpty()) {
            builder.addItem(
                Row.Builder()
                    .setTitle("No hay medicamentos programados")
                    .addText("¡Excelente! No tienes dosis pendientes para hoy")
                    .setImage(
                        CarIcon.Builder(
                            IconCompat.createWithResource(
                                carContext,
                                android.R.drawable.ic_dialog_info
                            )
                        ).build(),
                        Row.IMAGE_TYPE_ICON
                    )
                    .build()
            )
        } else {
            todaysMedications.forEach { medication ->
                builder.addItem(createMedicationRow(medication))
            }
        }
        
        return builder.build()
    }

    private fun createMedicationRow(medication: MedicationInfo): Row {
        val timeText = medication.time
        val statusText = if (medication.taken) "✓ Tomado" else "Pendiente"
        val statusColor = if (medication.taken) 
            CarColor.createCustom(android.graphics.Color.GREEN, android.graphics.Color.GREEN)
        else 
            CarColor.createCustom(android.graphics.Color.ORANGE, android.graphics.Color.ORANGE)

        return Row.Builder()
            .setTitle(medication.name)
            .addText("Hora: $timeText")
            .addText(statusText)
            .setImage(
                CarIcon.Builder(
                    IconCompat.createWithResource(
                        carContext,
                        if (medication.taken) 
                            android.R.drawable.ic_menu_agenda 
                        else 
                            android.R.drawable.ic_menu_recent_history
                    )
                ).build(),
                Row.IMAGE_TYPE_ICON
            )
            .setOnClickListener {
                if (!medication.taken) {
                    screenManager.push(ConfirmMedicationScreen(carContext, medication))
                }
            }
            .build()
    }

    private fun getTodaysMedications(): List<MedicationInfo> {
        // In a real app, you'd query your database
        // For now, return sample data
        return listOf(
            MedicationInfo("Aspirina 100mg", "08:00", false, 1),
            MedicationInfo("Vitamina D", "12:00", true, 2),
            MedicationInfo("Omeprazol", "20:00", false, 3)
        )
    }

    data class MedicationInfo(
        val name: String,
        val time: String,
        val taken: Boolean,
        val id: Int
    )
}