import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'awwab_prayer_service.dart';

class AwwabNotificationService {
  AwwabNotificationService._();
  static final AwwabNotificationService instance = AwwabNotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _permissionRequested = false;

  Future<void> initialise({bool requestPermission = false}) async {
    if (!_ready) {
      tzdata.initializeTimeZones();
      try {
        final localTimezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      }
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      _ready = true;
    }
    if (requestPermission && !_permissionRequested) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      _permissionRequested = true;
    }
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await initialise(requestPermission: true);
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'awwab_reminders',
          'تذكيرات أوّاب',
          channelDescription: 'تذكيرات الأذكار والعبادات',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWeekly({
    required int id,
    required List<int> weekdays,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await initialise(requestPermission: true);
    for (var weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(id * 10 + weekday);
    }
    final now = tz.TZDateTime.now(tz.local);
    for (final weekday in weekdays.toSet()) {
      if (weekday < 1 || weekday > 7) continue;
      var daysAhead = (weekday - now.weekday + 7) % 7;
      var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute)
          .add(Duration(days: daysAhead));
      if (!next.isAfter(now)) next = next.add(const Duration(days: 7));
      await _plugin.zonedSchedule(
        id * 10 + weekday,
        title,
        body,
        next,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'awwab_reminders',
            'تذكيرات أوّاب',
            channelDescription: 'تذكيرات الأذكار والعبادات',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> scheduleAt({
    required int id,
    required DateTime time,
    required String title,
    required String body,
    bool requestPermission = false,
  }) async {
    await initialise(requestPermission: requestPermission);
    final scheduled = tz.TZDateTime.from(time, tz.local);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'awwab_prayer_reminders',
          'تذكير بعد الصلاة',
          channelDescription: 'التذكير بقراءة آية الكرسي بعد الصلاة المكتوبة',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> refreshPrayerAyatReminders({
    required double latitude,
    required double longitude,
    bool requestPermission = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('reminder_item_405') ?? false)) return;
    await initialise(requestPermission: requestPermission);
    const baseId = 5000;
    for (var day = 0; day < 30; day++) {
      for (var prayer = 0; prayer < 5; prayer++) {
        await _plugin.cancel(baseId + day * 5 + prayer);
      }
    }
    final now = DateTime.now();
    for (var day = 0; day < 30; day++) {
      final date = now.add(Duration(days: day));
      final prayerTimes = AwwabPrayerSchedule.obligatoryPrayerTimesForDate(
        latitude: latitude,
        longitude: longitude,
        date: date,
      );
      for (var prayer = 0; prayer < prayerTimes.length; prayer++) {
        await scheduleAt(
          id: baseId + day * 5 + prayer,
          time: prayerTimes[prayer].add(const Duration(minutes: 2)),
          title: 'لا تنسَ آية الكرسي',
          body: 'تذكير بقراءة آية الكرسي بعد الصلاة المكتوبة.',
        );
      }
    }
  }

  Future<void> cancel(int id) async {
    await initialise();
    await _plugin.cancel(id);
  }

  Future<void> saveReminder({
    required String key,
    required int id,
    required bool enabled,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_$key', enabled);
    await prefs.setInt('reminder_${key}_hour', hour);
    await prefs.setInt('reminder_${key}_minute', minute);
    if (enabled) {
      await scheduleDaily(id: id, title: title, body: body, hour: hour, minute: minute);
    } else {
      await cancel(id);
    }
  }
}
