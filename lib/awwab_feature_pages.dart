import 'dart:async';
import 'dart:math' as math;
import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'awwab_location_service.dart';
import 'awwab_prayer_service.dart';
import 'awwab_notification_service.dart';

const _bg = Color(0xFF07080B);
const _fg = Color(0xFFF5F5F7);
const _muted = Color(0xFF9A9CA5);

class _FeatureCard extends StatelessWidget {
  final Widget child;
  const _FeatureCard({required this.child});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(.11)),
      ),
      child: child,
    ),
  );
}

String _clock(DateTime value) {
  final h = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final m = value.minute.toString().padLeft(2, '0');
  return '$h:$m ${value.hour >= 12 ? 'م' : 'ص'}';
}

String _duration(Duration value) {
  final h = value.inHours;
  final m = value.inMinutes.remainder(60);
  final s = value.inSeconds.remainder(60);
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

class AwwabHomePage extends StatefulWidget {
  const AwwabHomePage({super.key});
  @override
  State<AwwabHomePage> createState() => _AwwabHomePageState();
}

class _AwwabHomePageState extends State<AwwabHomePage> {
  final _location = AwwabLocationService();
  Position? _position;
  AwwabPrayerSchedule? _schedule;
  bool _loading = true;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _refreshLocation();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _position != null) {
        setState(() => _schedule = AwwabPrayerSchedule.calculate(
          latitude: _position!.latitude,
          longitude: _position!.longitude,
        ));
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _refreshLocation() async {
    setState(() => _loading = true);
    final position = await _location.getLocation();
    if (!mounted) return;
    setState(() {
      _position = position;
      _schedule = position == null ? null : AwwabPrayerSchedule.calculate(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      _loading = false;
    });
  }

  String _dailyAdhkar() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) return 'ابدأ أذكار الصباح';
    if (hour >= 10 && hour < 15) return 'ابدأ أذكار الاستيقاظ';
    if (hour >= 15 && hour < 19) return 'ابدأ أذكار المساء';
    return 'ابدأ أذكار النوم';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${now.day}/${now.month}/${now.year}';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        Row(children: [
          const Expanded(child: Text('أوّاب', style: TextStyle(color: _fg, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: .3))),
          _FeatureCard(child: Column(children: [
            Text(date, style: const TextStyle(color: _fg, fontSize: 12, fontWeight: FontWeight.w700)),
            const Text('التاريخ الميلادي', style: TextStyle(color: _muted, fontSize: 9)),
          ])),
        ]),
        const SizedBox(height: 6),
        const Text('كل يوم أقرب إلى الله', style: TextStyle(color: _muted, fontSize: 12)),
        const SizedBox(height: 18),
        InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AwwabAzkarPage())),
          child: _FeatureCard(child: Row(children: [
            const Icon(Icons.auto_awesome_rounded, color: _fg, size: 25),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('وردك اليومي', style: TextStyle(color: _muted, fontSize: 10)),
              Text(_dailyAdhkar(), style: const TextStyle(color: _fg, fontSize: 16, fontWeight: FontWeight.w800)),
            ])),
            const Icon(Icons.chevron_left_rounded, color: _muted),
          ])),
        ),
        const SizedBox(height: 14),
        _FeatureCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.mosque_outlined, size: 19), SizedBox(width: 8), Text('مواقيت الصلاة', style: TextStyle(color: _fg, fontWeight: FontWeight.w800))]),
          const SizedBox(height: 13),
          if (_loading) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
          else if (_schedule == null) ...[
            const Text('اسمح للتطبيق بالوصول إلى موقعك ليحسب المواقيت تلقائيًا، ويمكنه استخدام آخر موقع محفوظ دون إنترنت.', style: TextStyle(color: _muted, fontSize: 11, height: 1.7)),
            TextButton.icon(onPressed: _refreshLocation, icon: const Icon(Icons.my_location), label: const Text('السماح وتحديد موقعي')),
          ] else ...[
            Text('الصلاة القادمة: ${_schedule!.next!.name}', style: const TextStyle(color: _fg, fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(_duration(_schedule!.remaining ?? Duration.zero), style: const TextStyle(color: _fg, fontSize: 26, fontWeight: FontWeight.w800, fontFeatures: [])),
            const Text('الوقت المتبقي', style: TextStyle(color: _muted, fontSize: 10)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 9, children: _schedule!.entries.map((e) => Container(
              width: 91, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.045), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(.08))),
              child: Column(children: [
                Text(e.name, style: const TextStyle(color: _muted, fontSize: 10)),
                const SizedBox(height: 4),
                Text(_clock(e.time), style: const TextStyle(color: _fg, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            )).toList()),
            const SizedBox(height: 8),
            TextButton.icon(onPressed: _refreshLocation, icon: const Icon(Icons.refresh, size: 16), label: const Text('تحديث الموقع')),
          ],
        ])),
        const SizedBox(height: 14),
        _DailyContentCard(title: 'آية اليوم', text: _dailyVerses[now.day % _dailyVerses.length]['text']!, source: _dailyVerses[now.day % _dailyVerses.length]['source']!),
        const SizedBox(height: 12),
        _DailyContentCard(title: 'حديث اليوم', text: _dailyHadith[now.day % _dailyHadith.length]['text']!, source: _dailyHadith[now.day % _dailyHadith.length]['source']!),
        const SizedBox(height: 12),
        _DailyContentCard(title: 'دعاء اليوم', text: _dailyDuas[now.day % _dailyDuas.length]['text']!, source: _dailyDuas[now.day % _dailyDuas.length]['source']!),
        const SizedBox(height: 14),
        _FeatureCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('مساحات للعبادة', style: TextStyle(color: _fg, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _QuickAction('أسماء الله الحسنى', Icons.favorite_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllahNamesPage()))),
            _QuickAction('فضل الضحى وقيام الليل', Icons.nightlight_round, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerVirtuesPage()))),
            _QuickAction('اتجاه القبلة', Icons.explore_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AwwabQiblaPage()))),
          ]),
        ])),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(icon, size: 16, color: _fg),
    label: Text(label, style: const TextStyle(color: _fg, fontSize: 10)),
    backgroundColor: Colors.white.withOpacity(.07),
    side: BorderSide(color: Colors.white.withOpacity(.1)),
    onPressed: onTap,
  );
}

