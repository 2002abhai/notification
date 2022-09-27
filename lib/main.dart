import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Application());
}

class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {

  @override
  void initState() {
    super.initState();
    NotificationListenerProvider().getMessage(context);
  }


  void sendNotification() async {
    var token = await FirebaseMessaging.instance.getToken();
    String? title = "hello";
    String? body = "Notification";

    Future.delayed(
      const Duration(seconds: 10),
      () async {
         await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAAiTaGLBE:APA91bEg909LqsKH9KtWJe2p541lUR9Yg0vOueXlWP1Szb3B8uiw4nTjiiIi079xsRl3bKZU6zvuclqtdwZQNYslCRJYS665d2hOuUt61soVI9mODkQVoDZpB2ZxRmLQI4udwIgssLls',
          },
          body: jsonEncode(
            <String, dynamic>{
              "notification": <String, dynamic>{
                "body": body,
                "title": title
              },
              "priority": "normal",
              "to": "$token",
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cloud Messaging'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              sendNotification();
            },
            child: const Text('send Notification'),
          ),
        ),
      ),
    );
  }
}

void sendNotification( {String? title, String? body}) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');


  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,);

  ///
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_channel', 'High Importance Notification',
      description: "This channel is for important notification",
      importance: Importance.max);

  flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description),
    ),
  );
}

class NotificationListenerProvider {
  final _firebaseMessaging = FirebaseMessaging.instance.getInitialMessage();

  void getMessage(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      RemoteNotification notification = event.notification!;
      AndroidNotification androidNotification = event.notification!.android!;

      if (notification != null && androidNotification != null) {

        sendNotification(title: notification.title!, body: notification.body);

      }
    });
  }
}
