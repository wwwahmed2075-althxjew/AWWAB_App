import 'dart:ui';

import 'package:flutter/material.dart';

/// Standalone Mishkat home-page module.
///
/// Prayer times and daily religious content must be supplied by the host app
/// from verified/calculated sources. This widget deliberately contains no
/// fabricated prayer times, Quran verses, hadith, or supplications.
class MishkatHomePage extends StatelessWidget {
  const MishkatHomePage({
    super.key,
    required this.locationLabel,
    required this.gregorianDate,
    required this.hijriDate,
    required this.prayerTimes,
    required this.dailyItems,
    this.onNotifications,
    this.onSettings,
    this.onTheme,
    this.onQuran,
    this.onAzkar,
    this.onTasbeeh,
    this.onMore,
    this.quranProgress,
    this.quranProgressLabel,
  }) : assert(prayerTimes.length == 6 || prayerTimes.length == 7),
       assert(dailyItems.length == 3);

  final String locationLabel;
  final String gregorianDate;
  final String hijriDate;
  final List<MishkatPrayerTime> prayerTimes;
  final List<MishkatDailyItem> dailyItems;
  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final VoidCallback? onTheme;
  final VoidCallback? onQuran;
  final VoidCallback? onAzkar;
  final VoidCallback? onTasbeeh;
  final VoidCallback? onMore;
  final double? quranProgress;
  final String? quranProgressLabel;

  static const Color _ink = Color(0xFF09152B);
  static const Color _navy = Color(0xFF14233D);
  static const Color _gold = Color(0xFFE5CD98);
  static const Color _ivory = Color(0xFFFFF2D5);
  static const Color _muted = Color(0xFFC5C2BD);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.85, -0.8),
            radius: 1.45,
            colors: [Color(0xFF34304B), _ink, Color(0xFF101B30)],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 112),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildDateLocation(),
              const SizedBox(height: 14),
              _buildGreeting(),
              const SizedBox(height: 22),
              _sectionTitle('مواقيت الصلاة', Icons.access_time_rounded),
              const SizedBox(height: 12),
              _buildPrayerGrid(),
              const SizedBox(height: 22),
              _sectionTitle('من نور الوحي', Icons.auto_awesome_rounded),
              const SizedBox(height: 12),
              _buildDailyItems(),
              const SizedBox(height: 22),
              _sectionTitle('الاختصارات السريعة', Icons.bolt_rounded),
              const SizedBox(height: 12),
              _buildShortcuts(),
              if (quranProgress != null && quranProgressLabel != null) ...[
                const SizedBox(height: 22),
                _buildQuranProgress(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('مشكاة', style: TextStyle(
                color: _ivory, fontSize: 29, fontWeight: FontWeight.w900,
                height: 1.2, shadows: [Shadow(color: _gold, blurRadius: 14)],
              )),
              SizedBox(height: 3),
              Text('هُما خيرٌ من الدنيا', style: TextStyle(
                color: _gold, fontSize: 12, fontWeight: FontWeight.w600,
              )),
            ],
          ),
        ),
        if (onTheme != null) _HeaderAction(
          icon: Icons.nightlight_round, onTap: onTheme!, tooltip: 'تغيير المظهر',
        ),
        if (onNotifications != null) _HeaderAction(
          icon: Icons.notifications_none_rounded,
          onTap: onNotifications!, tooltip: 'الإشعارات',
        ),
        if (onSettings != null) _HeaderAction(
          icon: Icons.settings_outlined, onTap: onSettings!, tooltip: 'الإعدادات',
        ),
      ],
    );
  }

  Widget _buildDateLocation() {
    return Row(
      children: [
        Expanded(
          child: _GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              const Icon(Icons.calendar_month_rounded, color: _gold, size: 21),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gregorianDate, style: const TextStyle(
                    color: _ivory, fontSize: 12, fontWeight: FontWeight.w700,
                  )),
                  const SizedBox(height: 3),
                  Text(hijriDate, style: const TextStyle(color: _muted, fontSize: 11)),
                ],
              )),
            ]),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(children: [
              const Icon(Icons.location_on_outlined, color: _gold, size: 20),
              const SizedBox(width: 7),
              Expanded(child: Text(locationLabel, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _ivory, fontSize: 11, fontWeight: FontWeight.w600))),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('مرحبًا بك', style: TextStyle(
          color: _ivory, fontSize: 25, fontWeight: FontWeight.w800,
        )),
        SizedBox(height: 5),
        Text('اذكر ربك كثيرًا', style: TextStyle(
          color: _gold, fontSize: 14, fontWeight: FontWeight.w600,
        )),
        SizedBox(height: 10),
        _SoftDivider(),
      ],
    );
  }

  Widget _sectionTitle(String title, IconData icon) => Row(
    children: [
      Icon(icon, color: _gold, size: 19),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(
        color: _ivory, fontSize: 17, fontWeight: FontWeight.w800,
      )),
    ],
  );

  Widget _buildPrayerGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 18) / 3;
        return Wrap(
          spacing: 9,
          runSpacing: 9,
          children: prayerTimes.map((item) => SizedBox(
            width: cardWidth,
            height: 116,
            child: _PrayerGlassCard(item: item),
          )).toList(),
        );
      },
    );
  }

  Widget _buildDailyItems() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dailyItems.map((item) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: item == dailyItems.last ? 0 : 8),
          child: _DailyGlassCard(item: item),
        ),
      )).toList(),
    );
  }

  Widget _buildShortcuts() {
    final items = <_ShortcutData>[
      _ShortcutData('القرآن الكريم', Icons.menu_book_rounded, onQuran),
      _ShortcutData('الأذكار', Icons.auto_awesome_rounded, onAzkar),
      _ShortcutData('المسبحة', Icons.fingerprint_rounded, onTasbeeh),
      _ShortcutData('المزيد', Icons.grid_view_rounded, onMore),
    ];
    return Row(
      children: items.map((item) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: item == items.last ? 0 : 8),
          child: _ShortcutButton(item: item),
        ),
      )).toList(),
    );
  }

  Widget _buildQuranProgress() => _GlassPanel(
    padding: const EdgeInsets.all(15),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.menu_book_rounded, color: _gold, size: 21),
        const SizedBox(width: 9),
        const Expanded(child: Text('الورد اليومي', style: TextStyle(
          color: _ivory, fontSize: 15, fontWeight: FontWeight.w800,
        ))),
        Text(quranProgressLabel!, style: const TextStyle(color: _gold, fontSize: 11)),
      ]),
      const SizedBox(height: 11),
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
          value: quranProgress!.clamp(0, 1),
          minHeight: 5,
          backgroundColor: Colors.white.withOpacity(.12),
          valueColor: const AlwaysStoppedAnimation<Color>(_gold),
        ),
      ),
    ]),
  );
}

