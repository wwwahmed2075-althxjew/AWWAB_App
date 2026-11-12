import 'dart:ui';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'madinah_mushaf_reader_page.dart';
import 'awwab_feature_pages.dart';
import 'adhan_audio_page.dart';
import 'awwab_notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AwwabApp());
  _checkForPublishedRelease();
}

Future<void> _checkForPublishedRelease() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.get(
      Uri.parse('https://api.github.com/repos/wwwahmed2075-althxjew/AWWAB_App/releases/latest'),
      headers: {'Accept': 'application/vnd.github+json'},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return;
    final release = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = release['tag_name'] as String?;
    if (tag == null || tag.isEmpty) return;
    final previous = prefs.getString('awwab_last_notified_release');
    if (previous != null && previous != tag) {
      await AwwabNotificationService.instance.showNow(
        id: 9100,
        title: 'تحديث جديد لتطبيق ملاذ',
        body: 'الإصدار $tag متاح الآن. افتح نبذة عن التطبيق للاطلاع على المميزات.',
      );
    }
    await prefs.setString('awwab_last_notified_release', tag);
  } catch (_) {
    // Release checks are best-effort and must never block app startup.
  }
}

const ink = Color(0xFF07080B);
const panel = Color(0xFF15171C);
const white = Color(0xFFF5F5F7);
const muted = Color(0xFF9A9CA5);

class AwwabApp extends StatelessWidget {
  const AwwabApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ملاذ',
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
      initialAyah: lastSurah == surah['number'] ? (lastAyah ?? 1) : 1,
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
  final int number;
  final String name;
  final String englishName;
  final int ayahCount;
  final int initialAyah;
  const QuranReaderPage({super.key, required this.number, required this.name, required this.englishName, required this.ayahCount, this.initialAyah = 1});
  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  late Future<List<dynamic>> ayahsFuture;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  Set<int> _favorites = {};
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    ayahsFuture = loadAyahs();
    _loadFavorites();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> loadAyahs() async {
    final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/${widget.number}')).timeout(const Duration(seconds: 25));
    if (response.statusCode != 200) throw Exception('تعذر تحميل السورة');
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    if (json['code'] != 200) throw Exception('لم تصل بيانات السورة');
    return json['data']['ayahs'] as List<dynamic>;
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('quran_favorite_ayahs');
    final decoded = raw == null ? <dynamic>[] : (jsonDecode(raw) as List<dynamic>);
    if (!mounted) return;
    setState(() => _favorites = decoded
        .where((e) => e is Map && e['surah'] == widget.number)
        .map<int>((e) => e['ayah'] as int).toSet());
  }

