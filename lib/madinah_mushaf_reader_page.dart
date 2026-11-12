import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class MadinahMushafReaderPage extends StatefulWidget {
  const MadinahMushafReaderPage({super.key});

  @override
  State<MadinahMushafReaderPage> createState() => _MadinahMushafReaderPageState();
}

class _MadinahMushafReaderPageState extends State<MadinahMushafReaderPage> {
  static const int pageCount = 604;
  static const String release = 'v1.1.1';
  static const String commit = '3ff27b46cecb0c0519d77531d9c868a579d1f623';

  Map<String, dynamic>? _manifest;
  Directory? _cacheDirectory;
  final Map<int, Future<File>> _pageLoads = {};
  final PageController _pageController = PageController();
  int _page = 1;
  int _downloaded = 0;
  bool _downloading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialise();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initialise() async {
    try {
      final raw = await rootBundle.loadString('assets/mushaf/madinah_hafs_v4_manifest.json');
      final manifest = jsonDecode(raw) as Map<String, dynamic>;
      if (manifest['pageCount'] != pageCount || manifest['commit'] != commit) {
        throw Exception('ملف التحقق من صفحات المصحف غير مطابق للإصدار المعتمد.');
      }
      final docs = await getApplicationDocumentsDirectory();
      final directory = Directory('${docs.path}/madinah_hafs_v4');
      await directory.create(recursive: true);
      final prefs = await SharedPreferences.getInstance();
      final savedPage = prefs.getInt('madinah_mushaf_last_page') ?? 1;
      var downloaded = 0;
      for (var i = 1; i <= pageCount; i++) {
        if (await File('${directory.path}/$i.svg').exists()) downloaded++;
      }
      if (!mounted) return;
      setState(() {
        _manifest = manifest;
        _cacheDirectory = directory;
        _page = savedPage.clamp(1, pageCount).toInt();
        _downloaded = downloaded;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) _pageController.jumpToPage(_page - 1);
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'تعذر تهيئة المصحف: $e');
    }
  }

  String _expectedHash(int page) {
    final hashes = _manifest!['gitBlobSha1'] as Map<String, dynamic>;
    final value = hashes['$page'];
    if (value is! String || value.length != 40) {
      throw Exception('بصمة الصفحة $page غير موجودة في سجل التحقق.');
    }
    return value;
  }

  Future<bool> _isVerified(File file, int page) async {
    if (!await file.exists()) return false;
    final bytes = await file.readAsBytes();
    final header = utf8.encode('blob ${bytes.length}\u0000');
    return sha1.convert(<int>[...header, ...bytes]).toString() == _expectedHash(page);
  }

  Future<File> _loadPageOnce(int page) {
    return _pageLoads.putIfAbsent(page, () async {
      try {
        return await _ensurePage(page);
      } catch (_) {
        _pageLoads.remove(page);
        rethrow;
      }
    });
  }

