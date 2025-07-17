import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../data/database_helper.dart';

class MqttSyncButton extends StatefulWidget {
  @override
  _MqttSyncButtonState createState() => _MqttSyncButtonState();
}

class _MqttSyncButtonState extends State<MqttSyncButton> {
  final MqttService _mqttService = MqttService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isSyncing = false;

  Future<void> _syncReminders() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // Get all reminders from database
      final reminders = await _dbHelper.getReminders();
      
      if (reminders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No hay recordatorios para sincronizar'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Ensure MQTT is connected
      if (!_mqttService.isConnected) {
        await _mqttService.connect();
      }

      // Send reminders via MQTT
      await _mqttService.sendReminders(reminders);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reminders.length} recordatorios sincronizados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al sincronizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSyncing ? null : _syncReminders,
        icon: _isSyncing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(Icons.sync, size: 20),
        label: Text(
          _isSyncing ? 'Sincronizando...' : 'Sincronizar con Auto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}