class _DailyContentCard extends StatelessWidget {
  final String title, text, source;
  const _DailyContentCard({required this.title, required this.text, required this.source});
  @override
  Widget build(BuildContext context) => _FeatureCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: _fg, fontWeight: FontWeight.w800, fontSize: 13)),
    const SizedBox(height: 9),
    Text(text, textAlign: TextAlign.right, textDirection: TextDirection.rtl, style: const TextStyle(color: _fg, fontSize: 15, height: 1.9)),
    const SizedBox(height: 7),
    Text(source, style: const TextStyle(color: _muted, fontSize: 10)),
  ]));
}

const _dailyVerses = [
  {'text': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ', 'source': 'سورة الرعد: 28'},
  {'text': 'فَاقْرَءُوا مَا تَيَسَّرَ مِنَ الْقُرْآنِ', 'source': 'سورة المزمل: 20'},
  {'text': 'إِنَّ هَذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ', 'source': 'سورة الإسراء: 9'},
  {'text': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ', 'source': 'سورة البقرة: 152'},
];
const _dailyHadith = [
  {'text': 'من سلك طريقًا يلتمس فيه علمًا، سهّل الله له به طريقًا إلى الجنة.', 'source': 'صحيح مسلم: 2699'},
  {'text': 'خيركم من تعلم القرآن وعلمه.', 'source': 'صحيح البخاري: 5027'},
  {'text': 'مثل الذي يذكر ربه والذي لا يذكر ربه مثل الحي والميت.', 'source': 'صحيح البخاري: 6407'},
  {'text': 'أحب الأعمال إلى الله أدومها وإن قل.', 'source': 'صحيح البخاري: 6464، وصحيح مسلم: 783'},
];
const _dailyDuas = [
  {'text': 'اللهم أعني على ذكرك وشكرك وحسن عبادتك.', 'source': 'سنن أبي داود: 1522'},
  {'text': 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار.', 'source': 'سورة البقرة: 201'},
  {'text': 'اللهم إني أسألك الهدى والتقى والعفاف والغنى.', 'source': 'صحيح مسلم: 2721'},
];

class AwwabPrayerPage extends StatefulWidget {
  const AwwabPrayerPage({super.key});
  @override
  State<AwwabPrayerPage> createState() => _AwwabPrayerPageState();
}
class _AwwabPrayerPageState extends State<AwwabPrayerPage> {
  final _location = AwwabLocationService();
  Position? _position;
  AwwabPrayerSchedule? _schedule;
  bool _loading = true;
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await _location.getLocation();
    if (!mounted) return;
    setState(() {
      _position = p;
      _schedule = p == null ? null : AwwabPrayerSchedule.calculate(latitude: p.latitude, longitude: p.longitude);
      _loading = false;
    });
  }
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 120), children: [
    const Text('الصلاة', style: TextStyle(color: _fg, fontSize: 25, fontWeight: FontWeight.w800)),
    const SizedBox(height: 6),
    const Text('المواقيت تُحسب محليًا على جهازك دون الحاجة للإنترنت', style: TextStyle(color: _muted, fontSize: 11)),
    const SizedBox(height: 18),
    if (_loading) const Center(child: CircularProgressIndicator())
    else if (_schedule == null) _FeatureCard(child: Column(children: [
      const Icon(Icons.location_off_outlined, color: _muted, size: 28),
      const SizedBox(height: 8),
      const Text('اسمح بالوصول للموقع لتحديد مواقيت الصلاة واتجاه القبلة تلقائيًا.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 12)),
      TextButton(onPressed: _load, child: const Text('السماح بالموقع')),
    ]))
    else ...[
      _FeatureCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('الصلاة القادمة: ${_schedule!.next!.name}', style: const TextStyle(color: _fg, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(_clock(_schedule!.next!.time), style: const TextStyle(color: _fg, fontSize: 27, fontWeight: FontWeight.w800)),
        const Text('تُحسب المواقيت وفق طريقة الهيئة المصرية العامة للمساحة', style: TextStyle(color: _muted, fontSize: 10)),
      ])),
      const SizedBox(height: 12),
      for (final e in _schedule!.entries) Padding(padding: const EdgeInsets.only(bottom: 8), child: _FeatureCard(child: Row(children: [
        const Icon(Icons.access_time_rounded, color: _muted, size: 18), const SizedBox(width: 12),
        Expanded(child: Text(e.name, style: const TextStyle(color: _fg, fontWeight: FontWeight.w700))),
        Text(_clock(e.time), style: const TextStyle(color: _fg, fontWeight: FontWeight.w700)),
      ]))),
      _FeatureCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('التذكير بآية الكرسي بعد الصلاة', style: TextStyle(color: _fg, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('سيكون التنبيه اختياريًا من إعدادات التذكيرات. جدولة الإشعارات المحلية ستُفعّل ضمن خطوة إعداد أذونات أندرويد.', style: TextStyle(color: _muted, fontSize: 11, height: 1.7)),
      ])),
    ],
    const SizedBox(height: 12),
    TextButton.icon(onPressed: _load, icon: const Icon(Icons.my_location), label: const Text('تحديث الموقع تلقائيًا')),
  ]);
}

