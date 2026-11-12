import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'madinah_mushaf_reader_page.dart';
import 'awwab_feature_pages.dart';

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
  final pages = const [AwwabHomePage(), QuranPage(), AwwabAzkarPage(), AwwabPrayerPage(), MorePage()];
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

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});
  @override
  State<QuranPage> createState() => _QuranPageState();
}
class _QuranPageState extends State<QuranPage> {
  late Future<List<dynamic>> surahsFuture;
  final searchController = TextEditingController();
  String search = '';
  int? lastSurah;
  int? lastAyah;
  @override
  void initState() { super.initState(); surahsFuture = loadSurahs(); loadLastRead(); }
  @override
  void dispose() { searchController.dispose(); super.dispose(); }
  Future<List<dynamic>> loadSurahs() async {
    final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah')).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception('تعذر تحميل فهرس السور');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['code'] != 200) throw Exception('مصدر القرآن لم يستجب بشكل صحيح');
    return json['data'] as List<dynamic>;
  }
  Future<void> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { lastSurah = prefs.getInt('quran_last_surah'); lastAyah = prefs.getInt('quran_last_ayah'); });
  }
  Future<void> openSurah(Map<String, dynamic> surah) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReaderPage(
      number: surah['number'] as int, name: surah['name'] as String,
      englishName: surah['englishName'] as String, ayahCount: surah['numberOfAyahs'] as int,
    )));
    loadLastRead();
  }
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'القرآن الكريم', subtitle: 'فهرس السور والقراءة وحفظ موضع التوقف',
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('مصحفي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        const Text('افتح أي سورة لعرض آياتها، وسيُحفظ آخر موضع قراءة على جهازك.', style: TextStyle(color: muted, fontSize: 12, height: 1.8)),
        const SizedBox(height: 12),
        if (lastSurah != null)
          Text('آخر موضع قراءة: سورة رقم $lastSurah${lastAyah == null ? '' : ' • آية $lastAyah'}', style: const TextStyle(fontSize: 11, color: white))
        else
          const Text('آخر موضع قراءة: لم تبدأ بعد', style: TextStyle(fontSize: 11, color: muted)),
      ])),
      const SizedBox(height: 13),
      InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MadinahMushafReaderPage())),
        child: GlassCard(child: Row(children: [
          const Icon(Icons.menu_book_rounded, size: 23),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('مصحف المدينة النبوية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            SizedBox(height: 4),
            Text('رواية حفص • 604 صفحة • تنزيل للعمل دون إنترنت', style: TextStyle(color: muted, fontSize: 10)),
          ])),
          const Icon(Icons.chevron_left, color: muted),
        ])),
      ),
      const SizedBox(height: 13),
      TextField(controller: searchController, onChanged: (value) => setState(() => search = value.trim()),
        style: const TextStyle(color: white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'ابحث باسم السورة أو رقمها', hintStyle: const TextStyle(color: muted, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: muted, size: 19),
          filled: true, fillColor: Colors.white.withOpacity(.045),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white38)),
        ),
      ),
      const SizedBox(height: 12),
      FutureBuilder<List<dynamic>>(future: surahsFuture, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(35), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        if (snapshot.hasError) return GlassCard(child: Column(children: [
          const Icon(Icons.wifi_off_rounded, color: muted, size: 25), const SizedBox(height: 9),
          const Text('تعذر تحميل فهرس القرآن', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 5), const Text('تحقق من اتصال الإنترنت ثم حاول مرة أخرى.', style: TextStyle(color: muted, fontSize: 11)),
          TextButton(onPressed: () => setState(() => surahsFuture = loadSurahs()), child: const Text('إعادة المحاولة')),
        ]));
        final all = snapshot.data ?? [];
        final filtered = all.where((raw) {
          final item = raw as Map<String, dynamic>;
          return search.isEmpty || (item['name'] as String).contains(search) ||
            (item['englishName'] as String).toLowerCase().contains(search.toLowerCase()) || item['number'].toString() == search;
        }).toList();
        return Column(children: filtered.map((raw) {
          final item = raw as Map<String, dynamic>;
          return Padding(padding: const EdgeInsets.only(bottom: 7), child: InkWell(
            borderRadius: BorderRadius.circular(20), onTap: () => openSurah(item),
            child: GlassCard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [
              Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(11)), child: Text('${item['number']}', style: const TextStyle(fontSize: 11))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${item['numberOfAyahs']} آية • ${item['revelationType'] == 'Meccan' ? 'مكية' : 'مدنية'}', style: const TextStyle(fontSize: 10, color: muted)),
              ])),
              const Icon(Icons.chevron_left, color: muted, size: 19),
            ])),
          ));
        }).toList());
      }),
    ]),
  );
}
class QuranReaderPage extends StatefulWidget {
  final int number; final String name; final String englishName; final int ayahCount;
  const QuranReaderPage({super.key, required this.number, required this.name, required this.englishName, required this.ayahCount});
  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}
class _QuranReaderPageState extends State<QuranReaderPage> {
  late Future<List<dynamic>> ayahsFuture;
  @override
  void initState() { super.initState(); ayahsFuture = loadAyahs(); }
  Future<List<dynamic>> loadAyahs() async {
    final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/${widget.number}')).timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) throw Exception('تعذر تحميل السورة');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['code'] != 200) throw Exception('لم تصل بيانات السورة');
    return json['data']['ayahs'] as List<dynamic>;
  }
  Future<void> savePosition(int ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_last_surah', widget.number);
    await prefs.setInt('quran_last_ayah', ayah);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ink,
    appBar: AppBar(backgroundColor: ink, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      Text('${widget.englishName} • ${widget.ayahCount} آية', style: const TextStyle(fontSize: 10, color: muted)),
    ])),
    body: FutureBuilder<List<dynamic>>(future: ayahsFuture, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, color: muted, size: 28), const SizedBox(height: 10), const Text('تعذر تحميل الآيات'),
        TextButton(onPressed: () => setState(() => ayahsFuture = loadAyahs()), child: const Text('إعادة المحاولة')),
      ]));
      final ayahs = snapshot.data ?? [];
      return ListView.builder(padding: const EdgeInsets.fromLTRB(18, 18, 18, 35), itemCount: ayahs.length, itemBuilder: (context, index) {
        final ayah = ayahs[index] as Map<String, dynamic>;
        final number = ayah['numberInSurah'] as int;
        return InkWell(onTap: () => savePosition(number), child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 7),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.09)))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(ayah['text'] as String, textAlign: TextAlign.justify, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 23, height: 2.05, color: white, fontFamily: 'serif')),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(20)), child: Text('۞ $number  •  حفظ موضع القراءة', style: const TextStyle(fontSize: 9, color: muted)))),
          ]),
        ));
      });
    }),
  );
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
    _MoreTile(icon: Icons.explore_outlined, title: 'اتجاه القبلة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AwwabQiblaPage()))),
    _MoreTile(icon: Icons.favorite_outline, title: 'أسماء الله الحسنى', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllahNamesPage()))),
    _MoreTile(icon: Icons.nightlight_round, title: 'فضل الضحى وقيام الليل', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerVirtuesPage()))),
    _MoreTile(icon: Icons.menu_book_rounded, title: 'فضل القرآن والذكر', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranDhikrVirtuesPage()))),
    _MoreTile(icon: Icons.notifications_none_rounded, title: 'متابعة التذكيرات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderSettingsPage()))),
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
