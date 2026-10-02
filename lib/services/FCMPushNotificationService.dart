import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:websocketapp2/main.dart';
import 'package:websocketapp2/services/firebaseservice.dart';
import 'package:websocketapp2/services/notificationservice.dart';
                                                    // this code decide which how many type of notification can receive on phone
                                                    // like screen should be off or locked and should be open so many thing
@pragma('vm:entry-point')                          // this code about screen off and screen locked receive the notification
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
await notificationservice().shownotification(
  title:message.notification?.title?? "new message",
  body: message.notification?.body?? '',
);
   }

   Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler,);
  await notificationservice().init();
  runApp(const MyApp());
   }                                               //end of this code


class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseService _firebaseService = FirebaseService();

  final String backendUrl = 'http://10.0.2.2:3000/send-notification';

  Future<void> init() async {
    await notificationservice().init();          //initialize fcm code

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint("Permission status: ${settings.authorizationStatus}");

    String? token = await _messaging.getToken();   //get this user fcm token
    debugPrint("FCM Token: $token");

    if (token != null) {
      await _updateFCMToken(token);
    }

    _messaging.onTokenRefresh.listen((newToken) {
      _updateFCMToken(newToken);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


    /*FirebaseMessaging.onMessage.listen((RemoteMessage message) { // receive notification when app is open
      debugPrint("Foreground message received: ${message.notification?.title}");
      final title = message.notification?.title ?? message.data['title'] ?? "New Message";
      final body = message.notification?.body ?? message.data['body'] ?? "";
      notificationservice().shownotification(title: title, body: body);
    });*/

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {  // user tap on notification
      debugPrint("Notification clicked: ${message.messageId}");
    });                                                                // here is the end of that type of notification  code
  }

  Future<void> _updateFCMToken(String token) async {
    try {
      final currentUser = _firebaseService.firebaseAuth.currentUser;
      if (currentUser != null) {

        await _firebaseService.firestore
            .collection('users')
            .doc(currentUser.uid)
            .set({'fcmToken': token}, SetOptions(merge: true));
        debugPrint("Successfully updated FCM token for user ${currentUser.uid}");
      }
    } catch (e) {
      debugPrint("Error updating FCM token: $e");
    }
  }

  Future<String?> gettoken() async {
    return await _messaging.getToken();
  }

  Future<void> sendNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'title': title,
          'body': body,
          'priority': 'high',
          'data': {
            'title': title,
            'body': body,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK'
          }
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("Notification sent successfully via backend");
      } else {
        debugPrint("Failed to send notification: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error calling backend: $e");
    }
  }
}

typedef fcmservice = FcmService;