class AwwabAzkarPage extends StatelessWidget {
  const AwwabAzkarPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(backgroundColor: _bg, title: const Text('الأذكار')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      for (final item in ['أذكار الاستيقاظ','أذكار الصباح','أذكار المساء','أذكار النوم','أذكار بعد الصلاة','الرقية الشرعية']) Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AzkarDetailsPage(title: item))),
          child: _FeatureCard(child: Row(children: [
            const Icon(Icons.spa_outlined, color: _fg), const SizedBox(width: 12),
            Expanded(child: Text(item, style: const TextStyle(color: _fg, fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_left, color: _muted),
          ]))),
      ),
      const SizedBox(height: 8),
      _FeatureCard(child: const Text('يمكن تخصيص التذكيرات لكل ورد من صفحة إعدادات التذكيرات.', style: TextStyle(color: _muted, fontSize: 11))),
      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderSettingsPage())), child: const Text('متابعة التذكيرات وضبط مواعيدها')),
    ]),
  );
}

class AzkarDetailsPage extends StatelessWidget {
  final String title;
  const AzkarDetailsPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(backgroundColor: _bg, title: Text(title)),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      _FeatureCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('أذكار ثابتة من السنة', style: TextStyle(color: _fg, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const Text('أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ...', textDirection: TextDirection.rtl, style: TextStyle(color: _fg, height: 2, fontSize: 17)),
        const SizedBox(height: 7),
        const Text('يُستكمل إدراج النصوص والأعداد والأسانيد بعد مراجعتها من مصادر الأذكار المعتمدة.', style: TextStyle(color: _muted, fontSize: 10)),
      ])),
    ]),
  );
}

