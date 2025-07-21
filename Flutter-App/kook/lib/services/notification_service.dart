import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
      
  Future<void> init() async {
    // Initialize time zones
    tz_data.initializeTimeZones();
    
    // Initialize notification settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Initialize notification settings for iOS
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      // Don't request permissions at startup, we'll do it later in home screen
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    
    // Combine platform-specific settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    // Initialize notifications plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  // Request notification permissions (to be called from HomeScreen)
  // Fixed version that doesn't use the missing requestPermission() method
  Future<bool> requestPermissions() async {
    // For iOS, explicitly request permissions
    if (Platform.isIOS) {
      final bool? iosPermission = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return iosPermission ?? false;
    }
    
    // For Android, we'll assume permission is granted
    // Android will ask for permission when the first notification is shown if needed
    return true;
  }
  
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap - could navigate to specific screen
    print('Notification tapped: ${notificationResponse.payload}');
  }
  
  // Schedule mining reminder notification
  Future<void> scheduleMiningReminderNotification(DateTime miningEndTime) async {
    // Calculate when to send the notification (1 hour before mining ends)
    final oneHourBefore = miningEndTime.subtract(const Duration(hours: 1));
    final now = DateTime.now();
    
    // Only schedule if the one hour mark hasn't passed yet
    if (oneHourBefore.isAfter(now)) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0, // notification id
        'Mining Reminder',
        'Your mining session will finish in about 1 hour',
        tz.TZDateTime.from(oneHourBefore, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'mining_reminder_channel',
            'Mining Reminders',
            channelDescription: 'Notifications about mining sessions',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'mining_end',
      );
      
      print('Scheduled mining reminder notification for $oneHourBefore');
    } else {
      print('One hour before mark already passed, not scheduling notification');
    }
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}