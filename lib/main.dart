import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'madinah_mushaf_reader_page.dart';

void main() => runApp(const MalazApp());

const ink = Color(0xFF07080B);
const panel = Color(0xFF15171C);
const white = Color(0xFFF5F5F7);
const muted = Color(0xFF9A9CA5);

class MalazApp extends StatelessWidget {
  const MalazApp({super.key});
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
  bool downloadingQuran = false;
  int downloadedSurahs = 0;
  @override
  void initState() { super.initState(); surahsFuture = loadSurahs(); loadLastRead(); }
  @override
  void dispose() { searchController.dispose(); super.dispose(); }
  Future<List<dynamic>> loadSurahs() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('malaz_quran_surah_index_v1');
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah')).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('تعذر تحميل فهرس السور');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['code'] != 200 || json['data'] is! List || (json['data'] as List).length != 114) {
        throw Exception('فهرس السور غير مكتمل أو غير صالح');
      }
      await prefs.setString('malaz_quran_surah_index_v1', jsonEncode(json['data']));
      return json['data'] as List<dynamic>;
    } catch (_) {
      if (cached != null) {
        final local = jsonDecode(cached) as List<dynamic>;
        if (local.length == 114) return local;
      }
      rethrow;
    }
  }

  Future<Directory> _quranOfflineDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/malaz_quran_text_v1');
    await directory.create(recursive: true);
    return directory;
  }

  Future<void> downloadAllSurahs() async {
    if (downloadingQuran) return;
    setState(() { downloadingQuran = true; downloadedSurahs = 0; });
    try {
      final all = await surahsFuture;
      final directory = await _quranOfflineDirectory();
      for (final raw in all) {
        final surah = raw as Map<String, dynamic>;
        final number = surah['number'] as int;
        final file = File('${directory.path}/$number.json');
        if (await file.exists()) {
          try {
            final local = jsonDecode(await file.readAsString()) as List<dynamic>;
            if (local.length == surah['numberOfAyahs']) {
              if (mounted) setState(() => downloadedSurahs++);
              continue;
            }
          } catch (_) {}
          await file.delete();
        }
        final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$number')).timeout(const Duration(seconds: 30));
        if (response.statusCode != 200) throw Exception('تعذر تنزيل سورة $number');
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final ayahs = json['data']?['ayahs'];
        if (json['code'] != 200 || ayahs is! List || ayahs.length != surah['numberOfAyahs']) {
          throw Exception('عدد آيات سورة $number غير مطابق للفهرس');
        }
        final temp = File('${file.path}.tmp');
        await temp.writeAsString(jsonEncode(ayahs), flush: true);
        if (await file.exists()) await file.delete();
        await temp.rename(file.path);
        if (mounted) setState(() => downloadedSurahs++);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اكتمل حفظ نص القرآن الكريم للعمل دون إنترنت.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('توقف تنزيل القرآن بعد حفظ $downloadedSurahs سورة. $e')));
    } finally {
      if (mounted) setState(() => downloadingQuran = false);
    }
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
      const SizedBox(height: 12),
      GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('القرآن دون إنترنت', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        const Text('احفظ نص السور الـ114 على جهازك لتتمكن من قراءتها دون اتصال.', style: TextStyle(color: muted, fontSize: 11, height: 1.6)),
        const SizedBox(height: 10),
        if (downloadingQuran) ...[
          LinearProgressIndicator(value: downloadedSurahs / 114, minHeight: 4),
          const SizedBox(height: 6),
          Text('تم حفظ $downloadedSurahs من 114 سورة', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: muted)),
        ],
        OutlinedButton.icon(
          onPressed: downloadingQuran ? null : downloadAllSurahs,
          icon: Icon(downloadingQuran ? Icons.downloading_rounded : Icons.download_for_offline_outlined, size: 18),
          label: Text(downloadingQuran ? 'جارٍ الحفظ...' : 'تنزيل نص القرآن كاملًا'),
        ),
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
    final root = await getApplicationDocumentsDirectory();
    final file = File('${root.path}/malaz_quran_text_v1/${widget.number}.json');
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/${widget.number}')).timeout(const Duration(seconds: 25));
      if (response.statusCode != 200) throw Exception('تعذر تحميل السورة');
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final ayahs = json['data']?['ayahs'];
      if (json['code'] != 200 || ayahs is! List || ayahs.length != widget.ayahCount) {
        throw Exception('بيانات السورة غير مكتملة أو غير مطابقة لعدد آياتها');
      }
      await file.parent.create(recursive: true);
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(jsonEncode(ayahs), flush: true);
      if (await file.exists()) await file.delete();
      await temp.rename(file.path);
      return ayahs;
    } catch (networkError) {
      if (await file.exists()) {
        final local = jsonDecode(await file.readAsString()) as List<dynamic>;
        if (local.length == widget.ayahCount) return local;
      }
      rethrow;
    }
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
class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});
  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
  static const _items = <Map<String, Object>>[
    {'title': 'سبحان الله وبحمده', 'text': 'سبحان الله وبحمده', 'count': 100},
    {'title': 'أستغفر الله', 'text': 'أستغفر الله وأتوب إليه', 'count': 100},
    {'title': 'سيد الاستغفار', 'text': 'اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك عليّ، وأبوء بذنبي فاغفر لي، فإنه لا يغفر الذنوب إلا أنت', 'count': 1},
    {'title': 'التسبيح بعد الصلاة', 'text': 'سبحان الله، والحمد لله، والله أكبر', 'count': 33},
    {'title': 'المعوذات', 'text': 'سورة الإخلاص، وسورة الفلق، وسورة الناس', 'count': 3},
  ];
  int _selected = 0;
  int _count = 0;
  @override
  void initState() { super.initState(); _restore(); }
  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _selected = (prefs.getInt('azkar_selected') ?? 0).clamp(0, _items.length - 1); _count = prefs.getInt('azkar_count') ?? 0; });
  }
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('azkar_selected', _selected);
    await prefs.setInt('azkar_count', _count);
  }
  void _choose(int index) {
    setState(() { _selected = index; _count = 0; });
    _persist();
  }
  @override
  Widget build(BuildContext context) {
    final item = _items[_selected];
    final target = item['count'] as int;
    return PageFrame(title: 'الأذكار', subtitle: 'أذكار مختارة مع عدّاد يحفظ تقدمك', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      GlassCard(child: Column(children: [
        Text(item['title'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        Text(item['text'] as String, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 19, height: 2, color: white)),
        const SizedBox(height: 16),
        Text('$_count / $target', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: (_count / target).clamp(0, 1).toDouble(), minHeight: 4),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () { setState(() => _count = 0); _persist(); }, icon: const Icon(Icons.refresh, size: 17), label: const Text('إعادة'))),
          const SizedBox(width: 9),
          Expanded(child: FilledButton.icon(onPressed: _count >= target ? null : () { setState(() => _count++); _persist(); }, icon: const Icon(Icons.touch_app, size: 17), label: const Text('تسبيح'))),
        ]),
      ])),
      const SizedBox(height: 14),
      const Text('اختر الذكر', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      for (var i = 0; i < _items.length; i++)
        Padding(padding: const EdgeInsets.only(bottom: 7), child: InkWell(onTap: () => _choose(i), borderRadius: BorderRadius.circular(18), child: GlassCard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: Row(children: [
          Icon(_selected == i ? Icons.radio_button_checked : Icons.radio_button_off, size: 18, color: _selected == i ? white : muted),
          const SizedBox(width: 10),
          Expanded(child: Text(_items[i]['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text('× ${_items[i]['count']}', style: const TextStyle(fontSize: 11, color: muted)),
        ])))),
    ]));
  }
}

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});
  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
  static const _names = ['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب', 'العشاء'];
  static const _keys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  Map<String, String>? _times;
  String? _locationLabel;
  String? _error;
  bool _loading = false;
  int _method = 5;
  @override
  void initState() { super.initState(); _restore(); }
  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _method = p.getInt('malaz_prayer_method') ?? 5; _locationLabel = p.getString('malaz_prayer_location_label'); });
    final saved = p.getString('malaz_prayer_times');
    if (saved != null) {
      try { final decoded = jsonDecode(saved) as Map<String, dynamic>; if (mounted) setState(() => _times = decoded.map((k,v) => MapEntry(k, v.toString()))); } catch (_) {}
    }
  }
  Future<void> _calculate() async {
    if (_loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      if (!service) throw Exception('فعّل خدمة الموقع في الهاتف أولًا.');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw Exception('اسمح لملاذ بالوصول إلى الموقع لحساب المواقيت.');
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)));
      final now = DateTime.now();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final date = DateComponents(now.year, now.month, now.day);
      final params = _method == 0 ? CalculationMethod.egyptian.getParameters()
          : _method == 1 ? CalculationMethod.muslim_world_league.getParameters()
          : _method == 2 ? CalculationMethod.umm_al_qura.getParameters()
          : CalculationMethod.karachi.getParameters();
      params.madhab = Madhab.shafi;
      final prayers = PrayerTimes(coordinates, date, params);
      final values = <String, String>{};
      final raw = [prayers.fajr, prayers.sunrise, prayers.dhuhr, prayers.asr, prayers.maghrib, prayers.isha];
      for (var i=0;i<_keys.length;i++) { values[_keys[i]] = TimeOfDay.fromDateTime(raw[i].toLocal()).format(context); }
      final p = await SharedPreferences.getInstance();
      await p.setString('malaz_prayer_times', jsonEncode(values));
      await p.setString('malaz_prayer_location_label', 'موقعك الحالي');
      await p.setInt('malaz_prayer_method', _method);
      if (!mounted) return;
      setState(() { _times = values; _locationLabel = 'موقعك الحالي'; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) => PageFrame(title: 'الصلاة', subtitle: 'مواقيت محسوبة حسب موقعك وطريقة الحساب', child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [const Icon(Icons.location_on_outlined, size: 20), const SizedBox(width: 8), Expanded(child: Text(_locationLabel ?? 'لم يتم تحديد الموقع', style: const TextStyle(fontWeight: FontWeight.w700))), if (_loading) const SizedBox(width: 18,height:18,child:CircularProgressIndicator(strokeWidth:2))]),
      const SizedBox(height: 12),
      DropdownButtonFormField<int>(value: _method, dropdownColor: panel, decoration: const InputDecoration(labelText: 'طريقة حساب المواقيت', border: OutlineInputBorder()), items: const [
        DropdownMenuItem(value: 0, child: Text('الهيئة المصرية العامة للمساحة')),
        DropdownMenuItem(value: 1, child: Text('رابطة العالم الإسلامي')),
        DropdownMenuItem(value: 2, child: Text('أم القرى')),
        DropdownMenuItem(value: 3, child: Text('كراتشي')),
      ], onChanged: (v) async { if (v == null) return; setState(() => _method=v); final p=await SharedPreferences.getInstance(); await p.setInt('malaz_prayer_method',v); _calculate(); }),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: _loading ? null : _calculate, icon: const Icon(Icons.my_location, size: 18), label: Text(_loading ? 'جارٍ تحديد الموقع والحساب...' : 'تحديد موقعي وحساب المواقيت')),
      if (_error != null) Padding(padding: const EdgeInsets.only(top:8), child: Text(_error!, style: const TextStyle(color: Colors.orangeAccent,fontSize:11))),
      const Padding(padding: EdgeInsets.only(top:8), child: Text('تُحفظ آخر مواقيت محسوبة على جهازك لعرضها عند انقطاع الإنترنت. أعد الحساب يوميًا لتحديثها.', style: TextStyle(color: muted,fontSize:10,height:1.6))),
    ])),
    const SizedBox(height: 12),
    for (var i=0;i<_names.length;i++) Padding(padding: const EdgeInsets.only(bottom:8), child: GlassCard(padding: const EdgeInsets.symmetric(horizontal:16,vertical:14), child: Row(children: [const Icon(Icons.access_time_rounded,size:18,color:muted),const SizedBox(width:12),Expanded(child:Text(_names[i])),Text(_times?[_keys[i]] ?? '--:--',style: const TextStyle(color:white,fontWeight:FontWeight.w700))]))),
    GlassCard(child: const Text('الأذان والتنبيهات والقبلة ستظهر هنا بعد تفعيل إعداداتها. لا يتم تشغيل صوت أو إرسال تنبيه دون اختيارك.', style: TextStyle(color:muted,fontSize:11,height:1.7))),
  ]));
}


