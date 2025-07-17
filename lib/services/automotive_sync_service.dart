import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database_helper.dart';
import '../data/models/reminder.dart';

class AutomotiveSyncService {
  static final AutomotiveSyncService _instance = AutomotiveSyncService._internal();
  factory AutomotiveSyncService() => _instance;
  AutomotiveSyncService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  static const String REMINDERS_KEY = 'medigo_reminders_sync';
  static const String LAST_SYNC_KEY = 'medigo_last_sync';

  Future<void> syncRemindersToAutomotive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reminders = await _dbHelper.getReminders();
      
      // Convert reminders to JSON
      final remindersJson = reminders.map((r) => r.toMap()).toList();
      
      // Store in shared preferences
      await prefs.setString(REMINDERS_KEY, jsonEncode(remindersJson));
      await prefs.setString(LAST_SYNC_KEY, DateTime.now().toIso8601String());
      
      print('Synced ${reminders.length} reminders to automotive');
    } catch (e) {
      print('Error syncing reminders: $e');
    }
  }

  Future<List<Reminder>> getRemindersFromPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remindersJson = prefs.getString(REMINDERS_KEY);
      
      if (remindersJson != null) {
        final List<dynamic> remindersList = jsonDecode(remindersJson);
        return remindersList.map((r) => Reminder.fromMap(Map<String, dynamic>.from(r))).toList();
      }
    } catch (e) {
      print('Error getting reminders from phone: $e');
    }
    return [];
  }

  Future<void> markReminderTaken(int reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final takenKey = 'medigo_taken_$reminderId';
      await prefs.setBool(takenKey, true);
      await prefs.setString('${takenKey}_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error marking reminder taken: $e');
    }
  }

  Future<bool> isReminderTaken(int reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('medigo_taken_$reminderId') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> syncReminderTakenStatus(int reminderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final takenKey = 'medigo_taken_$reminderId';
      final timestampKey = '${takenKey}_timestamp';
      
      // Sync the taken status back to the main database if needed
      final isTaken = await isReminderTaken(reminderId);
      if (isTaken) {
        final reminder = await _getReminderById(reminderId);
        if (reminder != null) {
          await _dbHelper.addDoseHistory(reminder);
        }
      }
    } catch (e) {
      print('Error syncing taken status: $e');
    }
  }

  Future<Reminder?> _getReminderById(int reminderId) async {
    try {
      final reminders = await getRemindersFromPhone();
      return reminders.where((r) => r.id == reminderId).firstOrNull;
    } catch (e) {
      print('Error getting reminder by ID: $e');
      return null;
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(LAST_SYNC_KEY);
      if (lastSyncString != null) {
        return DateTime.parse(lastSyncString);
      }
    } catch (e) {
      print('Error getting last sync time: $e');
    }
    return null;
  }

  Future<void> clearTakenStatuses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('medigo_taken_')).toList();
      for (String key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing taken statuses: $e');
    }
  }
}