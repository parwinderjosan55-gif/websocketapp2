import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class notificationservice {
  final FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iossetting = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iossetting,
    );

    await localNotificationsPlugin.initialize(settings: settings);

    final androidPlugin = localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'important_message_channel',
        'Important Messages',
        description: 'Notification channel for incoming messages',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> shownotification({
    int id = 0,
    String title = "New Message",
    String body = "",
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      "important_message_channel",
      "Important Messages",
      channelDescription: "Notification channel for incoming messages",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );
    const DarwinNotificationDetails iosnotification = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentBanner: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosnotification,
    );

    await localNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}
