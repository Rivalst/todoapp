import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class LocalNotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static int notificationIdCounter = 0;
  DateTime scheduleDateTime = DateTime.now();

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

    scheduleDateTime = DateTime(
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
      tz.TZDateTime.from(scheduleDateTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'your_custom_data',
    );
    notificationIdCounter++;

    print('show work');
    try{
      var token = await FirebaseMessaging.instance.getToken();
      final body = jsonEncode(<String, dynamic>{
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done',
          'body': 'nameToDo',
          'title': 'Your ToDo time',
        },
        'notification': <String, dynamic>{
          'title': 'Remind: $nameTodo',
          'body': 'Your ToDo $_time',
        },
        'to': token
      });
      print('still work');

      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAevwX-Js:APA91bFzJE_D6-Co-HnmVozA-GtOzZcu4ley4Uu9esYmxbb7H8Ay8LzN4Dyi1b7ErtrkN9AtMNUPUcPFj7ch_XyKS3A6IRCtfOGK358WIHgr_3Zm0r1YmPZcoSn3gAH6S7D049HY3ViA'
          },
          body: body
      );
      print('send push done');
    } catch (e) {
      print('error $e');
    }
  }

  // Future<void> showPushNotify() async {
  //   print('show work');
  //   try{
  //     var token = await FirebaseMessaging.instance.getToken();
  //     final body = jsonEncode(<String, dynamic>{
  //       'priority': 'high',
  //       'data': <String, dynamic>{
  //         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //         'status': 'done',
  //         'body': 'nameToDo',
  //         'title': 'Your ToDo time'
  //       },
  //       'notification': <String, dynamic>{
  //         'title': 'nameToDo-to',
  //         'body': 'Your ToDo time',
  //       },
  //       'to': token
  //     });
  //     print('still work');
  //
  //     await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
  //         headers: {
  //           HttpHeaders.contentTypeHeader: 'application/json',
  //           HttpHeaders.authorizationHeader:
  //           'key=AAAAevwX-Js:APA91bFzJE_D6-Co-HnmVozA-GtOzZcu4ley4Uu9esYmxbb7H8Ay8LzN4Dyi1b7ErtrkN9AtMNUPUcPFj7ch_XyKS3A6IRCtfOGK358WIHgr_3Zm0r1YmPZcoSn3gAH6S7D049HY3ViA'
  //         },
  //         body: body
  //     );
  //     print('send push done');
  //   } catch (e) {
  //     print('error $e');
  //   }
  // }
}