class MishkatPrayerTime {
  const MishkatPrayerTime({
    required this.name,
    required this.time,
    required this.icon,
    this.countdown,
    this.isNext = false,
  });

  final String name;
  final String time;
  final IconData icon;
  final String? countdown;
  final bool isNext;
}

class MishkatDailyItem {
  const MishkatDailyItem({
    required this.title,
    required this.content,
    required this.icon,
    this.source,
  });

  final String title;
  final String content;
  final IconData icon;
  final String? source;
}

class _PrayerGlassCard extends StatelessWidget {
  const _PrayerGlassCard({required this.item});
  final MishkatPrayerTime item;

  @override
  Widget build(BuildContext context) => _GlassPanel(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
    highlighted: item.isNext,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(item.icon, color: const Color(0xFFE8CD91), size: 23),
        const SizedBox(height: 6),
        Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFFFFF2D5), fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5),
        Text(item.time, textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFFFF2D5), fontSize: 15, fontWeight: FontWeight.w800)),
        if (item.countdown != null) ...[
          const SizedBox(height: 4),
          Text('متبقي ${item.countdown}', maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFE8CD91), fontSize: 9, fontWeight: FontWeight.w700)),
        ],
      ],
    ),
  );
}

class _DailyGlassCard extends StatelessWidget {
  const _DailyGlassCard({required this.item});
  final MishkatDailyItem item;

  @override
  Widget build(BuildContext context) => _GlassPanel(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 13),
    child: Column(
      children: [
        Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFFFFF2D5), fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(height: 9),
        Icon(item.icon, color: const Color(0xFFE8CD91), size: 25),
        const SizedBox(height: 8),
        Text(item.content, maxLines: 5, overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFF7EBD4), fontSize: 10, height: 1.65)),
        if (item.source != null) ...[
          const SizedBox(height: 6),
          Text(item.source!, maxLines: 2, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFD9C18D), fontSize: 8)),
        ],
      ],
    ),
  );
}

class _ShortcutData {
  const _ShortcutData(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({required this.item});
  final _ShortcutData item;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.onTap == null ? .55 : 1,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(children: [
          _GlassPanel(
            padding: const EdgeInsets.all(13),
            radius: 24,
            child: Icon(item.icon, color: const Color(0xFFFFE8B6), size: 25),
          ),
          const SizedBox(height: 6),
          Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFFFF2D5), fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon, required this.onTap, required this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: _GlassPanel(
          padding: const EdgeInsets.all(10),
          radius: 30,
          child: Icon(icon, color: const Color(0xFFE8CD91), size: 19),
        ),
      ),
    ),
  );
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.radius = 21,
    this.highlighted = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 17, sigmaY: 17),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: highlighted
              ? [const Color(0xBFE9D8B4), const Color(0xA52B3650), const Color(0xA51B2B45)]
              : [const Color(0x713F4860), const Color(0xA51B2B45), const Color(0x8A17243A)],
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: highlighted ? const Color(0xFFE9D8B4).withOpacity(.8) : const Color(0xFFD9C18D).withOpacity(.38),
            width: highlighted ? 1.25 : .85,
          ),
          boxShadow: [
            BoxShadow(color: const Color(0xFFBBA4D8).withOpacity(.10), blurRadius: 17, offset: const Offset(-3, 4)),
            BoxShadow(color: Colors.black.withOpacity(.20), blurRadius: 16, offset: const Offset(2, 7)),
          ],
        ),
        child: child,
      ),
    ),
  );
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [
        Colors.transparent,
        const Color(0xFFD9C18D).withOpacity(.7),
        Colors.transparent,
      ]),
    ),
  );
}