class AllahNamesPage extends StatelessWidget {
  const AllahNamesPage({super.key});
  static const names = [
    ('الرَّحْمَن', 'واسع الرحمة الذي وسعت رحمته جميع خلقه.'),
    ('الرَّحِيم', 'المتفضل برحمته على عباده المؤمنين.'),
    ('الْمَلِك', 'المالك المتصرف في خلقه وأمره.'),
    ('الْقُدُّوس', 'المنزه عن كل نقص وعيب.'),
    ('السَّلَام', 'السالم من كل نقص، ومنه السلام والأمان.'),
    ('الْمُؤْمِن', 'الذي يؤمّن عباده ويصدق رسله.'),
    ('الْمُهَيْمِن', 'الرقيب الحافظ الشهيد على خلقه.'),
    ('الْعَزِيز', 'الغالب الذي لا يُغلب، القوي المنيع.'),
    ('الْجَبَّار', 'العالي القاهر، وجابر كسر عباده.'),
    ('الْمُتَكَبِّر', 'المتعالي عن صفات الخلق والنقص.'),
    ('الْخَالِق', 'الموجد للأشياء على غير مثال سابق.'),
    ('الْبَارِئ', 'الذي أوجد خلقه مبرأً متقنًا.'),
    ('الْمُصَوِّر', 'الذي أعطى كل مخلوق صورته وهيئته.'),
    ('الْغَفَّار', 'كثير المغفرة لمن تاب واستغفر.'),
    ('الْقَهَّار', 'الذي قهر جميع خلقه بقدرته.'),
    ('الْوَهَّاب', 'كثير العطاء بلا عوض ولا غرض.'),
    ('الرَّزَّاق', 'المتكفل بأرزاق خلقه.'),
    ('الْفَتَّاح', 'الذي يفتح أبواب رحمته وحكمه ورزقه.'),
    ('الْعَلِيم', 'المحيط علمه بكل شيء ظاهرًا وباطنًا.'),
    ('الْقَابِض', 'يقبض بحكمته ما يشاء من خلقه ورزقه.'),
    ('الْبَاسِط', 'يبسط الرزق والرحمة والفضل لمن يشاء بحكمته.'),
    ('الْخَافِض', 'يخفض من شاء بعدله وحكمته.'),
    ('الرَّافِع', 'يرفع من شاء من عباده بالطاعة والإيمان والفضل.'),
    ('الْمُعِزّ', 'يهب العزة لمن يشاء من عباده.'),
    ('الْمُذِلّ', 'يذل من شاء بعدله، ولا تكون العزة إلا بإذنه.'),
    ('السَّمِيع', 'الذي يسمع جميع الأصوات على اختلاف اللغات والحاجات.'),
    ('الْبَصِير', 'الذي يرى كل شيء، لا يخفى عليه ظاهر ولا باطن.'),
    ('الْحَكَم', 'الذي يحكم بين عباده بالحق والعدل.'),
    ('الْعَدْل', 'المنزه عن الظلم، الذي يضع الأمور مواضعها.'),
    ('اللَّطِيف', 'الذي يعلم دقائق الأمور، ويرفق بعباده من حيث لا يشعرون.'),
    ('الْخَبِير', 'العالم ببواطن الأشياء وخفاياها.'),
    ('الْحَلِيم', 'الذي لا يعاجل العصاة بالعقوبة مع قدرته عليهم.'),
    ('الْعَظِيم', 'الذي له العظمة والكمال والجلال كله.'),
    ('الْغَفُور', 'الذي يستر الذنب ويغفره لمن تاب.'),
    ('الشَّكُور', 'الذي يثيب على العمل القليل بالأجر الكثير.'),
    ('الْعَلِيّ', 'الذي له علو الذات والقدر والقهر كما يليق بجلاله.'),
    ('الْكَبِير', 'العظيم الذي كل شيء دونه.'),
    ('الْحَفِيظ', 'الحافظ لكل شيء، والحافظ لعباده وأعمالهم.'),
    ('الْمُقِيت', 'الموصل أقوات الخلق، والحفيظ المقتدر.'),
    ('الْحَسِيب', 'الكافي لعباده، والمحاسب لهم على أعمالهم.'),
    ('الْجَلِيل', 'المتصف بصفات العظمة والكبرياء والجلال.'),
    ('الْكَرِيم', 'كثير الخير والعطاء، الذي يعطي بغير حساب.'),
    ('الرَّقِيب', 'المطلع على أحوال عباده، لا يغيب عنه شيء.'),
    ('الْمُجِيب', 'الذي يجيب دعاء من دعاه وفق حكمته.'),
    ('الْوَاسِع', 'الذي وسع علمه ورحمته وفضله كل شيء.'),
    ('الْحَكِيم', 'الذي يضع الأمور مواضعها، وكل أفعاله قائمة على الحكمة.'),
    ('الْوَدُود', 'المحب لعباده المؤمنين، والمحبوب المستحق للمحبة.'),
    ('الْمَجِيد', 'العظيم الواسع الكرم والشرف والمجد.'),
    ('الْبَاعِث', 'الذي يبعث الخلق من قبورهم يوم القيامة.'),
    ('الشَّهِيد', 'الحاضر الذي لا يغيب عنه شيء، والشاهد على أعمال عباده.'),
    ('الْحَقّ', 'الثابت الذي لا شك في وجوده وربوبيته ووعده.'),
    ('الْوَكِيل', 'الكفيل بأرزاق عباده وأمورهم، ومن توكل عليه كفاه.'),
    ('الْقَوِيّ', 'كامل القوة الذي لا يعجزه شيء.'),
    ('الْمَتِين', 'الشديد القوة الذي لا يلحقه ضعف ولا تعب.'),
    ('الْوَلِيّ', 'ناصر المؤمنين ومتولي شؤون عباده.'),
    ('الْحَمِيد', 'المستحق للحمد والثناء لكمال أسمائه وصفاته وأفعاله.'),
    ('الْمُحْصِي', 'الذي أحاط بكل شيء عددًا وعلمًا.'),
    ('الْمُبْدِئ', 'الذي أنشأ الخلق ابتداءً من غير مثال سابق.'),
    ('الْمُعِيد', 'الذي يعيد الخلق بعد الموت للبعث والحساب.'),
    ('الْمُحْيِي', 'الذي يهب الحياة لمن يشاء.'),
    ('الْمُمِيت', 'الذي يقدر الموت على خلقه عند انتهاء آجالهم.'),
    ('الْحَيّ', 'كامل الحياة التي لا يسبقها عدم ولا يلحقها زوال.'),
    ('الْقَيُّوم', 'القائم بنفسه، المقيم لشؤون خلقه جميعًا.'),
    ('الْوَاجِد', 'الذي لا يعوزه شيء، ولا يفوته مطلوب.'),
    ('الْمَاجِد', 'العظيم الجليل، المتصف بغاية الكمال والشرف.'),
    ('الْوَاحِد', 'المتفرد الذي لا شريك له في ربوبيته وألوهيته وأسمائه وصفاته.'),
    ('الصَّمَد', 'السيد الكامل الذي تقصده الخلائق في حوائجها.'),
    ('الْقَادِر', 'الذي له القدرة التامة على كل شيء.'),
    ('الْمُقْتَدِر', 'كامل القدرة، لا يمتنع عليه شيء أراده.'),
    ('الْمُقَدِّم', 'الذي يقدم من يشاء بحكمته وفضله.'),
    ('الْمُؤَخِّر', 'الذي يؤخر من يشاء بحكمته وعدله.'),
    ('الأَوَّل', 'الذي ليس قبله شيء.'),
    ('الآخِر', 'الذي ليس بعده شيء.'),
    ('الظَّاهِر', 'العالي فوق خلقه، الظاهر بآياته ودلائل قدرته.'),
    ('الْبَاطِن', 'القريب المحيط علمًا، الذي لا تخفى عليه خافية.'),
    ('الْوَالِي', 'المتولي تدبير خلقه وتصريف أمورهم.'),
    ('الْمُتَعَالِي', 'المتعالي عن صفات النقص وعن مشابهة المخلوقين.'),
    ('الْبَرّ', 'الكثير الإحسان واللطف بعباده.'),
    ('التَّوَّاب', 'الذي يوفق عباده للتوبة ويقبلها منهم.'),
    ('الْمُنْتَقِم', 'الذي يعاقب من أصر على الظلم بعدله وحكمته.'),
    ('الْعَفُوّ', 'الذي يمحو الذنوب ويتجاوز عن السيئات.'),
    ('الرَّؤُوف', 'شديد الرحمة والرفق بعباده.'),
    ('مَالِكُ الْمُلْك', 'المالك لكل ملك، يؤتي الملك من يشاء وينزعه ممن يشاء.'),
    ('ذُو الْجَلَالِ وَالْإِكْرَام', 'صاحب العظمة والكبرياء والجود والإنعام.'),
    ('الْمُقْسِط', 'العادل الذي يقيم القسط ولا يظلم أحدًا.'),
    ('الْجَامِع', 'الذي يجمع الخلائق ليوم لا ريب فيه.'),
    ('الْغَنِيّ', 'المستغني عن كل ما سواه، وكل الخلق محتاجون إليه.'),
    ('الْمُغْنِي', 'الذي يغني من يشاء من عباده بفضله.'),
    ('الْمَانِع', 'الذي يمنع بحكمته ما شاء عمن شاء.'),
    ('الضَّارّ', 'الذي يقدر الضر لحكمة، ولا يقع شيء إلا بإذنه.'),
    ('النَّافِع', 'الذي بيده النفع، ولا ينال العبد خيرًا إلا بفضله.'),
    ('النُّور', 'نور السماوات والأرض، وهادي أهلها إلى الحق.'),
    ('الْهَادِي', 'الذي يهدي من يشاء إلى الصراط المستقيم.'),
    ('الْبَدِيع', 'الذي أبدع خلق السماوات والأرض على غير مثال سابق.'),
    ('الْبَاقِي', 'الدائم الذي لا يلحقه فناء ولا زوال.'),
    ('الْوَارِث', 'الباقي بعد فناء الخلق، وإليه يرجع ملك كل شيء.'),
    ('الرَّشِيد', 'الذي يرشد عباده إلى مصالحهم، وأفعاله كلها سداد وحكمة.'),
    ('الصَّبُور', 'الذي لا يعجل بالعقوبة، ويمهل عباده مع قدرته عليهم.'),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(backgroundColor: _bg, title: const Text('أسماء الله الحسنى')),
    body: ListView.builder(padding: const EdgeInsets.all(18), itemCount: names.length, itemBuilder: (context, i) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(color: Colors.transparent, child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 15),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(.1))),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(.16))),
        backgroundColor: Colors.white.withOpacity(.055),
        collapsedBackgroundColor: Colors.white.withOpacity(.045),
        leading: Text('${i + 1}'.padLeft(2, '0'), style: const TextStyle(color: _muted)),
        title: Text(names[i].$1, style: const TextStyle(color: _fg, fontWeight: FontWeight.w800)),
        children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: Align(alignment: Alignment.centerRight, child: Text(names[i].$2, textAlign: TextAlign.right, style: const TextStyle(color: _fg, height: 1.8))))],
      )),
    )),
  );
}

