import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local, on-device reminders. No account or paid service is required.
class MishkatNotificationService {
  MishkatNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'mishkat_reminders',
    'تذكيرات مشكاة',
    channelDescription: 'تنبيهات الصلاة والأذكار التي يختارها المستخدم',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
  );

  static NotificationDetails get _details =>
      const NotificationDetails(android: _androidDetails);

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      final zoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zoneName));
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
      _initialized = true;
    } catch (_) {
      // The app remains usable if the device or OS does not support notifications.
    }
  }

  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await initialize();
    if (!_initialized) return;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id, title, body, scheduled, _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id);

  static Future<void> scheduleDhikrWindow({
    required int intervalMinutes,
    required String phrase,
  }) async {
    await initialize();
    if (!_initialized) return;
    // Pre-schedule the next 72 hours. The app refreshes this window whenever
    // the reminder settings screen is opened or the app is restarted.
    for (var id = 3000; id < 3145; id++) {
      await _plugin.cancel(id);
    }
    final now = tz.TZDateTime.now(tz.local);
    final interval = Duration(minutes: intervalMinutes);
    final total = (72 * 60 / intervalMinutes).floor();
    for (var i = 1; i <= total; i++) {
      final when = now.add(interval * i);
      await _plugin.zonedSchedule(
        3000 + i,
        'تذكير من مشكاة',
        phrase,
        when,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelDhikrWindow() async {
    for (var id = 3000; id < 3145; id++) {
      await _plugin.cancel(id);
    }
  }

  static Future<void> scheduleAyatAfterPrayer(
      Map<String, DateTime> prayerTimes) async {
    await initialize();
    if (!_initialized) return;
    const prayers = ['الفجر', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
    for (var i = 0; i < prayers.length; i++) {
      await _plugin.cancel(2000 + i);
      final prayerTime = prayerTimes[prayers[i]];
      if (prayerTime == null) continue;
      final reminder = prayerTime.add(const Duration(minutes: 10));
      if (!reminder.isAfter(DateTime.now())) continue;
      await _plugin.zonedSchedule(
        2000 + i,
        'آية الكرسي',
        'حان وقت قراءة آية الكرسي بعد صلاة ${prayers[i]}',
        tz.TZDateTime.from(reminder, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
