import 'dart:convert'; // Import dart:convert

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../data/models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - you can navigate to confirmation screen here
    print('Notification tapped: ${response.payload}');

    if (response.actionId == 'snooze_action' && response.payload != null) {
      final reminderMap = jsonDecode(response.payload!);
      final reminder = Reminder.fromMap(reminderMap);
      _scheduleSnoozedNotification(reminder);
    }
  }

  Future<void> _scheduleSnoozedNotification(Reminder reminder) async {
    const androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Notifications for medicine reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('snooze_action', 'Snooze 5 min'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id ?? 0, // Use the same ID to replace the original
      'Tiempo de tomar tu medicamento',
      '${reminder.medicineName} - ${reminder.doseCount} ${reminder.doseType}',
      tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5)),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode(reminder.toMap()), // Pass reminder data
    );
  }

  Future<void> scheduleReminderNotification(Reminder reminder) async {
    // Parse the time string (format: "HH:mm")
    final timeParts = reminder.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Schedule for today first, then daily
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Notifications for medicine reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('snooze_action', 'Snooze 5 min'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      reminder.id ?? 0,
      'Tiempo de tomar tu medicamento',
      '${reminder.medicineName} - ${reminder.doseCount} ${reminder.doseType}',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: jsonEncode(reminder.toMap()),
    );
  }

  Future<void> cancelReminderNotification(int reminderId) async {
    await _notifications.cancel(reminderId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