class PrayerVirtuesPage extends StatelessWidget {
  const PrayerVirtuesPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(backgroundColor: _bg, title: const Text('فضل الضحى وقيام الليل')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      _FeatureCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('فضل صلاة الضحى', style: TextStyle(color: _fg, fontWeight: FontWeight.w800, fontSize: 17)),
        SizedBox(height: 10),
        Text('«يصبح على كل سلامى من أحدكم صدقة... ويجزئ من ذلك ركعتان يركعهما من الضحى».', textDirection: TextDirection.rtl, style: TextStyle(color: _fg, fontSize: 15, height: 2)),
        SizedBox(height: 6),
        Text('صحيح مسلم: 720', style: TextStyle(color: _muted, fontSize: 10)),
        SizedBox(height: 16),
        Text('فضل قيام الليل', style: TextStyle(color: _fg, fontWeight: FontWeight.w800, fontSize: 17)),
        SizedBox(height: 10),
        Text('«أفضل الصلاة بعد الفريضة صلاة الليل».', textDirection: TextDirection.rtl, style: TextStyle(color: _fg, fontSize: 15, height: 2)),
        SizedBox(height: 6),
        Text('صحيح مسلم: 1163', style: TextStyle(color: _muted, fontSize: 10)),
        SizedBox(height: 12),
        Text('ومن القرآن: (كَانُوا قَلِيلًا مِنَ اللَّيْلِ مَا يَهْجَعُونَ) — الذاريات: 17.', textDirection: TextDirection.rtl, style: TextStyle(color: _fg, height: 1.8)),
      ])),
    ]),
  );
}

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});
  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}
