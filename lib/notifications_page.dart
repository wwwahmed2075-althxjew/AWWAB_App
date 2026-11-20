import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

const _bg = Color(0xFF081629);
const _gold = Color(0xFFD9BD82);
const _muted = Color(0xFFB7B9C2);

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _dhikrEnabled = false;
  bool _morningEnabled = false;
  bool _eveningEnabled = false;
  int _interval = 120;
  String _phrase = 'سبحان الله وبحمده';
  TimeOfDay _morning = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _evening = const TimeOfDay(hour: 18, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dhikrEnabled = p.getBool('mishkat_dhikr_reminder_enabled') ?? false;
      _morningEnabled = p.getBool('mishkat_morning_reminder_enabled') ?? false;
      _eveningEnabled = p.getBool('mishkat_evening_reminder_enabled') ?? false;
      _interval = p.getInt('mishkat_dhikr_interval') ?? 120;
      _phrase = p.getString('mishkat_dhikr_phrase') ?? 'سبحان الله وبحمده';
      _morning = TimeOfDay(
        hour: p.getInt('mishkat_morning_hour') ?? 7,
        minute: p.getInt('mishkat_morning_minute') ?? 0,
      );
      _evening = TimeOfDay(
        hour: p.getInt('mishkat_evening_hour') ?? 18,
        minute: p.getInt('mishkat_evening_minute') ?? 0,
      );
      _loading = false;
    });
    await _applySchedules();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('mishkat_dhikr_reminder_enabled', _dhikrEnabled);
    await p.setBool('mishkat_morning_reminder_enabled', _morningEnabled);
    await p.setBool('mishkat_evening_reminder_enabled', _eveningEnabled);
    await p.setInt('mishkat_dhikr_interval', _interval);
    await p.setString('mishkat_dhikr_phrase', _phrase);
    await p.setInt('mishkat_morning_hour', _morning.hour);
    await p.setInt('mishkat_morning_minute', _morning.minute);
    await p.setInt('mishkat_evening_hour', _evening.hour);
    await p.setInt('mishkat_evening_minute', _evening.minute);
    await _applySchedules();
  }

  Future<void> _applySchedules() async {
    if (_dhikrEnabled) {
      await MishkatNotificationService.scheduleDhikrWindow(
        intervalMinutes: _interval,
        phrase: _phrase,
      );
    } else {
      await MishkatNotificationService.cancelDhikrWindow();
    }
    if (_morningEnabled) {
      await MishkatNotificationService.scheduleDaily(
        id: 4101,
        title: 'أذكار الصباح',
        body: 'ابدأ يومك بذكر الله',
        hour: _morning.hour,
        minute: _morning.minute,
      );
    } else {
      await MishkatNotificationService.cancel(4101);
    }
    if (_eveningEnabled) {
      await MishkatNotificationService.scheduleDaily(
        id: 4102,
        title: 'أذكار المساء',
        body: 'لا تنس أذكار المساء',
        hour: _evening.hour,
        minute: _evening.minute,
      );
    } else {
      await MishkatNotificationService.cancel(4102);
    }
  }

  Future<void> _pickTime(bool morning) async {
    final current = morning ? _morning : _evening;
    final picked = await showTimePicker(context: context, initialTime: current);
    if (picked == null) return;
    setState(() {
      if (morning) {
        _morning = picked;
      } else {
        _evening = picked;
      }
    });
    await _save();
  }

  Widget _card(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xB8182B43),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: _gold.withOpacity(.32)),
    ),
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text('التنبيهات والتذكير'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          _card(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('التذكير بالذكر',
                  style: TextStyle(color: _gold, fontWeight: FontWeight.w800)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تفعيل التذكير الدوري'),
                value: _dhikrEnabled,
                onChanged: (v) async {
                  setState(() => _dhikrEnabled = v);
                  await _save();
                },
              ),
              const Text('الفاصل الزمني',
                  style: TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 7),
              DropdownButtonFormField<int>(
                value: _interval,
                dropdownColor: const Color(0xFF14243A),
                items: const [
                  DropdownMenuItem(value: 30, child: Text('كل نصف ساعة')),
                  DropdownMenuItem(value: 120, child: Text('كل ساعتين')),
                ],
                onChanged: (v) async {
                  if (v == null) return;
                  setState(() => _interval = v);
                  await _save();
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _phrase,
                dropdownColor: const Color(0xFF14243A),
                decoration: const InputDecoration(labelText: 'الذكر'),
                items: const [
                  DropdownMenuItem(
                    value: 'سبحان الله وبحمده',
                    child: Text('سبحان الله وبحمده'),
                  ),
                  DropdownMenuItem(
                    value: 'سبحان الله العظيم',
                    child: Text('سبحان الله العظيم'),
                  ),
                  DropdownMenuItem(
                    value: 'لا حول ولا قوة إلا بالله',
                    child: Text('لا حول ولا قوة إلا بالله'),
                  ),
                  DropdownMenuItem(
                    value: 'اللهم صل وسلم على نبينا محمد',
                    child: Text('الصلاة على النبي ﷺ'),
                  ),
                ],
                onChanged: (v) async {
                  if (v == null) return;
                  setState(() => _phrase = v);
                  await _save();
                },
              ),
              const Padding(
                padding: EdgeInsets.only(top: 9),
                child: Text(
                  'تُجدول التذكيرات القادمة لثلاثة أيام، ويُعاد تجديدها عند فتح التطبيق.',
                  style: TextStyle(color: _muted, fontSize: 10, height: 1.6),
                ),
              ),
            ],
          )),
          _card(Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تذكير أذكار الصباح'),
                subtitle: Text(_morning.format(context),
                    style: const TextStyle(color: _muted)),
                value: _morningEnabled,
                onChanged: (v) async {
                  setState(() => _morningEnabled = v);
                  await _save();
                },
                secondary: IconButton(
                  onPressed: () => _pickTime(true),
                  icon: const Icon(Icons.schedule, color: _gold),
                ),
              ),
            ],
          )),
          _card(Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تذكير أذكار المساء'),
                subtitle: Text(_evening.format(context),
                    style: const TextStyle(color: _muted)),
                value: _eveningEnabled,
                onChanged: (v) async {
                  setState(() => _eveningEnabled = v);
                  await _save();
                },
                secondary: IconButton(
                  onPressed: () => _pickTime(false),
                  icon: const Icon(Icons.schedule, color: _gold),
                ),
              ),
            ],
          )),
          _card(const Text(
            'يمكن جدولة آية الكرسي بعد مواقيت الصلاة التي تم حسابها. يجب السماح بإشعارات التطبيق من إعدادات Android.',
            style: TextStyle(color: _muted, fontSize: 11, height: 1.7),
          )),
        ],
      ),
    );
  }
}
