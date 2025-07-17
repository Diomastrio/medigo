import 'package:flutter/material.dart';
import '../services/bluetooth_sync_service.dart';
import '../data/database_helper.dart';

class BluetoothSyncButton extends StatefulWidget {
  @override
  _BluetoothSyncButtonState createState() => _BluetoothSyncButtonState();
}

class _BluetoothSyncButtonState extends State<BluetoothSyncButton> {
  final BluetoothSyncService _bluetoothService = BluetoothSyncService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isConnected = false;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  void _checkConnection() {
    setState(() {
      _isConnected = _bluetoothService.isConnected;
    });
  }

  Future<void> _syncReminders() async {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay conexión Bluetooth con el vehículo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
    });

    try {
      // Get all reminders from database
      final reminders = await _dbHelper.getReminders();
      
      // Send each reminder via Bluetooth
      for (final reminder in reminders) {
        await _bluetoothService.sendReminderUpdate(reminder);
        await Future.delayed(Duration(milliseconds: 100)); // Small delay between sends
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reminders.length} recordatorios enviados al vehículo'),
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
      margin: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Connection Status
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isConnected ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isConnected ? 'Conectado al vehículo' : 'Vehículo desconectado',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isConnected ? Colors.green.shade700 : Colors.red.shade700,
                          fontSize: 16,
                        ),
                      ),
                      if (_isConnected && _bluetoothService.connectedDevice != null)
                        Text(
                          _bluetoothService.connectedDevice!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!_isConnected)
                  TextButton.icon(
                    onPressed: () async {
                      await _bluetoothService.initialize();
                      _checkConnection();
                    },
                    icon: Icon(Icons.refresh, size: 16),
                    label: Text('Reconectar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Sync Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isConnected && !_isSyncing ? _syncReminders : null,
              icon: _isSyncing 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.sync, size: 24),
              label: Text(
                _isSyncing 
                    ? 'Sincronizando...' 
                    : 'Enviar Recordatorios al Vehículo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isConnected ? Colors.blue : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _isConnected ? 2 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}