
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
}

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;


Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel =  const AndroidNotificationChannel(
    "0" ,// id
    'notifaction', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
    print("notiicaton----$message");
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
    print("notiicaton----$message");
  });
  isFlutterLocalNotificationsInitialized = true;
}



void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(Application());
}


class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {


/*
  Future<void> sendPushMessage() async {
    try {
      String? token = await FirebaseMessaging.instance.getAPNSToken();

      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; '
              'charset=UTF-8',
          'Authorization': ' $token',

        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }
*/


  void getToken()async{
    // token = FirebaseMessaging.instance.getAPNSToken() as String?;
    var token = await FirebaseMessaging.instance.getToken();
    print("token :---------$token");
   /* var headers = <String,String>{
      "Content-Type":"application/json",
      "Authorization":"key=AAAAiTaGLBE:APA91bEg909LqsKH9KtWJe2p541lUR9Yg0vOueXlWP1Szb3B8uiw4nTjiiIi079xsRl3bKZU6zvuclqtdwZQNYslCRJYS665d2hOuUt61soVI9mODkQVoDZpB2ZxRmLQI4udwIgssLls"
    };
    var body = <String, dynamic>{
      "to" :"$token",
      "notification":{
        "data" : "hello",
        "title":"Notification Demo"
      }
    };
    
    var response = await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers:headers,
        body:jsonEncode(body)

    );*/

    Future.delayed(const Duration(seconds: 10),() async{
      var response = await http.post(Uri.parse
        ( 'https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAiTaGLBE:APA91bEg909LqsKH9KtWJe2p541lUR9Yg0vOueXlWP1Szb3B8uiw4nTjiiIi079xsRl3bKZU6zvuclqtdwZQNYslCRJYS665d2hOuUt61soVI9mODkQVoDZpB2ZxRmLQI4udwIgssLls',
        },
        body: jsonEncode(
          <String, dynamic>{
            "notification": <String, dynamic>{
              "body": "notifiva6oppb", // New artical has been post in EventChannel
              "title": "hello"
            },
            "priority": "normal",
            "to": "$token",
          },
        ),
      );
      print("response-----${response.statusCode}");
      print("response-----${response.body}");
    },);



    
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
              getToken();
              FirebaseMessaging.instance.getInitialMessage();
            },
            child:const Text('send Notification'),
          ),
        ),
      ),
    );
  }
}

