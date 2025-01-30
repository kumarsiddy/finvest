import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bondgrid/services/storage_service.dart';
import 'package:bondgrid/constants/storage_constants.dart';

class PushNotificationHelper {
  static String fcmToken = "";
  static Future<void> initialized() async {
    await Firebase.initializeApp();

    FirebaseMessaging.instance.requestPermission(
        alert: true,
        sound: true,
        badge: true,
        announcement: true,
        criticalAlert: true);

    if (Platform.isAndroid) {
      NotificationHelper.initialized();
    }

    getDeviceTokenToSendNotification();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      return NavigatorScreen(
        selectedIndex: 0,
      );
      // additional logic to handle the app interaction when notification is opened while app is in terminated state
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // additional logic to handle the app interaction when notification is opened while app is in background state
    });

    // while app is open
    FirebaseMessaging.onMessage.listen((message) {
      if (Platform.isAndroid) {
        NotificationHelper.displayNotification(message);
      }
    });
  }

  static Future<String> getDeviceTokenToSendNotification() async {
    fcmToken = (await FirebaseMessaging.instance.getToken()).toString();

    await StorageService.storeItem(
        StorageConstants.fcmToken, {'token': fcmToken});

    return fcmToken;
  }
}

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialized() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/launch_image');

    flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(android: initializationSettingsAndroid));
  }

  static void displayNotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const notificationIconColor = Color.fromARGB(1, 56, 86, 221);
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails("finvest", "finvest_channel",
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/notification_icon',
            color: notificationIconColor),
      );

      await flutterLocalNotificationsPlugin.show(
          id,
          message.notification!.title,
          message.notification!.body,
          notificationDetails,
          payload: json.encode(message.data));
    } on Exception catch (e) {
      print(e);
    }
  }
}