  Future<void> savePosition(int ayah) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_last_surah', widget.number);
    await prefs.setInt('quran_last_ayah', ayah);
  }

  Future<void> _toggleFavorite(Map<String, dynamic> ayah) async {
    final number = ayah['numberInSurah'] as int;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('quran_favorite_ayahs');
    final entries = raw == null ? <Map<String, dynamic>>[] :
        (jsonDecode(raw) as List<dynamic>).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final existing = entries.indexWhere((e) => e['surah'] == widget.number && e['ayah'] == number);
    final add = existing < 0;
    if (add) {
      entries.add({'surah': widget.number, 'surahName': widget.name, 'ayah': number, 'text': ayah['text']});
    } else {
      entries.removeAt(existing);
    }
    await prefs.setString('quran_favorite_ayahs', jsonEncode(entries));
    if (!mounted) return;
    setState(() {
      if (add) { _favorites.add(number); } else { _favorites.remove(number); }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(add ? 'أُضيفت الآية إلى المفضلة' : 'أُزيلت الآية من المفضلة'),
      duration: const Duration(seconds: 1),
    ));
  }

  Future<void> _showAyahActions(Map<String, dynamic> ayah) async {
    final number = ayah['numberInSurah'] as int;
    await savePosition(number);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 38, height: 4, decoration: BoxDecoration(color: muted.withOpacity(.6), borderRadius: BorderRadius.circular(8))),
          const SizedBox(height: 16),
          Text('سورة ${widget.name} • الآية $number', style: const TextStyle(color: white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ListTile(
            leading: Icon(_favorites.contains(number) ? Icons.favorite : Icons.favorite_border, color: white),
            title: Text(_favorites.contains(number) ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة', style: const TextStyle(color: white)),
            onTap: () { Navigator.pop(sheetContext); _toggleFavorite(ayah); },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline_rounded, color: white),
            title: const Text('حفظ كآخر موضع قراءة', style: TextStyle(color: white)),
            onTap: () { Navigator.pop(sheetContext); savePosition(number); },
          ),
        ]),
      )),
    );
  }

  void _scrollToInitialAyah(List<dynamic> ayahs) {
    if (_initialScrollDone || widget.initialAyah <= 1) return;
    _initialScrollDone = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _ayahKeys[widget.initialAyah];
      final targetContext = key?.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(targetContext, duration: const Duration(milliseconds: 450), alignment: .12);
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ink,
    appBar: AppBar(
      backgroundColor: ink,
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        Text('${widget.englishName} • ${widget.ayahCount} آية', style: const TextStyle(fontSize: 10, color: muted)),
      ]),
      actions: [
        IconButton(tooltip: 'الآيات المفضلة', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranFavoritesPage())),
          icon: const Icon(Icons.favorite_border_rounded)),
      ],
    ),
    body: FutureBuilder<List<dynamic>>(future: ayahsFuture, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, color: muted, size: 28), const SizedBox(height: 10), const Text('تعذر تحميل الآيات'),
        TextButton(onPressed: () => setState(() { _initialScrollDone = false; ayahsFuture = loadAyahs(); }), child: const Text('إعادة المحاولة')),
      ]));
      final ayahs = snapshot.data ?? [];
      _scrollToInitialAyah(ayahs);
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 35),
        itemCount: ayahs.length,
        itemBuilder: (context, index) {
          final ayah = ayahs[index] as Map<String, dynamic>;
          final number = ayah['numberInSurah'] as int;
          final key = _ayahKeys.putIfAbsent(number, () => GlobalKey());
          return InkWell(
            key: key,
            onTap: () => savePosition(number),
            onLongPress: () => _showAyahActions(ayah),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 7),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(.09)))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(ayah['text'] as String, textAlign: TextAlign.justify, textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 23, height: 2.05, color: white, fontFamily: 'serif')),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.07), borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('۞ $number', style: const TextStyle(fontSize: 9, color: muted)),
                    if (_favorites.contains(number)) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.favorite, size: 11, color: white),
                    ],
                  ]),
                )),
              ]),
            ),
          );
        },
      );
    }),
  );
}

class QuranFavoritesPage extends StatefulWidget {
  const QuranFavoritesPage({super.key});
  @override
  State<QuranFavoritesPage> createState() => _QuranFavoritesPageState();
}

class _QuranFavoritesPageState extends State<QuranFavoritesPage> {
  List<Map<String, dynamic>> _items = [];
  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('quran_favorite_ayahs');
    final values = raw == null ? <Map<String, dynamic>>[] :
      (jsonDecode(raw) as List<dynamic>).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    if (mounted) setState(() => _items = values);
  }

  Future<void> _remove(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _items.removeAt(index);
    await prefs.setString('quran_favorite_ayahs', jsonEncode(_items));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ink,
    appBar: AppBar(backgroundColor: ink, title: const Text('الآيات المفضلة')),
    body: _items.isEmpty
      ? const Center(child: Text('لم تضف آيات إلى المفضلة بعد', style: TextStyle(color: muted)))
      : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('${item['surahName']} • الآية ${item['ayah']}', style: const TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(item['text'] as String, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                style: const TextStyle(color: white, fontSize: 19, height: 2)),
              Row(children: [
                const Spacer(),
                TextButton.icon(onPressed: () => _remove(index), icon: const Icon(Icons.delete_outline, size: 16), label: const Text('إزالة')),
              ]),
            ])),
          );
        },
      ),
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
  Widget build(BuildContext context) => PageFrame(title: 'المزيد', subtitle: 'أدواتك وإعدادات ملاذ', child: Column(children: [
    _MoreTile(icon: Icons.volume_up_rounded, title: 'الأذان واختيار الصوت', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdhanAudioPage()))),
    _MoreTile(icon: Icons.touch_app_rounded, title: 'السبحة الإلكترونية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbeehPage()))),
    _MoreTile(icon: Icons.explore_outlined, title: 'اتجاه القبلة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AwwabQiblaPage()))),
    _MoreTile(icon: Icons.favorite_outline, title: 'أسماء الله الحسنى', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllahNamesPage()))),
    _MoreTile(icon: Icons.nightlight_round, title: 'فضل الضحى وقيام الليل', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerVirtuesPage()))),
    _MoreTile(icon: Icons.menu_book_rounded, title: 'فضل القرآن والذكر', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuranDhikrVirtuesPage()))),
    _MoreTile(icon: Icons.notifications_none_rounded, title: 'متابعة التذكيرات', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderSettingsPage()))),
    _MoreTile(icon: Icons.calendar_month_rounded, title: 'المناسبات الهجرية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HijriOccasionsPage()))),
    _MoreTile(icon: Icons.share_outlined, title: 'مشاركة التطبيق', onTap: () async {
      await Share.share('تعرّف على تطبيق ملاذ؛ رفيقك للقرآن والأذكار والصلاة.', subject: 'تطبيق ملاذ');
    }),
    _MoreTile(icon: Icons.mail_outline_rounded, title: 'إبلاغ عن خلل أو اقتراح تحسين', onTap: () async {
      final uri = Uri(scheme: 'mailto', path: 'www.ahmed2075@gmail.com', queryParameters: {
        'subject': 'بلاغ أو اقتراح تحسين لتطبيق ملاذ',
        'body': 'نوع الرسالة: \n\nتفاصيل البلاغ أو الاقتراح: \n\nنوع الجهاز وإصدار التطبيق (اختياري): ',
      });
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح تطبيق البريد الإلكتروني.')));
      }
    }),
    _MoreTile(icon: Icons.info_outline_rounded, title: 'نبذة عن التطبيق', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AwwabAboutPage()))),
  ]));
}

