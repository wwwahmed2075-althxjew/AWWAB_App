import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AdhanAudioPage extends StatefulWidget {
  const AdhanAudioPage({super.key});
  @override
  State<AdhanAudioPage> createState() => _AdhanAudioPageState();
}

class _AdhanAudioPageState extends State<AdhanAudioPage> {
  static final Uri _source = Uri.parse(
    'https://upload.wikimedia.org/wikipedia/commons/e/e7/Adhan.ogg',
  );
  static const String _expectedSha1 =
      'b86432f1581e11f898de1dc3402af0d541af110e';
  final AudioPlayer _player = AudioPlayer();
  File? _audioFile;
  bool _downloading = false;
  bool _playing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocalAudio();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state == PlayerState.playing);
    });
  }

  Future<File> _targetFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/adhan_cc0.ogg');
  }

  Future<void> _loadLocalAudio() async {
    final file = await _targetFile();
    if (!mounted) return;
    if (await file.exists()) setState(() => _audioFile = file);
  }

  Future<void> _download() async {
    setState(() { _downloading = true; _error = null; });
    try {
      final response = await http.get(_source).timeout(const Duration(seconds: 45));
      if (response.statusCode != 200) {
        throw Exception('تعذر تنزيل الملف (HTTP ${response.statusCode}).');
      }
      final digest = sha1.convert(response.bodyBytes).toString();
      if (digest != _expectedSha1) {
        throw Exception('فشل التحقق من سلامة الملف؛ لم يتم حفظه.');
      }
      final file = await _targetFile();
      await file.writeAsBytes(response.bodyBytes, flush: true);
      if (!mounted) return;
      setState(() => _audioFile = file);
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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF07080B),
    appBar: AppBar(
      backgroundColor: const Color(0xFF07080B),
      title: const Text('الأذان واختيار الصوت'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.055),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(.11)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('أذان تجريبي مجاني', style: TextStyle(
                color: Color(0xFFF5F5F7), fontSize: 17,
                fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: 8),
              const Text(
                'تسجيل أذان منشور بترخيص CC0؛ يمكنك تنزيله مرة واحدة ثم تشغيله دون إنترنت.',
                style: TextStyle(color: Color(0xFF9A9CA5), height: 1.7, fontSize: 12),
              ),
              const SizedBox(height: 14),
              if (_audioFile == null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _downloading ? null : _download,
                    icon: _downloading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download_rounded),
                    label: Text(_downloading ? 'جارٍ التنزيل والتحقق...' : 'تنزيل الأذان للاستخدام دون إنترنت'),
                  ),
                )
              else ...[
                const Row(children: [
                  Icon(Icons.offline_pin_rounded, color: Color(0xFFB7D8C4)),
                  SizedBox(width: 8),
                  Expanded(child: Text('تم حفظ التسجيل على الجهاز', style: TextStyle(color: Color(0xFFF5F5F7)))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: FilledButton.icon(
                    onPressed: _playing ? null : _play,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('معاينة الأذان'),
                  )),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _playing ? _stop : null,
                    icon: const Icon(Icons.stop_circle_outlined),
                    tooltip: 'إيقاف',
                  ),
                ]),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.035),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'الترخيص والمصدر: Adhan.ogg — Aishatu98، Wikimedia Commons، ترخيص CC0 1.0. مدة التسجيل نحو 42 ثانية. هذا تسجيل واحد متاح الترخيص، وليس منسوبًا إلى شيخ معروف. لن نضيف أسماء مؤذنين أو تسجيلاتهم إلا بعد التحقق من ترخيص كل ملف على حدة.',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: Color(0xFF9A9CA5), fontSize: 11, height: 1.8),
          ),
        ),
      ],
    ),
  );
}
