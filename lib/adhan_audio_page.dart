import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AdhanRecording {
  final String id, title, creator, duration, url, sha1, filename, licenseUrl, licenseLabel;
  final String? gitBlobSha1;
  const _AdhanRecording({
    required this.id, required this.title, required this.creator,
    required this.duration, required this.url, required this.sha1,
    required this.filename, required this.licenseUrl, required this.licenseLabel,
    this.gitBlobSha1,
  });
}

class AdhanAudioPage extends StatefulWidget {
  const AdhanAudioPage({super.key});
  @override
  State<AdhanAudioPage> createState() => _AdhanAudioPageState();
}

class _AdhanAudioPageState extends State<AdhanAudioPage> {
  static const _recordings = [
    _AdhanRecording(
      id: 'aishatu98',
      title: 'تسجيل أذان قصير',
      creator: 'Aishatu98 — Wikimedia Commons',
      duration: '42 ثانية',
      url: 'https://upload.wikimedia.org/wikipedia/commons/e/e7/Adhan.ogg',
      sha1: 'b86432f1581e11f898de1dc3402af0d541af110e',
      filename: 'adhan_aishatu98.ogg',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Adhan.ogg',
      licenseLabel: 'CC0 1.0 — حر الاستخدام وإعادة التوزيع',
    ),
    _AdhanRecording(
      id: 'ejaz215_madinah',
      title: 'أذان المسجد النبوي – المدينة',
      creator: 'ejaz215 — Wikimedia Commons',
      duration: '3 دقائق و7 ثوانٍ',
      url: 'https://upload.wikimedia.org/wikipedia/commons/7/7c/33937_ejaz215_call-to-prayer-from-the-prophet-s-mo.ogg',
      sha1: '4aa432b9e44804e7d72af4429bd743aa5fa9e3a4',
      filename: 'adhan_madinah_ejaz215.ogg',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:33937_ejaz215_call-to-prayer-from-the-prophet-s-mo.ogg',
      licenseLabel: 'CC BY 3.0 — يلزم ذكر المصدر وصاحب التسجيل',
    ),
    _AdhanRecording(
      id: 'adam_synagda',
      title: 'تسجيل أذان طويل',
      creator: 'Adam-synagda — Wikimedia Commons',
      duration: 'دقيقتان و34 ثانية',
      url: 'https://upload.wikimedia.org/wikipedia/commons/b/b0/Beautiful_adhan.ogg',
      sha1: 'a1fa4fd942401922c5c3301816384aae86956522',
      filename: 'beautiful_adhan_adam.ogg',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Beautiful_adhan.ogg',
      licenseLabel: 'CC0 1.0 — حر الاستخدام وإعادة التوزيع',
    ),
    _AdhanRecording(
      id: 'aaqib_azeez',
      title: 'أذان عاقب عزيز',
      creator: 'Aaqib Azeez — Wikimedia Commons (معالجة صوتية من Taqwa)',
      duration: 'دقيقة و26 ثانية',
      url: 'https://raw.githubusercontent.com/MohamedAbulgasem/Taqwa/29fba6b08c9af3b6aac264b58095afff1799d786/shared/src/androidMain/res/raw/adhan_azeez_full.ogg',
      sha1: '',
      gitBlobSha1: '3793b9da12af6cd2f0ce0970c0341efe75ef83df',
      filename: 'adhan_aaqib_azeez.ogg',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:The_Adhan_-_Muslim_Call_to_Prayer_-_Aaqib_Azeez.mp3',
      licenseLabel: 'CC BY-SA 4.0 — مع ذكر المصدر وإتاحة التعديلات بنفس الترخيص',
    ),
    _AdhanRecording(
      id: 'makkah_haram',
      title: 'أذان المسجد الحرام – مكة',
      creator: 'Seyfula Islam — Wikimedia Commons (معالجة صوتية من Taqwa)',
      duration: '3 دقائق و9 ثوانٍ',
      url: 'https://raw.githubusercontent.com/MohamedAbulgasem/Taqwa/29fba6b08c9af3b6aac264b58095afff1799d786/shared/src/androidMain/res/raw/adhan_makkah_full.ogg',
      sha1: '',
      gitBlobSha1: '87b65a2a445aec4e65c9de89b5280555a90e3972',
      filename: 'adhan_makkah_haram.ogg',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Adhan,_Great_Mosque_of_Mecca_-_Jan_21,_2013.webm',
      licenseLabel: 'CC BY 3.0 — يلزم ذكر المصدر وصاحب التسجيل',
    ),
    _AdhanRecording(
      id: 'besim_azemi',
      title: 'أذان بسيم أزيمي – تسجيل الفجر',
      creator: 'Besim Azemi / Islamic Center Malmö (معالجة صوتية من Taqwa)',
      duration: '3 دقائق و31 ثانية',
      url: 'https://raw.githubusercontent.com/MohamedAbulgasem/Taqwa/29fba6b08c9af3b6aac264b58095afff1799d786/shared/src/androidMain/res/raw/adhan_azemi_full.ogg',
      sha1: '',
      gitBlobSha1: '822070bf72818d9d52390b715ac412f242577c2a',
      filename: 'adhan_besim_azemi.ogg',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Eid_al-Fitr_Fajr_azan_at_Malm%C3%B6_Mosque_-_19_August_2012.webm',
      licenseLabel: 'CC BY 3.0 — يلزم ذكر المصدر وصاحب التسجيل؛ تمت إزالة صيغة الفجر الخاصة ليصلح كأذان عام',
    ),
    _AdhanRecording(
      id: 'sabah_fakhri',
      title: 'أذان صباح فخري',
      creator: 'صباح فخري — تسجيل مؤرخ بعام 1985، عبر Wikimedia Commons',
      duration: 'دقيقتان و38 ثانية',
      url: 'https://upload.wikimedia.org/wikipedia/commons/2/27/Call_to_prayer_by_Sabah_Fakhry.mp3',
      sha1: 'a76718d98e7495a930ce9c024d94dba98f490a1f',
      filename: 'adhan_sabah_fakhri.mp3',
      licenseUrl: 'https://commons.wikimedia.org/wiki/File:Call_to_prayer_by_Sabah_Fakhry.mp3',
      licenseLabel: 'Public Domain Mark 1.0 — مصنف كملكية عامة وفق صفحة المصدر',
    ),
  ];