class AwwabAboutPage extends StatefulWidget {
  const AwwabAboutPage({super.key});
  @override
  State<AwwabAboutPage> createState() => _AwwabAboutPageState();
}

class _AwwabAboutPageState extends State<AwwabAboutPage> {
  Map<String, dynamic>? _release;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadRelease(); }

  Future<void> _loadRelease() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/wwwahmed2075-althxjew/AWWAB_App/releases/latest'),
        headers: {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 404) {
        if (mounted) setState(() { _release = null; _loading = false; });
        return;
      }
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (mounted) setState(() { _release = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'تعذر تحميل سجل الإصدارات الآن. حاول مرة أخرى لاحقًا.'; });
    }
  }

  String _formatPublished(dynamic value) {
    if (value is! String) return '';
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final assets = (_release?['assets'] as List<dynamic>?) ?? [];
    final apk = assets.cast<Map<String, dynamic>?>().whereType<Map<String, dynamic>>()
        .where((asset) => (asset['name'] as String? ?? '').toLowerCase().endsWith('.apk')).toList();
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(backgroundColor: ink, title: const Text('نبذة عن ملاذ')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        GlassCard(child: Column(children: [
          const Icon(Icons.auto_awesome_rounded, size: 42, color: white),
          const SizedBox(height: 12),
          const Text('ملاذ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text('رفيقك للقرآن والأذكار والصلاة', style: TextStyle(color: muted, fontSize: 12)),
        ])),
        const SizedBox(height: 12),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('عن التطبيق', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text('ملاذ رفيقك للقرآن والأذكار والصلاة والتذكيرات اليومية، مع أدوات تساعدك على المحافظة على عباداتك.',
            style: TextStyle(color: muted, height: 1.9, fontSize: 12)),
        ])),
        const SizedBox(height: 12),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('المطوّر', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Ahmed Khalil', textDirection: TextDirection.ltr, style: TextStyle(color: muted, fontSize: 13)),
        ])),
        const SizedBox(height: 12),
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('سجل التحديثات', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (_loading) const LinearProgressIndicator(minHeight: 2)
          else if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: muted, fontSize: 11)),
            TextButton(onPressed: _loadRelease, child: const Text('إعادة المحاولة')),
          ] else if (_release == null)
            const Text('لا يوجد إصدار رسمي منشور حتى الآن. ستظهر ملاحظات التحديث هنا بعد نشر إصدار من مستودع ملاذ.',
              style: TextStyle(color: muted, height: 1.8, fontSize: 11))
          else ...[
            Text('الإصدار ${_release!['tag_name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            if (_formatPublished(_release!['published_at']).isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 4), child: Text('تاريخ النشر: ${_formatPublished(_release!['published_at'])}', style: const TextStyle(color: muted, fontSize: 10))),
            const SizedBox(height: 8),
            Text((_release!['body'] as String?)?.trim().isNotEmpty == true ? (_release!['body'] as String).trim() : 'لم تُضف ملاحظات لهذا الإصدار.',
              style: const TextStyle(color: muted, height: 1.8, fontSize: 11)),
            if (apk.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final asset in apk)
                Align(alignment: Alignment.centerRight, child: TextButton.icon(
                  onPressed: () async {
                    final url = asset['browser_download_url'] as String?;
                    if (url != null) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: Text('تنزيل ${asset['name']}'),
                )),
            ] else
              const Padding(padding: EdgeInsets.only(top: 10), child: Text('لا يوجد ملف APK مرفق بهذا الإصدار حتى الآن.',
                style: TextStyle(color: muted, fontSize: 10))),
            if (_release!['html_url'] is String)
              TextButton(onPressed: () => launchUrl(Uri.parse(_release!['html_url'] as String), mode: LaunchMode.externalApplication),
                child: const Text('عرض صفحة الإصدار على GitHub')),
          ],
        ])),
      ]),
    );
  }
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
  static const phrases = ['سبحان الله', 'الحمد لله', 'الله أكبر'];
  final Map<String, int> counts = {for (final phrase in phrases) phrase: 0};
  int goal = 33;
  bool loaded = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      goal = prefs.getInt('tasbeeh_goal') ?? 33;
      for (var i = 0; i < phrases.length; i++) {
        counts[phrases[i]] = prefs.getInt('tasbeeh_count_$i') ??
            (i == 0 ? (prefs.getInt('tasbeeh_count') ?? 0) : 0);
      }
      loaded = true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbeeh_goal', goal);
    for (var i = 0; i < phrases.length; i++) {
      await prefs.setInt('tasbeeh_count_$i', counts[phrases[i]] ?? 0);
    }
    await prefs.setInt('tasbeeh_count', counts[phrases.first] ?? 0);
  }

  void _increment(String phrase) {
    setState(() => counts[phrase] = (counts[phrase] ?? 0) + 1);
    _save();
  }

  Future<void> _reset() async {
    setState(() { for (final phrase in phrases) { counts[phrase] = 0; } });
    await _save();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ink,
    appBar: AppBar(
      title: const Text('السبحة الإلكترونية'),
      backgroundColor: ink,
      actions: [IconButton(tooltip: 'تصفير جميع العدادات', onPressed: _reset, icon: const Icon(Icons.refresh_rounded))],
    ),
    body: !loaded ? const Center(child: CircularProgressIndicator()) : ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
      children: [
        GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('تسبيحك اليوم', style: TextStyle(color: muted, fontSize: 11)),
          const SizedBox(height: 5),
          Text('${counts.values.fold<int>(0, (sum, value) => sum + value)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
          const Text('إجمالي التسبيحات', style: TextStyle(color: muted, fontSize: 10)),
        ])),
        const SizedBox(height: 14),
        for (final phrase in phrases) Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _increment(phrase),
              child: GlassCard(child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(phrase, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Text('اضغط على الذكر لزيادة عداده • الهدف $goal', style: const TextStyle(color: muted, fontSize: 10)),
                ])),
                Container(
                  constraints: const BoxConstraints(minWidth: 58),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.09), borderRadius: BorderRadius.circular(15)),
                  child: Text('${counts[phrase]}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                ),
              ])),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () async {
            final controller = TextEditingController(text: goal.toString());
            final picked = await showDialog<int>(context: context, builder: (dialogContext) => AlertDialog(
              backgroundColor: panel,
              title: const Text('هدف التكرار'),
              content: TextField(controller: controller, keyboardType: TextInputType.number, autofocus: true,
                decoration: const InputDecoration(hintText: 'مثلاً 33')),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                TextButton(onPressed: () => Navigator.pop(dialogContext, int.tryParse(controller.text)), child: const Text('حفظ')),
              ],
            ));
            controller.dispose();
            if (picked != null && picked > 0) { setState(() => goal = picked); await _save(); }
          },
          icon: const Icon(Icons.flag_outlined),
          label: Text('تغيير الهدف الحالي: $goal'),
        ),
      ],
    ),
  );
}



