import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/models/reminder.dart';
import '../services/search_service.dart';
import '../services/mqtt_service.dart'; // Replace bluetooth with mqtt

class AutomotiveHomeScreen extends StatefulWidget {
  @override
  _AutomotiveHomeScreenState createState() => _AutomotiveHomeScreenState();
}

class _AutomotiveHomeScreenState extends State<AutomotiveHomeScreen> {
  List<Reminder> _reminders = [];
  List<Reminder> _filteredReminders = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  bool _isMqttConnected = false;
  final MqttService _mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _initializeMqtt();
  }

  Future<void> _initializeMqtt() async {
    try {
      await _mqttService.initialize();
      setState(() {
        _isMqttConnected = _mqttService.isConnected;
      });
    } catch (e) {
      print('Error initializing MQTT: $e');
    }
  }

  Future<void> _connectToMqtt() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _mqttService.connect();
      
      setState(() {
        _isMqttConnected = _mqttService.isConnected;
        _isLoading = false;
      });
      
      if (_isMqttConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conectado al servidor MQTT'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo conectar al servidor MQTT'),
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

      final allReminders = await _dbHelper.getReminders();
      
      // Filter for today's reminders that haven't been taken
      final now = DateTime.now();
      final todayReminders = <Reminder>[];
      
      for (final reminder in allReminders) {
        // Check if reminder is for today and not taken
        if (reminder.id != null) {
          final history = await _dbHelper.getDoseHistory();
          final takenToday = history.any((h) => 
            h.reminderId == reminder.id && 
            DateTime.parse(h.takenAt).day == now.day &&
            DateTime.parse(h.takenAt).month == now.month &&
            DateTime.parse(h.takenAt).year == now.year
          );
          
          if (!takenToday) {
            todayReminders.add(reminder);
          }
        }
      }

      setState(() {
        _reminders = allReminders;
        _filteredReminders = todayReminders;
        _isLoading = false;
      });
      
      print('Loaded ${todayReminders.length} pending reminders');
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
        // Add to dose history
        await _dbHelper.addDoseHistory(reminder);
        
        // Send confirmation via MQTT
        await _mqttService.sendDoseConfirmation(reminder);
      }
      
      // Show large success alert
      _showSuccessAlert(reminder.medicineName);
      
      // Reload reminders to update the list
      await _loadReminders();
    } catch (e) {
      print('Error confirming dose: $e');
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
                  
                  // MQTT Connection Status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isMqttConnected ? Colors.green : Colors.grey[700],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isMqttConnected ? Icons.cloud_done : Icons.cloud_off,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _isMqttConnected ? 'Conectado' : 'Desconectado',
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
                    onPressed: _isMqttConnected ? null : _connectToMqtt,
                    icon: Icon(
                      _isMqttConnected ? Icons.check : Icons.cloud,
                      size: 16,
                    ),
                    label: Text(_isMqttConnected ? 'Conectado' : 'Conectar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMqttConnected ? Colors.green : Colors.blue,
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