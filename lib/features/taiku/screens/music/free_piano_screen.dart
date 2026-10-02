import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../taiku_app.dart';
import '../../utils/piano_audio.dart';
import '../stage_learn_screen.dart';

class FreePianoScreen extends ConsumerStatefulWidget {
  const FreePianoScreen({super.key});

  @override
  ConsumerState<FreePianoScreen> createState() => _FreePianoScreenState();
}

class _FreePianoScreenState extends ConsumerState<FreePianoScreen> {
  final List<String> _playedNotes = [];
  final Set<String> _pressedKeys = {};
  bool _badgeAwarded = false;
  final _player = PianoPlayer();

  static const _noteColors = {
    'C': Color(0xFFE74C3C),
    'D': Color(0xFFE67E22),
    'E': Color(0xFFF1C40F),
    'F': Color(0xFF27AE60),
    'G': Color(0xFF2980B9),
    'A': Color(0xFF8E44AD),
    'B': Color(0xFFE91E8C),
  };

  static const _japaneseNotes = {
    'C': 'ド', 'C#': 'ド♯', 'D': 'レ', 'D#': 'レ♯', 'E': 'ミ',
    'F': 'ファ', 'F#': 'ファ♯', 'G': 'ソ', 'G#': 'ソ♯', 'A': 'ラ', 'A#': 'ラ♯', 'B': 'シ',
  };

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _pressKey(String note) {
    setState(() {
      _pressedKeys.add(note);
      _playedNotes.add(_japaneseNotes[note] ?? note);
      if (_playedNotes.length > 32) _playedNotes.removeAt(0);
    });
    _player.playTone(note);

    // Release key animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _pressedKeys.remove(note));
    });

    // Award badge on first 5 notes
    if (_playedNotes.length >= 5 && !_badgeAwarded) {
      _badgeAwarded = true;
      // TODO: Badge awarded notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎹 ピアノ探検家バッジ獲得！')),
      );
    }
  }

  void _clearNotes() => setState(() => _playedNotes.clear());

  Color _keyColor(String note) {
    final base = note.replaceAll('#', '').replaceAll('♯', '');
    return _noteColors[base] ?? TaikuColors.forTheme('music');
  }

  @override
  Widget build(BuildContext context) {
    const pianoColor = Color(0xFF9C27B0);
    const darkBg = Color(0xFF1A1A2E);
    const darkBar = Color(0xFF16213E);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('🎹 フリーピアノ'),
        backgroundColor: darkBar,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'クイズに挑戦',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const StageLearnScreen(
                stageNum: 30,
                emoji: '🎹',
                title: 'フリー演奏',
                theme: 'music',
                color: Color(0xFF9C27B0),
              ),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearNotes,
            tooltip: 'クリア',
          ),
        ],
      ),
      body: Column(
        children: [
          // 説明バナー
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF0F3460),
            child: const Text(
              '✨ 鍵盤をタップして自由に演奏しよう！ドレミの音を耳と心で感じてね',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

          // 音符表示エリア
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              child: _playedNotes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🎵', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 8),
                          Text(
                            '鍵盤を押すと音符が並ぶよ！',
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
                        children: _playedNotes.asMap().entries.map((e) {
                          final note = e.value;
                          final base = note.replaceAll('♯', '');
                          final color = _noteColors[base] ?? pianoColor;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)
                              ],
                            ),
                            child: Text(
                              note,
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

          // ノート名ガイド
          if (_pressedKeys.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _pressedKeys.map((note) {
                    final color = _keyColor(note);
                    final jp = _japaneseNotes[note] ?? note;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$note = $jp',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // ピアノ鍵盤
          SizedBox(
            height: 180,
            child: PianoKeyboard(
              onKeyPress: _pressKey,
              pressedKeys: _pressedKeys,
              noteColors: _noteColors,
            ),
          ),

          // ヒント
          Container(
            padding: const EdgeInsets.all(10),
            color: darkBar,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('白鍵: ドレミファソラシ', style: TextStyle(color: Colors.white54, fontSize: 11)),
                Text('黒鍵: ♯（半音高い音）', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PianoKeyboard extends StatelessWidget {
  final void Function(String) onKeyPress;
  final Set<String> pressedKeys;
  final Map<String, Color> noteColors;

  const PianoKeyboard({
    super.key,
    required this.onKeyPress,
    required this.pressedKeys,
    required this.noteColors,
  });

  @override
  Widget build(BuildContext context) {
    const whiteKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    const blackKeyOffsets = {1: 'C#', 2: 'D#', 4: 'F#', 5: 'G#', 6: 'A#'};

    return Stack(
      children: [
        // 白鍵
        Row(
          children: whiteKeys.asMap().entries.map((e) {
            final note = e.value;
            final isPressed = pressedKeys.contains(note);
            return Expanded(
              child: GestureDetector(
                onTapDown: (_) => onKeyPress(note),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isPressed ? Colors.grey.shade300 : Colors.white,
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      if (isPressed)
                        BoxShadow(color: Colors.grey.shade400, blurRadius: 4)
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          note,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _japaneseNotes[note] ?? '',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // 黒鍵
        Positioned.fill(
          child: IgnorePointer(
            child: Row(
              children: whiteKeys.asMap().entries.map((e) {
                final i = e.key;
                final nextBlackNote = blackKeyOffsets[i];
                return Expanded(
                  child: Stack(
                    children: [
                      if (nextBlackNote != null && i < whiteKeys.length - 1)
                        Positioned(
                          right: -20,
                          top: 0,
                          bottom: 0,
                          width: 50,
                          child: IgnorePointer(
                            ignoring: false,
                            child: GestureDetector(
                              onTapDown: (_) => onKeyPress(nextBlackNote),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: pressedKeys.contains(nextBlackNote)
                                      ? Colors.grey.shade700
                                      : Colors.black87,
                                  border: Border.all(color: Colors.black, width: 1),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    if (pressedKeys.contains(nextBlackNote))
                                      const BoxShadow(color: Colors.black54, blurRadius: 4)
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    nextBlackNote.replaceAll('#', '♯'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  static const _japaneseNotes = {
    'C': 'ド', 'C#': 'ド♯', 'D': 'レ', 'D#': 'レ♯', 'E': 'ミ',
    'F': 'ファ', 'F#': 'ファ♯', 'G': 'ソ', 'G#': 'ソ♯', 'A': 'ラ', 'A#': 'ラ♯', 'B': 'シ',
  };
}