class _HijriOccasion {
  final String title;
  final String hijriDate;
  final int day;
  final int month;
  final String note;
  const _HijriOccasion(this.title, this.hijriDate, this.day, this.month, this.note);
}

class HijriOccasionsPage extends StatefulWidget {
  const HijriOccasionsPage({super.key});
  @override
  State<HijriOccasionsPage> createState() => _HijriOccasionsPageState();
}

class _HijriOccasionsPageState extends State<HijriOccasionsPage> {
  List<Map<String, String>> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadEvents(); }

  String _dateString(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  Future<Map<String, dynamic>> _request(String url) async {
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['code'] != 200) throw Exception('تعذر تحويل التاريخ الهجري');
    return decoded['data'] as Map<String, dynamic>;
  }

  Future<String> _toGregorian(int day, int month, int year) async {
    final date = '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
    final data = await _request('https://api.aladhan.com/v1/hToG/$date?calendarMethod=HJCoSA');
    return (data['gregorian'] as Map<String, dynamic>)['date'] as String;
  }

  DateTime _parseGregorian(String value) {
    final parts = value.split('-').map(int.parse).toList();
    return DateTime(parts[2], parts[1], parts[0]);
  }

  Future<void> _loadEvents() async {
    try {
      final today = DateTime.now();
      final hijri = await _request('https://api.aladhan.com/v1/gToH/${_dateString(today)}?calendarMethod=HJCoSA');
      final currentYear = int.parse((hijri['hijri'] as Map<String, dynamic>)['year'].toString());
      const definitions = [
        _HijriOccasion('رأس السنة الهجرية', '1 محرّم', 1, 1, 'بداية العام الهجري الجديد.'),
        _HijriOccasion('يوم عاشوراء', '10 محرّم', 10, 1, 'يوافق اليوم العاشر من شهر محرّم.'),
        _HijriOccasion('المولد النبوي الشريف', '12 ربيع الأول', 12, 3, 'هذا هو التاريخ المتداول في بعض التقاويم، وتوجد أقوال أخرى في تحديد يوم المولد.'),
      ];
      final events = <Map<String, String>>[];
      for (final event in definitions) {
        var year = currentYear;
        var gregorian = await _toGregorian(event.day, event.month, year);
        if (_parseGregorian(gregorian).isBefore(DateTime(today.year, today.month, today.day))) {
          year++;
          gregorian = await _toGregorian(event.day, event.month, year);
        }
        events.add({
          'title': event.title,
          'hijri': '${event.hijriDate} ${year} هـ',
          'gregorian': gregorian,
          'note': event.note,
        });
      }
      events.sort((a, b) => _parseGregorian(a['gregorian']!).compareTo(_parseGregorian(b['gregorian']!)));
      if (mounted) setState(() { _events = events; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'تعذر جلب تواريخ المناسبات الآن. تحقق من اتصال الإنترنت وحاول مجددًا.'; });
    }
  }

  String _formatDate(String date) {
    final d = _parseGregorian(date);
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ink,
    appBar: AppBar(backgroundColor: ink, title: const Text('المناسبات الهجرية')),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : _events.isEmpty
        ? Center(child: Padding(padding: const EdgeInsets.all(22), child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_error ?? 'لا توجد بيانات متاحة', textAlign: TextAlign.center, style: const TextStyle(color: muted)),
            TextButton.icon(onPressed: () { setState(() { _loading = true; _error = null; }); _loadEvents(); },
              icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
          ])))
        : ListView(padding: const EdgeInsets.all(18), children: [
            for (final event in _events) Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => showModalBottomSheet(
                  context: context, backgroundColor: panel,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                  builder: (sheetContext) => SafeArea(child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Text(event['title']!, style: const TextStyle(color: white, fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Text('التاريخ الهجري المتوقع: ${event['hijri']}', style: const TextStyle(color: white)),
                      const SizedBox(height: 6),
                      Text('التاريخ الميلادي المتوقع: ${_formatDate(event['gregorian']!)}', style: const TextStyle(color: white)),
                      const SizedBox(height: 10),
                      Text(event['note']!, style: const TextStyle(color: muted, height: 1.8, fontSize: 11)),
                    ]),
                  )),
                ),
                child: GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(event['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('هجري: ${event['hijri']}', style: const TextStyle(color: white, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('ميلادي متوقع: ${_formatDate(event['gregorian']!)}', style: const TextStyle(color: muted, fontSize: 11)),
                  const SizedBox(height: 7),
                  const Text('اضغط لعرض التفاصيل', style: TextStyle(color: muted, fontSize: 10)),
                ])),
              ),
            ),
            const SizedBox(height: 4),
            const GlassCard(child: Text('تنبيه: التواريخ المعروضة تقديرية وفق تقويم حسابي، وقد تتقدم أو تتأخر يومًا بحسب ثبوت الهلال والرؤية الشرعية في بلدك.',
              style: TextStyle(color: muted, fontSize: 11, height: 1.8))),
          ]),
  );
}
