import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/home/mishkat_home_page.dart';

void main() {
  const prayers = [
    MishkatPrayerTime(name: 'الفجر', time: '04:30 ص', icon: Icons.nights_stay, isNext: true, countdown: '00:24:10'),
    MishkatPrayerTime(name: 'الشروق', time: '06:02 ص', icon: Icons.wb_sunny_outlined),
    MishkatPrayerTime(name: 'الظهر', time: '12:05 م', icon: Icons.wb_sunny),
    MishkatPrayerTime(name: 'العصر', time: '03:20 م', icon: Icons.sunny),
    MishkatPrayerTime(name: 'المغرب', time: '06:11 م', icon: Icons.wb_twilight),
    MishkatPrayerTime(name: 'العشاء', time: '07:35 م', icon: Icons.nights_stay_outlined),
    MishkatPrayerTime(name: 'قيام الليل', time: 'حسب الإعداد', icon: Icons.nightlight_round),
  ];

  const daily = [
    MishkatDailyItem(title: 'آية اليوم', content: 'نص آية موثقة يمررها التطبيق المضيف', icon: Icons.menu_book),
    MishkatDailyItem(title: 'حديث اليوم', content: 'نص حديث موثق يمرره التطبيق المضيف', icon: Icons.auto_stories),
    MishkatDailyItem(title: 'دعاء اليوم', content: 'دعاء موثق يمرره التطبيق المضيف', icon: Icons.volunteer_activism),
  ];

  testWidgets('renders separate prayer cards and single daily/shortcut sections', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MishkatHomePage(
          locationLabel: 'القاهرة، مصر',
          gregorianDate: 'الجمعة 20 نوفمبر 2026',
          hijriDate: '10 جمادى الآخرة 1448 هـ',
          prayerTimes: prayers,
          dailyItems: daily,
          onQuran: () {},
          onAzkar: () {},
          onTasbeeh: () {},
          onMore: () {},
        ),
      ),
    ));

    expect(find.text('مشكاة'), findsOneWidget);
    expect(find.text('القاهرة، مصر'), findsOneWidget);
    expect(find.text('مواقيت الصلاة'), findsOneWidget);
    for (final prayer in prayers) {
      expect(find.text(prayer.name), findsOneWidget);
      expect(find.text(prayer.time), findsOneWidget);
    }
    expect(find.text('متبقي 00:24:10'), findsOneWidget);
    expect(find.text('آية اليوم'), findsOneWidget);
    expect(find.text('حديث اليوم'), findsOneWidget);
    expect(find.text('دعاء اليوم'), findsOneWidget);
    expect(find.text('الاختصارات السريعة'), findsOneWidget);
    expect(find.text('القرآن الكريم'), findsOneWidget);
    expect(find.text('الأذكار'), findsOneWidget);
    expect(find.text('المسبحة'), findsOneWidget);
    expect(find.text('المزيد'), findsOneWidget);
    expect(find.text('اتجاه القبلة'), findsNothing);
  });
}
