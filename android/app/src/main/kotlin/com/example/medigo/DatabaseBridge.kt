package com.example.medigo

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class DatabaseBridge(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {
    private var methodChannel: MethodChannel? = null

    companion object {
        private const val DATABASE_NAME = "medigo_database.db"
        private const val DATABASE_VERSION = 1
    }

    override fun onCreate(db: SQLiteDatabase) {
        // Database will be created by Flutter app
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // Handle upgrades if needed
    }

    fun setupMethodChannel(channel: MethodChannel) {
        methodChannel = channel
    }

    suspend fun getTodayReminders(): List<Map<String, Any>> {
        return withContext(Dispatchers.Main) {
            try {
                val result = methodChannel?.invokeMethod("getTodayReminders", null)
                @Suppress("UNCHECKED_CAST")
                result as? List<Map<String, Any>> ?: emptyList()
            } catch (e: Exception) {
                emptyList()
            }
        }
    }

    suspend fun markMedicationTaken(reminderId: Int): Boolean {
        return withContext(Dispatchers.Main) {
            try {
                val result = methodChannel?.invokeMethod("markMedicationTaken", reminderId)
                result as? Boolean ?: false
            } catch (e: Exception) {
                false
            }
        }
    }

    fun getTodaysReminders(): List<TodayMedicationsScreen.MedicationInfo> {
        val medications = mutableListOf<TodayMedicationsScreen.MedicationInfo>()
        val db = readableDatabase

        try {
            val cursor = db.rawQuery(
                "SELECT medicine_name, time, id FROM reminders ORDER BY time ASC",
                null
            )

            while (cursor.moveToNext()) {
                val name = cursor.getString(0)
                val time = cursor.getString(1)
                val id = cursor.getInt(2)

                medications.add(
                    TodayMedicationsScreen.MedicationInfo(name, time, false, id)
                )
            }
            cursor.close()
        } catch (e: Exception) {
            // Handle database errors
        }

        return medications
    }
}