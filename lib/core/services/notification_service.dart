import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({bool requestPermissionOnInit = true}) async {
    tz.initializeTimeZones();
    final String timeZoneName =
        (await FlutterTimezone.getLocalTimezone()).identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: requestPermissionOnInit,
          requestBadgePermission: requestPermissionOnInit,
          requestSoundPermission: requestPermissionOnInit,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> requestNotificationPermission() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required String title,
    required String body,
    required DateTime scheduleTime,
  }) async {
    // Avoid scheduling in the past
    if (scheduleTime.isBefore(DateTime.now())) return;

    final settings =
        await SharedPreferencesHelper.getPrayerNotificationSettings(prayerName);

    final bool isAllowed = settings?['isAllowed'] != false;
    if (!isAllowed) return;

    final List<int> selectedDays = (settings?['selectedDays'] is List)
        ? (settings?['selectedDays'] as List)
              .map((e) => int.tryParse(e.toString()) ?? -1)
              .where((e) => e >= 0 && e <= 6)
              .toList()
        : <int>[0, 1, 2, 3, 4, 5, 6];

    final int dayIndex = scheduleTime.weekday == DateTime.sunday
        ? 6
        : scheduleTime.weekday - 1;
    if (!selectedDays.contains(dayIndex)) return;

    final String notificationSound =
        (settings?['notificationSound'] ?? 'Adhan(Makkah)').toString();
    final normalized = notificationSound.toLowerCase();
    final bool playSound =
        !normalized.contains('without') && !normalized.contains('silent');

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_reminders',
        'Prayer Reminders',
        channelDescription: 'Notifications for prayer times',
        importance: Importance.max,
        priority: Priority.high,
        playSound: playSound,
        sound: playSound
            ? const RawResourceAndroidNotificationSound('adhan')
            : null,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
        sound: playSound ? 'adhan.caf' : null,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'verse_of_day',
          'Verse of the Day',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleDailyMemorizationReminder({
    required int hour,
    required int minute,
  }) async {
    const int reminderId = 99001;
    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await _notificationsPlugin.zonedSchedule(
      id: reminderId,
      title: 'Daily Practice Reminder',
      body: 'Time for your Quran memorization practice.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_memorization_reminder',
          'Daily Memorization Reminder',
          channelDescription: 'Daily reminder for Quran memorization practice',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
