import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../data/database_helper.dart';
import '../data/models/reminder.dart';

class BluetoothSyncService {
  static final BluetoothSyncService _instance = BluetoothSyncService._internal();
  factory BluetoothSyncService() => _instance;
  BluetoothSyncService._internal();

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isConnected = false;

  // Service and Characteristic UUIDs for MediGO
  static const String SERVICE_UUID = "12345678-1234-1234-1234-123456789abc";
  static const String CHARACTERISTIC_UUID = "87654321-4321-4321-4321-cba987654321";

  Future<void> initialize() async {
    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        print("Bluetooth not supported by this device");
        return;
      }

      // Turn on Bluetooth if off
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        await FlutterBluePlus.turnOn();
      }

      // Start scanning for devices
      await _startScanning();
    } catch (e) {
      print('Error initializing Bluetooth: $e');
    }
  }

  Future<void> _startScanning() async {
    try {
      // Listen to scan results
      var subscription = FlutterBluePlus.scanResults.listen((results) {
        // Look for automotive devices specifically
        for (ScanResult r in results) {
          if (r.device.platformName.contains('MediGO') || 
              r.device.platformName.contains('Automotive') ||
              r.device.platformName.contains('Car') ||
              r.advertisementData.localName.contains('MediGO')) {
            _connectToDevice(r.device);
            break;
          }
        }
      });

      // Start scanning with longer timeout for automotive
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 30));

      // Stop scanning after timeout
      await FlutterBluePlus.stopScan();
      subscription.cancel();
    } catch (e) {
      print('Error scanning for devices: $e');
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;
      
      print('Connected to ${device.platformName}');
      
      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      
      // Find our service and characteristic
      for (BluetoothService service in services) {
        if (service.uuid.toString().toLowerCase() == SERVICE_UUID.toLowerCase()) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString().toLowerCase() == CHARACTERISTIC_UUID.toLowerCase()) {
              _characteristic = characteristic;
              
              // Subscribe to notifications
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen(_onDataReceived);
              
              // Send initial sync request
              await _requestReminderSync();
              break;
            }
          }
        }
      }
      
    } catch (e) {
      print('Error connecting to device: $e');
      _isConnected = false;
    }
  }

  void _onDataReceived(List<int> data) async {
    try {
      String message = String.fromCharCodes(data);
      Map<String, dynamic> messageData = jsonDecode(message);
      
      switch (messageData['type']) {
        case 'reminder_sync':
          await _handleReminderSync(messageData['data']);
          break;
        case 'reminder_update':
          await _handleReminderUpdate(messageData['data']);
          break;
        case 'dose_confirmation':
          await _handleDoseConfirmation(messageData['data']);
          break;
      }
    } catch (e) {
      print('Error processing received data: $e');
    }
  }

  Future<void> _handleReminderSync(List<dynamic> remindersData) async {
    try {
      for (var reminderData in remindersData) {
        Reminder reminder = Reminder.fromMap(Map<String, dynamic>.from(reminderData));
        
        // Check if reminder already exists
        List<Reminder> existingReminders = await _dbHelper.getReminders();
        bool exists = existingReminders.any((r) => 
          r.medicineName == reminder.medicineName && 
          r.time == reminder.time
        );
        
        if (!exists) {
          await _dbHelper.insertReminder(reminder);
          print('Synced reminder: ${reminder.medicineName}');
        }
      }
    } catch (e) {
      print('Error handling reminder sync: $e');
    }
  }

  Future<void> _handleReminderUpdate(Map<String, dynamic> reminderData) async {
    try {
      Reminder reminder = Reminder.fromMap(reminderData);
      await _dbHelper.updateReminder(reminder);
      print('Updated reminder: ${reminder.medicineName}');
    } catch (e) {
      print('Error handling reminder update: $e');
    }
  }

  Future<void> _handleDoseConfirmation(Map<String, dynamic> data) async {
    try {
      int reminderId = data['reminderId'];
      List<Reminder> reminders = await _dbHelper.getReminders();
      Reminder? reminder = reminders.where((r) => r.id == reminderId).firstOrNull;
      
      if (reminder != null) {
        await _dbHelper.addDoseHistory(reminder);
        print('Dose confirmed for: ${reminder.medicineName}');
      }
    } catch (e) {
      print('Error handling dose confirmation: $e');
    }
  }

  Future<void> _requestReminderSync() async {
    if (!_isConnected || _characteristic == null) return;
    
    try {
      Map<String, dynamic> message = {
        'type': 'sync_request',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _characteristic!.write(utf8.encode(jsonEncode(message)));
    } catch (e) {
      print('Error requesting sync: $e');
    }
  }

  Future<void> sendReminderUpdate(Reminder reminder) async {
    if (!_isConnected || _characteristic == null) return;
    
    try {
      Map<String, dynamic> message = {
        'type': 'reminder_update',
        'data': reminder.toMap(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _characteristic!.write(utf8.encode(jsonEncode(message)));
    } catch (e) {
      print('Error sending reminder update: $e');
    }
  }

  Future<void> sendDoseConfirmation(int reminderId) async {
    if (!_isConnected || _characteristic == null) return;
    
    try {
      Map<String, dynamic> message = {
        'type': 'dose_confirmation',
        'data': {'reminderId': reminderId},
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _characteristic!.write(utf8.encode(jsonEncode(message)));
    } catch (e) {
      print('Error sending dose confirmation: $e');
    }
  }

  // Add method to send all reminders at once
  Future<void> sendAllReminders(List<Reminder> reminders) async {
    if (!_isConnected || _characteristic == null) {
      throw Exception('No hay conexión Bluetooth activa');
    }
    
    try {
      Map<String, dynamic> message = {
        'type': 'bulk_reminder_sync',
        'data': reminders.map((r) => r.toMap()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      String jsonMessage = jsonEncode(message);
      List<int> messageBytes = utf8.encode(jsonMessage);
      
      // Split message if too large for single transmission
      const int chunkSize = 500; // Adjust based on your BLE constraints
      
      if (messageBytes.length > chunkSize) {
        // Send in chunks
        for (int i = 0; i < messageBytes.length; i += chunkSize) {
          int end = (i + chunkSize < messageBytes.length) ? i + chunkSize : messageBytes.length;
          List<int> chunk = messageBytes.sublist(i, end);
          await _characteristic!.write(chunk);
          await Future.delayed(Duration(milliseconds: 50)); // Small delay between chunks
        }
      } else {
        await _characteristic!.write(messageBytes);
      }
      
      print('Sent ${reminders.length} reminders to automotive device');
    } catch (e) {
      print('Error sending reminders: $e');
      throw e;
    }
  }

  void disconnect() {
    _connectedDevice?.disconnect();
    _connectedDevice = null;
    _characteristic = null;
    _isConnected = false;
  }

  bool get isConnected => _isConnected;
  String? get connectedDevice => _connectedDevice?.platformName;
}