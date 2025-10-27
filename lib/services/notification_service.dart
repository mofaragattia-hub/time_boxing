import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // Initialize time zones for scheduled notifications to use device local time
    try {
      tz.initializeTimeZones();
    } catch (_) {
      // ignore repeated initialization
    }
  }

  Future<void> showNotification(
    String title,
    String body,
    int notificationId,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'timeboxing_channel',
          'Timeboxing',
          channelDescription: 'Channel for Timeboxing notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleNotification({
    required DateTime scheduledDateTime,
    required String title,
    required String body,
    required int notificationId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'timeboxing_channel',
          'Timeboxing',
          channelDescription: 'Channel for Timeboxing notifications',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final tzDateTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
    
    try {
      // Try exact scheduling first
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      // Fallback to approximate scheduling if exact alarms not permitted
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    }  }
}