  final AudioPlayer _player = AudioPlayer();
  String _selectedId = 'aishatu98';
  String? _downloadedId;
  File? _audioFile;
  bool _downloading = false;
  bool _playing = false;
  String? _error;

  _AdhanRecording get _selected =>
      _recordings.firstWhere((item) => item.id == _selectedId);

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state == PlayerState.playing);
    });
  }

  Future<File> _fileFor(_AdhanRecording recording) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/${recording.filename}');
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('adhan_selected_recording') ?? 'aishatu98';
    final selected = _recordings.any((item) => item.id == saved) ? saved : 'aishatu98';
    final downloaded = prefs.getString('adhan_downloaded_recording');
    _AdhanRecording? recording;
    for (final item in _recordings) {
      if (item.id == downloaded) { recording = item; break; }
    }
    File? file;
    if (recording != null) {
      final candidate = await _fileFor(recording);
      if (await candidate.exists()) file = candidate;
    }
    if (!mounted) return;
    setState(() {
      _selectedId = selected;
      _downloadedId = file == null ? null : downloaded;
      _audioFile = file;
    });
  }

  Future<void> _select(_AdhanRecording recording) async {
    await _player.stop();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('adhan_selected_recording', recording.id);
    final file = await _fileFor(recording);
    final exists = await file.exists();
    if (!mounted) return;
    setState(() {
      _selectedId = recording.id;
      _audioFile = exists ? file : null;
      _downloadedId = exists ? recording.id : null;
      _error = null;
    });
  }

  Future<void> _download() async {
    final recording = _selected;
    setState(() { _downloading = true; _error = null; });
    try {
      final response = await http.get(Uri.parse(recording.url))
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) {
        throw Exception('تعذر تنزيل الملف (HTTP ${response.statusCode}).');
      }
      final digest = sha1.convert(response.bodyBytes).toString();
      final gitBlobDigest = sha1.convert(<int>[
        ...utf8.encode('blob ${response.bodyBytes.length}\u0000'),
        ...response.bodyBytes,
      ]).toString();
      final validDigest = recording.gitBlobSha1 == null
          ? digest == recording.sha1
          : gitBlobDigest == recording.gitBlobSha1;
      if (!validDigest) {
        throw Exception('فشل التحقق من بصمة الملف؛ لم يتم حفظه.');
      }
      final file = await _fileFor(recording);
      await file.writeAsBytes(response.bodyBytes, flush: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('adhan_downloaded_recording', recording.id);
      if (!mounted) return;
      setState(() {
        _audioFile = file;
        _downloadedId = recording.id;
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'لم يكتمل التنزيل: $e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _play() async {
    final file = _audioFile;
    if (file == null || !await file.exists()) return;
    await _player.play(DeviceFileSource(file.path));
  }

  Future<void> _stop() => _player.stop();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07080B),
        title: const Text('الأذان واختيار الصوت'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('اختر تسجيلًا للمعاينة', style: TextStyle(
            color: Color(0xFFF5F5F7), fontWeight: FontWeight.w800, fontSize: 16,
          )),
          const SizedBox(height: 10),
          for (final recording in _recordings)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _downloading ? null : () => _select(recording),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(_selectedId == recording.id ? .11 : .045),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(_selectedId == recording.id ? .25 : .08)),
                  ),
                  child: Row(children: [
                    Icon(_selectedId == recording.id ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: const Color(0xFFF5F5F7), size: 19),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(recording.title, style: const TextStyle(color: Color(0xFFF5F5F7), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text('${recording.creator} • ${recording.duration}',
                        style: const TextStyle(color: Color(0xFF9A9CA5), fontSize: 10)),
                    ])),
                    if (_downloadedId == recording.id)
                      const Icon(Icons.offline_pin_rounded, color: Color(0xFFB7D8C4), size: 19),
                  ]),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.055),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(.1)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(selected.title, style: const TextStyle(color: Color(0xFFF5F5F7), fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                'الترخيص: ${selected.licenseLabel}. راجع رابط المصدر لمعرفة شروط النسب وإعادة الاستخدام. أسماء رافعي الملفات لا تعني بالضرورة أنهم المؤذنون؛ لا نذكر اسم مؤذن إلا إذا وثّقه مصدر التسجيل.',
                style: const TextStyle(color: Color(0xFF9A9CA5), fontSize: 11, height: 1.8),
              ),
              const SizedBox(height: 13),
              if (_audioFile == null)
                SizedBox(width: double.infinity, child: FilledButton.icon(
                  onPressed: _downloading ? null : _download,
                  icon: _downloading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_rounded),
                  label: Text(_downloading ? 'جارٍ التنزيل والتحقق...' : 'تنزيل التسجيل للاستخدام دون إنترنت'),
                ))
              else ...[
                const Row(children: [
                  Icon(Icons.offline_pin_rounded, color: Color(0xFFB7D8C4)),
                  SizedBox(width: 8),
                  Text('التسجيل محفوظ على الجهاز', style: TextStyle(color: Color(0xFFF5F5F7), fontSize: 12)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: FilledButton.icon(
                    onPressed: _playing ? null : _play,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('معاينة'),
                  )),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _playing ? _stop : null,
                    icon: const Icon(Icons.stop_circle_outlined),
                    tooltip: 'إيقاف',
                  ),
                ]),
              ],
              if (_error != null) ...[
                const SizedBox(height: 9),
                Text(_error!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
              ],
              const SizedBox(height: 8),
              SelectableText('المصدر والترخيص: ${selected.licenseUrl}',
                style: const TextStyle(color: Color(0xFF9A9CA5), fontSize: 10)),
            ]),
          ),
        ],
      ),
    );
  }
}
