import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permissions
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Get FCM token
    String? token = await _fcm.getToken();
    if (kDebugMode) print("FCM Token: $token");

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle app opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print("Foreground Notification: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
    }

    // Show local notification
    await _showLocalNotification(message);
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    if (kDebugMode) {
      print("Notification opened app: ${message.notification?.title}");
    }
    // Handle navigation based on notification data
    _handleNotificationNavigation(message);
  }

  Future<void> _handleInitialMessage(RemoteMessage? message) async {
    if (message != null && kDebugMode) {
      print("App opened from terminated state: ${message.notification?.title}");
    }
    if (message != null) {
      _handleNotificationNavigation(message);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'hirelink_channel',
      'HireLink Notifications',
      channelDescription: 'Notifications for job applications and messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'HireLink',
      message.notification?.body ?? 'You have a new notification',
      details,
      payload: message.data.toString(),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) print("Notification tapped: ${response.payload}");
    // Handle navigation when notification is tapped
    if (response.payload != null) {
      // Parse payload and navigate accordingly
    }
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    // Navigate based on notification type
    switch (type) {
      case 'job_application':
        // Navigate to applications screen
        break;
      case 'message':
        // Navigate to chat screen
        break;
      case 'job_posted':
        // Navigate to job details
        break;
      default:
        // Navigate to notifications screen
        break;
    }
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
  }
}
