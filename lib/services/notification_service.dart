import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Define the channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'todo_channel', // id
    'Task Reminders', // title
    description: 'Channel for task reminders.', // description
    importance: Importance.max,
  );

  static Future<void> init() async {
    // 1. Initialize Timezones
    tz.initializeTimeZones();

    // 2. Create Channel
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);

    // 3. Initialize Plugin
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _notificationsPlugin.initialize(settings);

    // 4. Request Permissions
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Request post notifications permission
      final bool? postNotificationGranted = await androidPlugin
          .requestNotificationsPermission();

      // Request exact alarm permission
      final bool? exactAlarmsGranted = await androidPlugin
          .requestExactAlarmsPermission();

      if (postNotificationGranted == false || exactAlarmsGranted == false) {
        Fluttertoast.showToast(
          msg:
              "Notifications and Alarms are required for reminders. Please enable them in settings.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
        // Optionally open settings after a delay
        await Future.delayed(const Duration(seconds: 2));
        await openAppSettings();
      }
    }
  }

  static Future<void> showInstantNotification(String title, String body) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channel.id, // Use channel ID
          _channel.name, // Use channel name
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformDetails,
    );
  }

  static Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, // Use channel ID
          _channel.name, // Use channel name
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async =>
      await _notificationsPlugin.cancel(id);
}
