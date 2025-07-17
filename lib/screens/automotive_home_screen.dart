import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/reminder.dart';
import '../services/search_service.dart';
import '../services/bluetooth_sync_service.dart';
import '../services/automotive_sync_service.dart';
import 'confirmation_screen.dart';
import '../widgets/modals/confirm_success.dart';

class AutomotiveHomeScreen extends StatefulWidget {
  @override
  _AutomotiveHomeScreenState createState() => _AutomotiveHomeScreenState();
}

class _AutomotiveHomeScreenState extends State<AutomotiveHomeScreen> {
  List<Reminder> _reminders = [];
  List<Reminder> _filteredReminders = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  bool _isBluetoothConnected = false; // Add this
  final BluetoothSyncService _bluetoothService = BluetoothSyncService(); // Add this

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _initializeBluetooth(); // Add this
  }

  // Add this method
  Future<void> _initializeBluetooth() async {
    await _bluetoothService.initialize();
    setState(() {
      _isBluetoothConnected = _bluetoothService.isConnected;
    });
  }

  // Add this method
  Future<void> _connectToBluetooth() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _bluetoothService.initialize();
      
      // Wait a moment for connection
      await Future.delayed(Duration(seconds: 2));
      
      setState(() {
        _isBluetoothConnected = _bluetoothService.isConnected;
        _isLoading = false;
      });
      
      if (_isBluetoothConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conectado a ${_bluetoothService.connectedDevice ?? "dispositivo"}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo conectar. Asegúrate de que el teléfono esté cerca.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadReminders() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get synced reminders from phone
      final syncedReminders = await AutomotiveSyncService().getRemindersFromPhone();
      
      // Filter for today's reminders that haven't been taken
      final now = DateTime.now();
      final todayReminders = <Reminder>[];
      
      for (final reminder in syncedReminders) {
        // Check if reminder is for today and not taken
        if (reminder.id != null) {
          final isTaken = await AutomotiveSyncService().isReminderTaken(reminder.id!);
          if (!isTaken) {
            todayReminders.add(reminder);
          }
        }
      }

      setState(() {
        _reminders = syncedReminders;
        _filteredReminders = todayReminders; // This was missing!
        _isLoading = false;
      });
      
      print('Loaded ${todayReminders.length} pending reminders from sync');
    } catch (e) {
      print('Error loading reminders: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadReminders();
  }

  Future<void> _confirmDose(Reminder reminder) async {
    try {
      if (reminder.id != null) {
        // Mark as taken in automotive sync service
        await AutomotiveSyncService().markReminderTaken(reminder.id!);
        
        // Also add to dose history
        await _dbHelper.addDoseHistory(reminder);
      }
      
      // Show large success alert
      _showSuccessAlert(reminder.medicineName);
      
      // Reload reminders to update the list
      await _loadReminders();
    } catch (e) {
      print('Error confirming dose: $e');
      // Show error alert
      _showErrorAlert();
    }
  }

  void _showSuccessAlert(String medicineName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(32),
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Success Message
                Text(
                  '¡Dosis Confirmada!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 16),
                
                Text(
                  medicineName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 24),
                
                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    // Auto-dismiss after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showErrorAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(32),
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Error Message
                Text(
                  'Error',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 16),
                
                Text(
                  'No se pudo confirmar la dosis.\nIntenta nuevamente.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 24),
                
                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    // Auto-dismiss after 4 seconds for error
    Future.delayed(Duration(seconds: 4), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    color: Colors.blue,
                    size: 32,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'MediGO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  
                  // Bluetooth Connection Status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isBluetoothConnected ? Colors.green : Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isBluetoothConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _isBluetoothConnected ? 'Conectado' : 'Desconectado',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(width: 8),
                  
                  // Connect Button
                  ElevatedButton.icon(
                    onPressed: _isBluetoothConnected ? null : _connectToBluetooth,
                    icon: Icon(
                      _isBluetoothConnected ? Icons.check : Icons.bluetooth,
                      size: 16,
                    ),
                    label: Text(_isBluetoothConnected ? 'Conectado' : 'Conectar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBluetoothConnected ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white, size: 28),
                    onPressed: _refreshData,
                  ),
                ],
              ),
              
              SizedBox(height: 32),

              // Title
              Text(
                'Próximas Dosis',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: 24),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : _filteredReminders.isEmpty
                        ? _buildEmptyState()
                        : _buildRemindersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: Colors.grey[600],
          ),
          SizedBox(height: 16),
          Text(
            'No hay recordatorios pendientes',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 20,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Todos tus medicamentos están al día',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    return ListView.builder(
      itemCount: _filteredReminders.length,
      itemBuilder: (context, index) {
        final reminder = _filteredReminders[index];
        return _buildAutomotiveReminderCard(reminder);
      },
    );
  }

  Widget _buildAutomotiveReminderCard(Reminder reminder) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Row(
        children: [
          // Medicine Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          SizedBox(width: 20),
          
          // Medicine Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.medicineName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${reminder.doseCount} ${reminder.doseType}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[500],
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      reminder.time,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(width: 16),
          
          // Confirm Button
          ElevatedButton(
            onPressed: () => _confirmDose(reminder),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 20),
                SizedBox(width: 8),
                Text(
                  'Confirmar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}