class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  final Map<String, bool> enabled = {
    'أذكار الاستيقاظ': false, 'أذكار الصباح': false, 'أذكار المساء': false,
    'أذكار النوم': false, 'آية الكرسي بعد الصلاة': false,
    'الضحى': false, 'قيام الليل': false, 'الورد اليومي': false,
  };
  final Map<String, TimeOfDay> times = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      for (final item in enabled.keys) {
        final id = enabled.keys.toList().indexOf(item) + 401;
        enabled[item] = prefs.getBool('reminder_item_$id') ?? false;
        final hour = prefs.getInt('reminder_item_${id}_hour') ?? 8;
        final minute = prefs.getInt('reminder_item_${id}_minute') ?? 0;
        times[item] = TimeOfDay(hour: hour, minute: minute);
      }
      _loading = false;
    });
  }

  Future<void> _saveItem(String item) async {
    final index = enabled.keys.toList().indexOf(item);
    final id = index + 401;
    final time = times[item] ?? const TimeOfDay(hour: 8, minute: 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder_item_$id', enabled[item]!);
    await prefs.setInt('reminder_item_${id}_hour', time.hour);
    await prefs.setInt('reminder_item_${id}_minute', time.minute);

    if (item == 'آية الكرسي بعد الصلاة') {
      const baseId = 5000;
      for (var day = 0; day < 7; day++) {
        for (var prayer = 0; prayer < 5; prayer++) {
          await AwwabNotificationService.instance.cancel(baseId + day * 5 + prayer);
        }
      }
      if (!enabled[item]!) return;
      final position = await AwwabLocationService().getLocation(askPermission: false);
      if (position == null) return;
      final now = DateTime.now();
      for (var day = 0; day < 7; day++) {
        final date = now.add(Duration(days: day));
        final prayerTimes = AwwabPrayerSchedule.obligatoryPrayerTimesForDate(
          latitude: position.latitude,
          longitude: position.longitude,
          date: date,
        );
        for (var prayer = 0; prayer < prayerTimes.length; prayer++) {
          final afterPrayer = prayerTimes[prayer].add(const Duration(minutes: 2));
          await AwwabNotificationService.instance.scheduleAt(
            id: baseId + day * 5 + prayer,
            time: afterPrayer,
            title: 'لا تنسَ آية الكرسي',
            body: 'تذكير بقراءة آية الكرسي بعد الصلاة المكتوبة.',
          );
        }
      }
      return;
    }

    final dailyId = 401 + index;
    if (enabled[item]!) {
      await AwwabNotificationService.instance.scheduleDaily(
        id: dailyId,
        title: 'تذكير أوّاب: $item',
        body: item == 'قيام الليل' ? 'اجعل لك نصيبًا من صلاة الليل.' : 'حان وقت $item.',
        hour: time.hour,
        minute: time.minute,
      );
    } else {
      await AwwabNotificationService.instance.cancel(dailyId);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(backgroundColor: _bg, title: const Text('متابعة التذكيرات')),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : ListView(padding: const EdgeInsets.all(18), children: [
        const Text('فعّل ما تريد، واضبط وقت كل تذكير بشكل مستقل. تعمل التذكيرات محليًا دون إنترنت.', style: TextStyle(color: _muted, fontSize: 11)),
        const SizedBox(height: 12),
        for (final item in enabled.keys) Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: _FeatureCard(child: Column(children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: enabled[item]!,
              activeColor: _fg,
              title: Text(item, style: const TextStyle(color: _fg, fontSize: 13, fontWeight: FontWeight.w700)),
              onChanged: (v) {
                setState(() => enabled[item] = v);
                _saveItem(item);
              },
            ),
            if (enabled[item]!) Align(alignment: Alignment.centerLeft, child: TextButton.icon(
              onPressed: () async {
                final picked = await showTimePicker(context: context, initialTime: times[item] ?? const TimeOfDay(hour: 8, minute: 0));
                if (picked != null) {
                  setState(() => times[item] = picked);
                  _saveItem(item);
                }
              },
              icon: const Icon(Icons.schedule, size: 16),
              label: Text(item == 'آية الكرسي بعد الصلاة' ? 'بعد كل صلاة بوقت قصير' : (times[item]?.format(context) ?? 'اختيار وقت التذكير')),
            )),
          ])),
        ),
      ]),
  );
}