class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});
  @override
  State<QiblaPage> createState() => _QiblaPageState();
}
class _QiblaPageState extends State<QiblaPage> {
  double? _bearing;
  String? _error;
  bool _loading = false;
  @override
  void initState() { super.initState(); _locate(); }
  Future<void> _locate() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw Exception('فعّل خدمة الموقع أولًا.');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw Exception('اسمح بالوصول للموقع لحساب اتجاه القبلة.');
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 20)));
      const kaabaLat = 21.422487;
      const kaabaLon = 39.826206;
      final lat1 = pos.latitude * math.pi / 180;
      final lat2 = kaabaLat * math.pi / 180;
      final dLon = (kaabaLon - pos.longitude) * math.pi / 180;
      final y = math.sin(dLon);
      final x = math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(dLon);
      final bearing = (math.atan2(y, x) * 180 / math.pi + 360) % 360;
      if (mounted) setState(() => _bearing = bearing);
    } catch (e) { if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', '')); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ink,
    appBar: AppBar(backgroundColor: ink, title: const Text('اتجاه القبلة')),
    body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.explore_outlined, size: 30, color: muted),
      const SizedBox(height: 14),
      if (_loading) const CircularProgressIndicator(),
      if (_bearing != null) ...[
        StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            final heading = snapshot.data?.heading;
            if (heading == null) return const Text('حساس البوصلة غير متاح أو يحتاج معايرة الهاتف.', textAlign: TextAlign.center, style: TextStyle(color: muted));
            final angle = (_bearing! - heading) * math.pi / 180;
            return Column(children: [
              Transform.rotate(angle: angle, child: const Icon(Icons.navigation_rounded, size: 150, color: white)),
              const SizedBox(height: 18),
              Text('اتجه نحو القبلة • ${_bearing!.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('اتجاه الهاتف: ${heading.toStringAsFixed(0)}°', style: const TextStyle(color: muted, fontSize: 12)),
            ]);
          },
        ),
      ],
      if (_error != null) Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.orangeAccent)),
      const SizedBox(height: 18),
      OutlinedButton.icon(onPressed: _loading ? null : _locate, icon: const Icon(Icons.my_location), label: const Text('تحديث موقعي')),
      const Padding(padding: EdgeInsets.only(top:14), child: Text('ضع الهاتف أفقيًا بعيدًا عن المعادن ومصادر التشويش، وحرّكه على شكل رقم 8 لمعايرة البوصلة. الاتجاه يتأثر بحساس جهازك.', textAlign: TextAlign.center, style: TextStyle(color: muted,fontSize:11,height:1.7))),
    ]))),
  );
}

