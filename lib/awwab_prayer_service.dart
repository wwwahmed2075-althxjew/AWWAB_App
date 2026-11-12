import 'package:adhan/adhan.dart';

class AwwabPrayerEntry {
  final String name;
  final DateTime time;
  const AwwabPrayerEntry(this.name, this.time);
}

class AwwabPrayerSchedule {
  static List<DateTime> obligatoryPrayerTimesForDate({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) {
    final coordinates = Coordinates(latitude, longitude, validate: true);
    final parameters = CalculationMethod.egyptian.getParameters();
    final times = PrayerTimes(
      coordinates,
      DateComponents(date.year, date.month, date.day),
      parameters,
    );
    return [times.fajr, times.dhuhr, times.asr, times.maghrib, times.isha];
  }

  final List<AwwabPrayerEntry> entries;
  final AwwabPrayerEntry? next;
  final Duration? remaining;
  final double qiblaDegrees;

  const AwwabPrayerSchedule({
    required this.entries,
    required this.next,
    required this.remaining,
    required this.qiblaDegrees,
  });

  factory AwwabPrayerSchedule.calculate({
    required double latitude,
    required double longitude,
    DateTime? now,
  }) {
    final instant = now ?? DateTime.now();
    final coordinates = Coordinates(latitude, longitude, validate: true);
    final parameters = CalculationMethod.egyptian.getParameters();
    final prayerTimes = PrayerTimes.today(coordinates, parameters);

    final entries = <AwwabPrayerEntry>[
      AwwabPrayerEntry('الفجر', prayerTimes.fajr),
      AwwabPrayerEntry('الشروق', prayerTimes.sunrise),
      AwwabPrayerEntry('الظهر', prayerTimes.dhuhr),
      AwwabPrayerEntry('العصر', prayerTimes.asr),
      AwwabPrayerEntry('المغرب', prayerTimes.maghrib),
      AwwabPrayerEntry('العشاء', prayerTimes.isha),
    ];

    final prayerEntries = entries.where((e) => e.name != 'الشروق').toList();
    AwwabPrayerEntry? next;
    for (final entry in prayerEntries) {
      if (entry.time.isAfter(instant)) {
        next = entry;
        break;
      }
    }

    if (next == null) {
      final tomorrow = PrayerTimes(
        coordinates,
        DateComponents.from(instant.add(const Duration(days: 1))),
        parameters,
      );
      next = AwwabPrayerEntry('الفجر', tomorrow.fajr);
    }

    return AwwabPrayerSchedule(
      entries: entries,
      next: next,
      remaining: next.time.difference(instant),
      qiblaDegrees: Qibla(coordinates).direction,
    );
  }
}