class AwwabQiblaPage extends StatefulWidget {
  const AwwabQiblaPage({super.key});
  @override
  State<AwwabQiblaPage> createState() => _AwwabQiblaPageState();
}
class _AwwabQiblaPageState extends State<AwwabQiblaPage> {
  final _location = AwwabLocationService();
  Position? _position;
  double? _bearing;
  double? _heading;
  @override
  void initState() {
    super.initState();
    _location.getLocation().then((p) { if (mounted) setState(() => _position = p); });
    FlutterCompass.events?.listen((event) { if (mounted) setState(() => _heading = event.heading); });
  }
  @override
  Widget build(BuildContext context) {
    final direction = _position == null ? null : adhan.Qibla(adhan.Coordinates(_position!.latitude, _position!.longitude)).direction;
    final rotation = direction == null || _heading == null ? 0.0 : (direction - _heading!) * math.pi / 180;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(backgroundColor: _bg, title: const Text('اتجاه القبلة')),
      body: Center(child: Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (direction == null) const Text('اسمح بالوصول للموقع لتحديد اتجاه القبلة.', style: TextStyle(color: _muted))
        else ...[
          Transform.rotate(angle: rotation, child: Container(
            width: 250, height: 250,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.22), width: 2), color: Colors.white.withOpacity(.045)),
            child: const Stack(alignment: Alignment.center, children: [
              Icon(Icons.navigation_rounded, color: _fg, size: 130),
              Positioned(top: 18, child: Text('القبلة', style: TextStyle(color: _fg, fontWeight: FontWeight.w800))),
            ]),
          )),
          const SizedBox(height: 18),
          Text('اتجاه القبلة: ${direction.toStringAsFixed(1)}°', style: const TextStyle(color: _fg, fontSize: 17, fontWeight: FontWeight.w800)),
          Text(_heading == null ? 'حساس البوصلة غير متاح أو يحتاج إلى معايرة.' : 'اتبع اتجاه السهم وحرّك الهاتف ببطء لمعايرة الحساس.', style: const TextStyle(color: _muted, fontSize: 11)),
        ],
      ]))),
    );
  }
}