class MorePage extends StatelessWidget {
  const MorePage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(title: 'المزيد', subtitle: 'أدواتك وإعدادات ملاذ', child: Column(children: [
    _MoreTile(icon: Icons.touch_app_rounded, title: 'السبحة الإلكترونية', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbeehPage()))),
    _MoreTile(icon: Icons.flag_outlined, title: 'الختمة والورد اليومي', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KhatmaPage()))),
    _MoreTile(icon: Icons.explore_outlined, title: 'اتجاه القبلة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaPage()))),
    _MoreTile(icon: Icons.notifications_none_rounded, title: 'التنبيهات والأذان'),
    _MoreTile(icon: Icons.language_rounded, title: 'اللغة'),
    _MoreTile(icon: Icons.text_fields_rounded, title: 'الخط والمظهر'),
    _MoreTile(icon: Icons.info_outline_rounded, title: 'عن ملاذ'),
  ]));
}

class _MoreTile extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback? onTap;
  const _MoreTile({required this.icon, required this.title, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 9), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: GlassCard(child: Row(children: [Icon(icon, size: 20, color: muted), const SizedBox(width: 13), Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))), const Icon(Icons.chevron_left, color: muted, size: 18)]))));
}


class KhatmaPage extends StatefulWidget {
  const KhatmaPage({super.key});
  @override
  State<KhatmaPage> createState() => _KhatmaPageState();
}

