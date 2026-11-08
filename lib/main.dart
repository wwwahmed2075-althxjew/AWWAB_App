import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const AwwabApp());

const ink = Color(0xFF07080B);
const panel = Color(0xFF15171C);
const white = Color(0xFFF5F5F7);
const muted = Color(0xFF9A9CA5);

class AwwabApp extends StatelessWidget {
  const AwwabApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'أوّاب',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ink,
      colorScheme: const ColorScheme.dark(primary: white, surface: panel),
      fontFamily: 'NotoNaskhArabic',
      useMaterial3: true,
    ),
    home: const MainShell(),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int tab = 0;
  final pages = const [HomePage(), QuranPage(), AzkarPage(), PrayerPage(), MorePage()];
  final labels = const ['الرئيسية', 'القرآن', 'الأذكار', 'الصلاة', 'المزيد'];
  final icons = const [Icons.home_rounded, Icons.menu_book_rounded, Icons.auto_awesome_rounded, Icons.mosque_rounded, Icons.grid_view_rounded];

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBody: true,
    body: SafeArea(bottom: false, child: IndexedStack(index: tab, children: pages)),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xD91B1D22),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(.16), width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.45), blurRadius: 28, offset: const Offset(0, 10))],
            ),
            child: Row(
              children: List.generate(5, (i) => Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => tab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: tab == i ? Colors.white.withOpacity(.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(icons[i], size: 20, color: tab == i ? white : muted),
                      const SizedBox(height: 4),
                      Text(labels[i], style: TextStyle(fontSize: 9.5, fontWeight: tab == i ? FontWeight.w700 : FontWeight.w400, color: tab == i ? white : muted)),
                    ]),
                  ),
                ),
              )),
            ),
          ),
        ),
      ),
    ),
  );
}

class PageFrame extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const PageFrame({super.key, required this.title, this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 120), sliver: SliverList(delegate: SliverChildListDelegate([
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: white)),
        if (subtitle != null) ...[const SizedBox(height: 5), Text(subtitle!, style: const TextStyle(fontSize: 12, color: muted))],
      ])), const GlassIcon(icon: Icons.notifications_none_rounded)]),
      const SizedBox(height: 22),
      child,
    ]))),
  ]);
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(17)});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(23),
    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), child: Container(
      width: double.infinity, padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.055),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: Colors.white.withOpacity(.105)),
      ),
      child: child,
    )),
  );
}

class GlassIcon extends StatelessWidget {
  final IconData icon;
  const GlassIcon({super.key, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(.06), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(.12))),
    child: Icon(icon, size: 19, color: white),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(title: 'السلام عليك', subtitle: 'اجعل يومك عامرًا بذكر الله', child: Column(children: [
    GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('وَاذْكُر رَّبَّكَ كَثِيرًا', style: TextStyle(fontSize: 25, height: 1.8, fontWeight: FontWeight.w700)),
      const SizedBox(height: 5),
      const Text('خطوة صغيرة كل يوم… وأثر يبقى في القلب.', style: TextStyle(color: muted, fontSize: 12)),
      const SizedBox(height: 18),
      const Row(children: [Icon(Icons.auto_awesome, size: 15, color: muted), SizedBox(width: 7), Text('وردك اليومي يبدأ من هنا', style: TextStyle(fontSize: 11, color: muted))]),
    ])),
    const SizedBox(height: 14),
    GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.mosque_outlined, size: 18), SizedBox(width: 8), Text('مواقيت الصلاة', style: TextStyle(fontWeight: FontWeight.w700))]),
      const SizedBox(height: 13),
      const Text('اضبط موقعك وطريقة الحساب لعرض مواقيت دقيقة', style: TextStyle(color: muted, fontSize: 12)),
      const SizedBox(height: 12),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [PrayerMini(name: 'الفجر'), PrayerMini(name: 'الظهر'), PrayerMini(name: 'العصر'), PrayerMini(name: 'المغرب'), PrayerMini(name: 'العشاء')]),
    ])),
    const SizedBox(height: 14),
    GlassCard(child: Row(children: [const Icon(Icons.menu_book_rounded, size: 22), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('متابعة القرآن', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 4), Text('ابدأ القراءة وسنحفظ موضعك على جهازك', style: TextStyle(color: muted, fontSize: 11))])), const Icon(Icons.chevron_left, color: muted)])),
  ]));
}

class PrayerMini extends StatelessWidget {
  final String name;
  const PrayerMini({super.key, required this.name});
  @override
  Widget build(BuildContext context) => Column(children: [Text(name, style: const TextStyle(fontSize: 10, color: muted)), const SizedBox(height: 5), const Text('--:--', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]);
}

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});
  static const surahs = ['الفاتحة','البقرة','آل عمران','النساء','المائدة','الأنعام','الأعراف','الأنفال','التوبة','يونس','هود','يوسف','الرعد','إبراهيم','الحجر','النحل','الإسراء','الكهف','مريم','طه'];
  @override
  Widget build(BuildContext context) => PageFrame(title: 'القرآن الكريم', subtitle: 'اقرأ، واستمع، وتابع وردك', child: Column(children: [
    GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('مصحفي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 7), const Text('سيُضاف عرض المصحف بالرسم العثماني وأدوات التلاوة والحفظ في المرحلة التالية.', style: TextStyle(color: muted, fontSize: 12, height: 1.8)),
      const SizedBox(height: 12), const Text('آخر موضع قراءة: لم تبدأ بعد', style: TextStyle(fontSize: 11)),
    ])),
    const SizedBox(height: 15),
    ...List.generate(surahs.length, (i) => Padding(padding: const EdgeInsets.only(bottom: 7), child: GlassCard(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), child: Row(children: [
      Container(width: 30, height: 30, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(10)), child: Text('${i+1}', style: const TextStyle(fontSize: 11))),
      const SizedBox(width: 12), Expanded(child: Text(surahs[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))), const Icon(Icons.chevron_left, color: muted, size: 19),
    ])))),
  ]));
}

