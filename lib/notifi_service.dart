import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart';

class LocalNotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static int notificationIdCounter = 0;
  

  Future<void> initializeNotification() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/icon_todo');

    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    Future<bool> requestNotificationPermission() async {
      final status = await Permission.notification.request();
      return status.isGranted;
    }

    await requestNotificationPermission();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<void> showNotify(String remindOption, String nameTodo,
      DateTime selectedDay, TimeOfDay selectedTime) async {
    Duration _timeInterval;
    String _time;


    if (remindOption == 'In 24 hours') {
      _timeInterval = const Duration(hours: 24);
      _time = 'will be in 24 hours';
    } else if (remindOption == 'An hour before') {
      _timeInterval = const Duration(hours: 1);
      _time = 'will be in hour';
    } else {
      _timeInterval = const Duration(minutes: 15);
      _time = 'will be in 15 minutes';
    }
    //
    final scheduleDateTime = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      selectedTime.hour,
      selectedTime.minute,
    ).subtract(_timeInterval);

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationIdCounter,
      'ToDo remind: $nameTodo',
      'Your ToDo $_time',
      TZDateTime.from(scheduleDateTime, local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'your_custom_data',
    );

    notificationIdCounter++;
  }


}
