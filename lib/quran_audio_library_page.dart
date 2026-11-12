import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_theme.dart';

class _MiladhReciter {
  final String name;
  final String edition;
  const _MiladhReciter(this.name, this.edition);
}

class QuranAudioLibraryPage extends StatefulWidget {
  const QuranAudioLibraryPage({super.key});

  @override
  State<QuranAudioLibraryPage> createState() => _QuranAudioLibraryPageState();
}

class _QuranAudioLibraryPageState extends State<QuranAudioLibraryPage> {
  static const _reciters = [
    _MiladhReciter('مشاري العفاسي', 'ar.alafasy'),
    _MiladhReciter('محمود خليل الحصري', 'ar.husary'),
    _MiladhReciter('محمد صديق المنشاوي', 'ar.minshawi'),
    _MiladhReciter('عبدالرحمن السديس', 'ar.sudais'),
    _MiladhReciter('سعود الشريم', 'ar.shuraim'),
    _MiladhReciter('عبدالباسط عبدالصمد', 'ar.abdulbasit'),
    _MiladhReciter('علي الحذيفي', 'ar.hudhaify'),
  ];

  final AudioPlayer _player = AudioPlayer();
  List<dynamic> _surahs = [];
  int _surahNumber = 1;
  int _reciterIndex = 0;
  PlayerState _state = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _loading = true;
  bool _seeking = false;
  String? _error;

  String get _audioUrl =>
      'https://cdn.islamic.network/quran/audio-surah/128/${_reciters[_reciterIndex].edition}/$_surahNumber.mp3';

  Map<String, dynamic>? get _selectedSurah {
    for (final item in _surahs) {
      if ((item as Map<String, dynamic>)['number'] == _surahNumber) return item;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadSurahs();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _state = state);
    });
    _player.onPositionChanged.listen((position) {
      if (mounted && !_seeking) setState(() => _position = position);
    });
    _player.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() { _state = PlayerState.completed; _position = _duration; });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadSurahs() async {
    try {
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah'))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) throw Exception('تعذر تحميل فهرس السور');
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      if (decoded['code'] != 200) throw Exception('مصدر فهرس السور لم يستجب');
      if (!mounted) return;
      setState(() { _surahs = decoded['data'] as List<dynamic>; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = 'تعذر تحميل قائمة السور. تحقق من الإنترنت وحاول مرة أخرى.'; });
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_state == PlayerState.playing) {
        await _player.pause();
      } else if (_state == PlayerState.paused) {
        await _player.resume();
      } else {
        setState(() { _error = null; _position = Duration.zero; _duration = Duration.zero; });
        await _player.play(UrlSource(_audioUrl));
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تشغيل التلاوة. قد يكون الملف غير متاح مؤقتًا؛ جرّب قارئًا آخر أو أعد المحاولة.');
    }
  }

  Future<void> _changeSelection({int? surah, int? reciter}) async {
    await _player.stop();
    if (!mounted) return;
    setState(() {
      if (surah != null) _surahNumber = surah;
      if (reciter != null) _reciterIndex = reciter;
      _position = Duration.zero;
      _duration = Duration.zero;
      _state = PlayerState.stopped;
      _error = null;
    });
  }

  String _time(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppPalette.background,
    appBar: AppBar(backgroundColor: AppPalette.background, title: const Text('المكتبة الصوتية للقرآن')),
    body: _loading
      ? const Center(child: CircularProgressIndicator())
      : _surahs.isEmpty
        ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_error ?? 'تعذر تحميل السور', textAlign: TextAlign.center, style: TextStyle(color: AppPalette.muted)),
            TextButton.icon(onPressed: () { setState(() { _loading = true; _error = null; }); _loadSurahs(); },
              icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
          ])))
        : ListView(padding: const EdgeInsets.all(18), children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(color: AppPalette.cardOverlay, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppPalette.cardBorder)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('القارئ', style: TextStyle(color: AppPalette.muted, fontSize: 11)),
                const SizedBox(height: 7),
                DropdownButtonFormField<int>(
                  value: _reciterIndex,
                  isExpanded: true,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  items: List.generate(_reciters.length, (index) => DropdownMenuItem(
                    value: index, child: Text(_reciters[index].name, overflow: TextOverflow.ellipsis))),
                  onChanged: (value) { if (value != null) _changeSelection(reciter: value); },
                ),
                const SizedBox(height: 14),
                Text('السورة', style: TextStyle(color: AppPalette.muted, fontSize: 11)),
                const SizedBox(height: 7),
                DropdownButtonFormField<int>(
                  value: _surahNumber,
                  isExpanded: true,
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  items: _surahs.map((raw) {
                    final item = raw as Map<String, dynamic>;
                    return DropdownMenuItem<int>(value: item['number'] as int, child: Text('${item['number']}. ${item['name']}'));
                  }).toList(),
                  onChanged: (value) { if (value != null) _changeSelection(surah: value); },
                ),
                const SizedBox(height: 18),
                Center(child: Text(_selectedSurah?['name'] as String? ?? '', style: TextStyle(color: AppPalette.foreground, fontSize: 19, fontWeight: FontWeight.w800))),
                const SizedBox(height: 5),
                Center(child: Text(_reciters[_reciterIndex].name, style: TextStyle(color: AppPalette.muted, fontSize: 11))),
                const SizedBox(height: 14),
                Slider(
                  value: _duration.inMilliseconds <= 0 ? 0 : _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble(),
                  max: _duration.inMilliseconds <= 0 ? 1 : _duration.inMilliseconds.toDouble(),
                  onChangeStart: (_) => _seeking = true,
                  onChanged: _duration.inMilliseconds <= 0 ? null : (value) => setState(() => _position = Duration(milliseconds: value.round())),
                  onChangeEnd: (value) { _seeking = false; _player.seek(Duration(milliseconds: value.round())); },
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_time(_position), style: TextStyle(color: AppPalette.muted, fontSize: 10)),
                  Text(_time(_duration), style: TextStyle(color: AppPalette.muted, fontSize: 10)),
                ]),
                const SizedBox(height: 10),
                Center(child: IconButton.filled(
                  onPressed: _togglePlayback,
                  iconSize: 30,
                  padding: const EdgeInsets.all(15),
                  icon: Icon(_state == PlayerState.playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  tooltip: _state == PlayerState.playing ? 'إيقاف مؤقت' : 'تشغيل التلاوة',
                )),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 11), textAlign: TextAlign.center),
                ],
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppPalette.cardOverlay, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppPalette.cardBorder)),
              child: Text(
                'مصدر التلاوات: شبكة Al Quran Cloud المفتوحة. التشغيل يحتاج إلى اتصال بالإنترنت. لم نفعّل تنزيل الملفات بعد، لأن إتاحة البث لا تعني تلقائيًا وجود إذن بإعادة توزيع التسجيلات أو حفظها داخل التطبيق.',
                style: TextStyle(color: AppPalette.muted, fontSize: 10, height: 1.8),
              ),
            ),
          ]),
  );
}