class AzkarPage extends StatelessWidget {
  const AzkarPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(title: 'الأذكار', subtitle: 'أذكارك اليومية في مكان واحد', child: Column(children: [
    for (final item in ['أذكار الصباح','أذكار المساء','أذكار النوم','أذكار الاستيقاظ','الرقية الشرعية','أذكار بعد الصلاة']) Padding(padding: const EdgeInsets.only(bottom: 10), child: GlassCard(child: Row(children: [const Icon(Icons.spa_outlined, size: 20), const SizedBox(width: 12), Expanded(child: Text(item, style: const TextStyle(fontWeight: FontWeight.w600))), const Icon(Icons.chevron_left, color: muted)]))),
  ]));
}

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(title: 'الصلاة', subtitle: 'مواقيت الصلاة والأذان والقبلة', child: Column(children: [
    GlassCard(child: Column(children: const [Icon(Icons.location_on_outlined, size: 25), SizedBox(height: 9), Text('حدد موقعك لعرض المواقيت الصحيحة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), SizedBox(height: 5), Text('لن نعرض أوقاتًا تقديرية غير موثوقة', style: TextStyle(fontSize: 11, color: muted))])),
    const SizedBox(height: 12),
    for (final p in ['الفجر','الشروق','الظهر','العصر','المغرب','العشاء']) Padding(padding: const EdgeInsets.only(bottom: 8), child: GlassCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), child: Row(children: [const Icon(Icons.access_time_rounded, size: 18, color: muted), const SizedBox(width: 12), Expanded(child: Text(p)), const Text('--:--', style: TextStyle(color: muted))]))),
  ]));
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(title: 'المزيد', subtitle: 'أدواتك وإعدادات أوّاب', child: Column(children: [
    _MoreTile(icon: Icons.touch_app_rounded, title: 'السبحة الإلكترونية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbeehPage()))),
    _MoreTile(icon: Icons.flag_outlined, title: 'الختمة والورد اليومي'),
    _MoreTile(icon: Icons.explore_outlined, title: 'اتجاه القبلة'),
    _MoreTile(icon: Icons.notifications_none_rounded, title: 'التنبيهات والأذان'),
    _MoreTile(icon: Icons.language_rounded, title: 'اللغة'),
    _MoreTile(icon: Icons.text_fields_rounded, title: 'الخط والمظهر'),
    _MoreTile(icon: Icons.info_outline_rounded, title: 'عن أوّاب'),
  ]));
}

class _MoreTile extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback? onTap;
  const _MoreTile({required this.icon, required this.title, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: GlassCard(child: Row(children: [Icon(icon, size: 20, color: muted), const SizedBox(width: 13), Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))), const Icon(Icons.chevron_left, color: muted, size: 18)]))));
}

class TasbeehPage extends StatefulWidget {
  const TasbeehPage({super.key});
  @override
  State<TasbeehPage> createState() => _TasbeehPageState();
}
class _TasbeehPageState extends State<TasbeehPage> {
  int count = 0; int goal = 100; String phrase = 'سبحان الله';
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final p = await SharedPreferences.getInstance(); setState(() { count = p.getInt('tasbeeh_count') ?? 0; goal = p.getInt('tasbeeh_goal') ?? 100; phrase = p.getString('tasbeeh_phrase') ?? 'سبحان الله'; }); }
  Future<void> _save() async { final p = await SharedPreferences.getInstance(); await p.setInt('tasbeeh_count', count); await p.setInt('tasbeeh_goal', goal); await p.setString('tasbeeh_phrase', phrase); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('السبحة الإلكترونية'), backgroundColor: ink), body: Padding(padding: const EdgeInsets.all(22), child: Column(children: [
    const SizedBox(height: 20), Text(phrase, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)), const SizedBox(height: 25),
    Expanded(child: Center(child: GestureDetector(onTap: () { setState(() => count++); _save(); }, child: Container(width: 230, height: 230, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.045), border: Border.all(color: Colors.white.withOpacity(.2), width: 2), boxShadow: [BoxShadow(color: Colors.white.withOpacity(.035), blurRadius: 35, spreadRadius: 8)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('$count', style: const TextStyle(fontSize: 58, fontWeight: FontWeight.w300)), Text('من $goal', style: const TextStyle(color: muted, fontSize: 12))]))))),
    Row(children: [Expanded(child: OutlinedButton(onPressed: () { setState(() => count = 0); _save(); }, child: const Text('تصفير'))), const SizedBox(width: 10), Expanded(child: OutlinedButton(onPressed: () { setState(() { phrase = phrase == 'سبحان الله' ? 'الحمد لله' : phrase == 'الحمد لله' ? 'الله أكبر' : 'سبحان الله'; count = 0; }); _save(); }, child: const Text('تغيير الذكر')))]),
    const SizedBox(height: 20),
  ])));
}
