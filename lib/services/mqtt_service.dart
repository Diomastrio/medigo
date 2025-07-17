import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../data/models/reminder.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  MqttServerClient? _client;
  bool _isConnected = false;

  // MQTT Configuration
  static const String _broker = 'broker.hivemq.com'; // Use HiveMQ public broker
  static const int _port = 1883; // Default MQTT port
  static const String _clientId = 'medigo_phone_app'; // Keep your client ID
  static const String _username = ''; // No username needed for public broker
  static const String _password = ''; // No password needed for public broker

  // Topics
  static const String _topicRemindersSync = 'medigo/reminders/sync';
  static const String _topicDoseConfirmation = 'medigo/dose/confirmation';
  static const String _topicConnectionStatus = 'medigo/connection/status';

  Future<void> initialize() async {
    try {
      _client = MqttServerClient(_broker, _clientId);
      _client!.port = _port;
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 20;
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onUnsubscribed = _onUnsubscribed;
      _client!.onSubscribed = _onSubscribed;
      _client!.onSubscribeFail = _onSubscribeFail;
      _client!.pongCallback = _pong;

      print('MQTT service initialized');
    } catch (e) {
      print('Error initializing MQTT service: $e');
      throw e;
    }
  }

  Future<void> connect() async {
    if (_client == null) {
      await initialize();
    }

    try {
      final connMess = MqttConnectMessage()
          .withClientIdentifier(_clientId)
          .withWillTopic('willtopic')
          .withWillMessage('My Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      
      if (_username.isNotEmpty && _password.isNotEmpty) {
        connMess.authenticateAs(_username, _password);
      }
      
      _client!.connectionMessage = connMess;

      await _client!.connect();
      
      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        _isConnected = true;
        print('MQTT client connected successfully');
        
        // Subscribe to relevant topics
        _subscribeToTopics();
        
        // Send connection status
        await _publishConnectionStatus(true);
      } else {
        print('MQTT connection failed - status: ${_client!.connectionStatus}');
        _isConnected = false;
      }
    } catch (e) {
      print('Error connecting to MQTT broker: $e');
      _isConnected = false;
      throw e;
    }
  }

  void _subscribeToTopics() {
    if (_client == null || !_isConnected) return;

    try {
      // Subscribe to topics that the phone app should listen to
      _client!.subscribe('$_topicDoseConfirmation/response', MqttQos.atLeastOnce);
      _client!.subscribe('$_topicConnectionStatus/automotive', MqttQos.atLeastOnce);
      
      // Listen for incoming messages
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        if (c != null) {
          for (var message in c) {
            _handleIncomingMessage(message);
          }
        }
      });
    } catch (e) {
      print('Error subscribing to MQTT topics: $e');
    }
  }

  void _handleIncomingMessage(MqttReceivedMessage<MqttMessage?> message) {
    try {
      final topic = message.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
        (message.payload as MqttPublishMessage).payload.message,
      );
      
      print('Received message on topic $topic: $payload');
      
      if (topic.contains('dose/confirmation/response')) {
        _handleDoseConfirmationResponse(payload);
      } else if (topic.contains('connection/status/automotive')) {
        _handleAutomotiveConnectionStatus(payload);
      }
    } catch (e) {
      print('Error handling incoming MQTT message: $e');
    }
  }

  void _handleDoseConfirmationResponse(String payload) {
    try {
      final data = jsonDecode(payload);
      print('Dose confirmation response: $data');
    } catch (e) {
      print('Error parsing dose confirmation response: $e');
    }
  }

  void _handleAutomotiveConnectionStatus(String payload) {
    try {
      final data = jsonDecode(payload);
      print('Automotive connection status: $data');
    } catch (e) {
      print('Error parsing automotive connection status: $e');
    }
  }

  Future<void> sendReminders(List<Reminder> reminders) async {
    if (!_isConnected || _client == null) {
      throw Exception('MQTT client not connected');
    }

    try {
      final message = {
        'type': 'reminders_sync',
        'timestamp': DateTime.now().toIso8601String(),
        'reminders': reminders.map((r) => r.toMap()).toList(),
      };

      final payload = jsonEncode(message);
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);

      _client!.publishMessage(_topicRemindersSync, MqttQos.atLeastOnce, builder.payload!);
      
      print('Sent ${reminders.length} reminders via MQTT');
    } catch (e) {
      print('Error sending reminders via MQTT: $e');
      throw e;
    }
  }

  Future<void> sendDoseConfirmation(Reminder reminder) async {
    if (!_isConnected || _client == null) {
      throw Exception('MQTT client not connected');
    }

    try {
      final message = {
        'type': 'dose_confirmation',
        'timestamp': DateTime.now().toIso8601String(),
        'reminder_id': reminder.id,
        'medicine_name': reminder.medicineName,
        'dose_details': '${reminder.doseCount} ${reminder.doseType}',
      };

      final payload = jsonEncode(message);
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);

      _client!.publishMessage(_topicDoseConfirmation, MqttQos.atLeastOnce, builder.payload!);
      
      print('Sent dose confirmation for ${reminder.medicineName}');
    } catch (e) {
      print('Error sending dose confirmation: $e');
      throw e;
    }
  }

  Future<void> _publishConnectionStatus(bool isConnected) async {
    if (_client == null) return;

    try {
      final message = {
        'device': 'phone',
        'connected': isConnected,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final payload = jsonEncode(message);
      final builder = MqttClientPayloadBuilder();
      builder.addString(payload);

      _client!.publishMessage('$_topicConnectionStatus/phone', MqttQos.atLeastOnce, builder.payload!);
    } catch (e) {
      print('Error publishing connection status: $e');
    }
  }

  void disconnect() {
    if (_client != null && _isConnected) {
      _publishConnectionStatus(false);
      _client!.disconnect();
    }
  }

  // Callback methods
  void _onConnected() {
    print('MQTT client connected');
    _isConnected = true;
  }

  void _onDisconnected() {
    print('MQTT client disconnected');
    _isConnected = false;
  }

  void _onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  void _onSubscribeFail(String topic) {
    print('Failed to subscribe to topic: $topic');
  }

  void _onUnsubscribed(String? topic) {
    print('Unsubscribed from topic: $topic');
  }

  void _pong() {
    print('MQTT Ping response received');
  }

  bool get isConnected => _isConnected;
}