  Future<void> _confirmAndDownloadAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.surface,
        title: Text('تنزيل المصحف كاملًا'),
        content: Text(
          'سيتم تنزيل الصفحات الـ604 وحفظها على جهازك لتعمل دون إنترنت. '
          'قد تحتاج إلى نحو 430 ميجابايت من مساحة التخزين، وقد يستهلك التنزيل بيانات الإنترنت. '
          'يفضل استخدام شبكة Wi-Fi.',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('ليس الآن')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('ابدأ التنزيل')),
        ],
      ),
    );
    if (confirmed == true) await _downloadAll();
  }

  Future<File> _ensurePage(int page) async {
    if (page < 1 || page > pageCount) throw RangeError.range(page, 1, pageCount);
    final directory = _cacheDirectory;
    if (directory == null || _manifest == null) {
      throw Exception('المصحف لم يكتمل تجهيزه بعد.');
    }
    final file = File('${directory.path}/$page.svg');
    if (await _isVerified(file, page)) return file;
    if (await file.exists()) await file.delete();

    final padded = page.toString().padLeft(3, '0');
    final urls = <String>[
      'https://cdn.quran.ws/svg/pages/$release/hafs-kfqc/$padded.svg',
      'https://raw.githubusercontent.com/quran-ws/quran-svg/$commit/mushafs/hafs/kfqc/svg/$padded.svg',
    ];
    Object? lastError;
    for (final url in urls) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 45));
        if (response.statusCode != 200) {
          throw HttpException('HTTP ${response.statusCode} عند تنزيل الصفحة $page');
        }
        final bytes = response.bodyBytes;
        if (bytes.isEmpty || !utf8.decode(bytes.take(200).toList(), allowMalformed: true).contains('<svg')) {
          throw FormatException('الملف المستلم ليس صفحة SVG صالحة: $page');
        }
        final header = utf8.encode('blob ${bytes.length}\u0000');
        final digest = sha1.convert(<int>[...header, ...bytes]).toString();
        if (digest != _expectedHash(page)) {
          throw FormatException('فشل التحقق من سلامة الصفحة $page؛ لم يتم حفظها.');
        }
        final temp = File('${file.path}.tmp');
        await temp.writeAsBytes(bytes, flush: true);
        if (await file.exists()) await file.delete();
        await temp.rename(file.path);
        return file;
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('تعذر تحميل الصفحة $page من المصدرين. ${lastError ?? ''}');
  }

  Future<void> _showPage(int page) async {
    if (!mounted) return;
    setState(() {
      _page = page;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('madinah_mushaf_last_page', page);
    _loadPageOnce(page);
    if (page < pageCount) _loadPageOnce(page + 1);
    if (mounted) setState(() {});
  }

  Future<void> _downloadAll() async {
    if (_downloading || _manifest == null) return;
    setState(() {
      _downloading = true;
      _downloaded = 0;
      _error = null;
    });
    var completed = 0;
    try {
      for (var start = 1; start <= pageCount; start += 4) {
        final end = (start + 3).clamp(1, pageCount).toInt();
        final batch = List.generate(end - start + 1, (i) => start + i);
        await Future.wait(batch.map((page) async {
          await _loadPageOnce(page);
          completed++;
          if (mounted) setState(() => _downloaded = completed);
        }));
      }
      if (mounted) {
        setState(() => _downloaded = pageCount);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اكتمل تنزيل صفحات مصحف المدينة الـ604 والتحقق منها. يمكنك القراءة دون إنترنت.')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'توقف التنزيل بعد التحقق من $completed صفحة في هذه المحاولة. $e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _goToPageDialog() async {
    final controller = TextEditingController(text: '$_page');
    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17191E),
        title: Text('الانتقال إلى صفحة'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'من 1 إلى 604'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء')),
          TextButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              if (parsed != null && parsed >= 1 && parsed <= pageCount) Navigator.pop(context, parsed);
            },
            child: Text('انتقال'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) {
      _pageController.animateToPage(value - 1, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      _showPage(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _manifest != null && _cacheDirectory != null;
    return Scaffold(
      backgroundColor: const Color(0xFF08090C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF08090C),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مصحف المدينة النبوية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            Text('رواية حفص • مجمع الملك فهد • 604 صفحة', style: TextStyle(fontSize: 10, color: AppPalette.muted)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تنزيل المصحف كاملًا للعمل دون إنترنت',
            onPressed: ready && !_downloading ? _confirmAndDownloadAll : null,
            icon: Icon(Icons.download_for_offline_outlined),
          ),
          IconButton(tooltip: 'انتقال إلى صفحة', onPressed: ready ? _goToPageDialog : null, icon: Icon(Icons.find_in_page_outlined)),
        ],
      ),
      body: !ready
          ? Center(child: _error == null
              ? const CircularProgressIndicator()
              : Padding(padding: const EdgeInsets.all(20), child: Text(_error!, textAlign: TextAlign.center)))
          : Column(
              children: [
                if (_downloading || _downloaded > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_downloading ? 'جارٍ تنزيل صفحات المصحف والتحقق منها' : 'الصفحات المحفوظة على الجهاز'),
                            Text('$_downloaded / $pageCount', style: TextStyle(fontSize: 11, color: AppPalette.foreground)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(value: _downloaded / pageCount, minHeight: 4),
                      ],
                    ),
                  ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(_error!, style: TextStyle(color: Colors.orangeAccent, fontSize: 11), textAlign: TextAlign.center),
                  ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pageCount,
                    onPageChanged: _showPage,
                    itemBuilder: (context, index) {
                      final page = index + 1;
                      final future = _loadPageOnce(page);
                      return FutureBuilder<File>(
                        future: future,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cloud_off_outlined, color: AppPalette.muted, size: 30),
                                  const SizedBox(height: 10),
                                  Text('تعذر تحميل الصفحة $page', style: TextStyle(color: AppPalette.foreground)),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _pageLoads.remove(page);
                                      _loadPageOnce(page);
                                    }),
                                    child: Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F0E3),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 5))],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: SvgPicture.file(
                                  snapshot.data!,
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  placeholderBuilder: (_) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
