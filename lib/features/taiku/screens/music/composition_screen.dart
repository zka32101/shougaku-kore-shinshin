import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/composition.dart';
import '../../providers/composition_provider.dart';
import '../../utils/piano_audio.dart';
import '../stage_learn_screen.dart';
import 'free_piano_screen.dart' show PianoKeyboard;

const _noteColors = {
  'C': Color(0xFFE74C3C),
  'D': Color(0xFFE67E22),
  'E': Color(0xFFF1C40F),
  'F': Color(0xFF27AE60),
  'G': Color(0xFF2980B9),
  'A': Color(0xFF8E44AD),
  'B': Color(0xFFE91E8C),
};

const _japaneseNotes = {
  'C': 'ド', 'C#': 'ド♯', 'D': 'レ', 'D#': 'レ♯', 'E': 'ミ',
  'F': 'ファ', 'F#': 'ファ♯', 'G': 'ソ', 'G#': 'ソ♯', 'A': 'ラ', 'A#': 'ラ♯', 'B': 'シ',
};

class CompositionScreen extends ConsumerStatefulWidget {
  const CompositionScreen({super.key});

  @override
  ConsumerState<CompositionScreen> createState() => _CompositionScreenState();
}

class _CompositionScreenState extends ConsumerState<CompositionScreen> {
  final _player = PianoPlayer();
  final Set<String> _pressedKeys = {};
  final List<CompositionNote> _recordedNotes = [];
  DateTime? _lastPressTime;
  bool _isPlaying = false;

  static const _minDurationMs = 150;
  static const _maxDurationMs = 2000;
  static const _defaultDurationMs = 400;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _pressKey(String note) {
    final now = DateTime.now();
    if (_lastPressTime != null && _recordedNotes.isNotEmpty) {
      final elapsed = now.difference(_lastPressTime!).inMilliseconds;
      _recordedNotes[_recordedNotes.length - 1] = CompositionNote(
        note: _recordedNotes.last.note,
        durationMs: elapsed.clamp(_minDurationMs, _maxDurationMs),
      );
    }
    _lastPressTime = now;

    setState(() {
      _pressedKeys.add(note);
      _recordedNotes.add(CompositionNote(note: note, durationMs: _defaultDurationMs));
    });
    _player.playTone(note);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _pressedKeys.remove(note));
    });
  }

  void _clear() {
    setState(() {
      _recordedNotes.clear();
      _lastPressTime = null;
    });
  }

  Future<void> _playback() async {
    if (_recordedNotes.isEmpty || _isPlaying) return;
    setState(() => _isPlaying = true);
    for (final n in _recordedNotes) {
      if (!mounted) break;
      await _player.playTone(n.note);
      await Future.delayed(Duration(milliseconds: n.durationMs));
    }
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _saveComposition() async {
    if (_recordedNotes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('まず何か演奏してみよう！')),
      );
      return;
    }

    final titleCtrl = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('曲を保存しよう'),
        content: TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: '曲のタイトル',
            hintText: '例：わたしのメロディー',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              context,
              titleCtrl.text.isEmpty ? 'わたしのメロディー' : titleCtrl.text,
            ),
            child: const Text('保存する'),
          ),
        ],
      ),
    );

    if (title == null || !mounted) return;

    final composition = Composition(
      id: const Uuid().v4(),
      title: title,
      notes: List.of(_recordedNotes),
      createdAt: DateTime.now(),
    );
    await ref.read(compositionProvider.notifier).add(composition);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎼 曲を保存しました！')),
    );
    _clear();
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF1A1A2E);
    const darkBar = Color(0xFF16213E);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('🎼 作曲する'),
        backgroundColor: darkBar,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'クイズに挑戦',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const StageLearnScreen(
                stageNum: 31,
                emoji: '🎼',
                title: '作曲にちょうせん',
                theme: 'music',
                color: Color(0xFF9C27B0),
              ),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clear,
            tooltip: 'クリア',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF0F3460),
            child: const Text(
              '✨ 鍵盤を弾いて曲を作ろう！保存すると後で聴き直せるよ',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _recordedNotes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🎼', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 8),
                          Text(
                            '鍵盤を弾くと音符が記録されるよ！',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      reverse: true,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _recordedNotes.map((n) {
                          final base = n.note.replaceAll('#', '');
                          final color = _noteColors[base] ?? const Color(0xFF9C27B0);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _japaneseNotes[n.note] ?? n.note,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isPlaying ? null : _playback,
                    icon: Icon(_isPlaying ? Icons.hourglass_top : Icons.play_arrow, color: Colors.white),
                    label: Text(_isPlaying ? '再生中...' : '再生する', style: const TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveComposition,
                    icon: const Icon(Icons.save),
                    label: const Text('保存する'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: PianoKeyboard(
              onKeyPress: _pressKey,
              pressedKeys: _pressedKeys,
              noteColors: _noteColors,
            ),
          ),
        ],
      ),
    );
  }
}
