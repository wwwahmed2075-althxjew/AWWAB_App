import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class AwwabNotificationService {
  AwwabNotificationService._();
  static final AwwabNotificationService instance = AwwabNotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialise() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await initialise();
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

  Future<void> scheduleAt({
    required int id,
    required DateTime time,
    required String title,
    required String body,
  }) async {
    await initialise();
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