class _KhatmaPageState extends State<KhatmaPage> {
  int _pagesRead = 0;
  int _dailyGoal = 20;
  final _goalController = TextEditingController(text: '20');
  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _goalController.dispose(); super.dispose(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _pagesRead = (p.getInt('khatma_pages_read') ?? 0).clamp(0, 604); _dailyGoal = (p.getInt('khatma_daily_goal') ?? 20).clamp(1, 604); _goalController.text = '$_dailyGoal'; });
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('khatma_pages_read', _pagesRead);
    await p.setInt('khatma_daily_goal', _dailyGoal);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ink,
    appBar: AppBar(backgroundColor: ink, title: const Text('الختمة والورد اليومي')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      GlassCard(child: Column(children: [
        const Text('إنجاز ختمتك', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 18),
        Text('$_pagesRead / 604', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _pagesRead / 604, minHeight: 6),
        const SizedBox(height: 8),
        Text('متبقي ${604 - _pagesRead} صفحة', style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: _pagesRead == 0 ? null : () { setState(() => _pagesRead = (_pagesRead - 1).clamp(0, 604).toInt()); _save(); }, child: const Text('صفحة أقل'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton(onPressed: _pagesRead >= 604 ? null : () { setState(() => _pagesRead++); _save(); }, child: const Text('أتممت صفحة'))),
        ]),
      ])),
      const SizedBox(height: 14),
      GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('الورد اليومي', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('حدد عدد الصفحات التي تريد قراءتها يوميًا. المدة التقريبية للختمة تُحسب على هذا الأساس.', style: TextStyle(color: muted, fontSize: 11, height: 1.7)),
        const SizedBox(height: 8),
        TextField(controller: _goalController, keyboardType: TextInputType.number, style: const TextStyle(color: white), decoration: const InputDecoration(labelText: 'صفحات يوميًا', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () { final value = int.tryParse(_goalController.text.trim()); if (value == null || value < 1 || value > 604) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل عددًا من 1 إلى 604'))); return; } setState(() => _dailyGoal = value); _save(); }, child: const Text('حفظ الورد')),
        Text('الختمة خلال نحو ${(604 / _dailyGoal).ceil()} يومًا', textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 12)),
      ])),
      const SizedBox(height: 10),
      TextButton(onPressed: () async { final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('بدء ختمة جديدة؟'), content: const Text('سيتم تصفير عدد الصفحات المقروءة.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('إلغاء')), TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('تصفير'))])); if (ok == true) { setState(() => _pagesRead = 0); _save(); } }, child: const Text('بدء ختمة جديدة')),
    ]),
  );
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
