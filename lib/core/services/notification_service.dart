import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const String _notificationIcon = 'launcher_icon';
  static const String _fallbackIcon = 'ic_launcher';
  static String _validatedIcon = _notificationIcon;

  static const MethodChannel _settingsChannel = MethodChannel('com.example.daily_water_reminder/settings');
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings(_notificationIcon);
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
        },
      );
      _validatedIcon = _notificationIcon;
      await _createChannel();
    } catch (e) {
      // Fallback to default flutter icon if launcher_icon is not available
      try {
        const AndroidInitializationSettings fallbackSettings =
            AndroidInitializationSettings(_fallbackIcon);
        const InitializationSettings initSettings = InitializationSettings(
          android: fallbackSettings,
          iOS: DarwinInitializationSettings(),
        );
        await _notificationsPlugin.initialize(initSettings);
        _validatedIcon = _fallbackIcon;
      } catch (fallbackError) {
        // Notification initialization failed
      }
    }
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      final location = tz.getLocation(timeZoneName);
      tz.setLocalLocation(location);
    } catch (e) {
      // Fallback to UTC if timezone detection fails
      tz.setLocalLocation(tz.UTC);
    }
  }

  static Future<Map<String, bool>> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool notificationsGranted = false;
    bool exactAlarmGranted = true;

    if (androidImplementation != null) {
      notificationsGranted = await androidImplementation.requestNotificationsPermission() ?? false;

      try {
        final bool? canSchedule = await _settingsChannel.invokeMethod<bool>('canScheduleExactAlarms');
        exactAlarmGranted = canSchedule ?? true;
      } catch (e) {
        // Error checking exact alarm status
      }
    }

    final bool? iosGranted = await _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return {
      'notifications': notificationsGranted || (iosGranted ?? false),
      'exactAlarm': exactAlarmGranted,
    };
  }

  static Future<bool> openBatteryOptimizationSettings() async {
    try {
      final bool? result = await _settingsChannel.invokeMethod<bool>('openBatteryOptimizationSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> openExactAlarmSettings() async {
    try {
      final bool? result = await _settingsChannel.invokeMethod<bool>('openExactAlarmSettings');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _createChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'water_reminder_channel',
      'Water Reminders',
      description: 'Stay hydrated with timely reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(channel);
    }
  }

  static Future<void> scheduleReminders({int? intervalMinutes, int? intervalHours}) async {
    final int minutes = intervalMinutes ?? (intervalHours ?? 1) * 60;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'water_reminder_channel',
      'Water Reminders',
      channelDescription: 'Stay hydrated with timely reminders',
      importance: Importance.max,
      priority: Priority.high,
      icon: _validatedIcon,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      styleInformation: const BigTextStyleInformation(''),
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await cancelAll();

    const int instances = 100;
    int scheduledCount = 0;

    for (int i = 1; i <= instances; i++) {
      try {
        final scheduledTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: i * minutes));
        await _notificationsPlugin.zonedSchedule(
          i,
          '💧 Drink Water',
          'Stay hydrated! Time for a refreshing glass of water.',
          scheduledTime,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        scheduledCount++;
      } catch (e) {
        if (i == 1) rethrow;
      }
    }
  }

  static Future<int> getPendingNotificationCount() async {
    final List<PendingNotificationRequest> pending =
        await _notificationsPlugin.pendingNotificationRequests();
    return pending.length;
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
