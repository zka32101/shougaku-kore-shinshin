import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';

class FreePianoScreen extends ConsumerStatefulWidget {
  const FreePianoScreen({super.key});

  @override
  ConsumerState<FreePianoScreen> createState() => _FreePianoScreenState();
}

class _FreePianoScreenState extends ConsumerState<FreePianoScreen> {
  final List<String> _playedNotes = [];
  final Set<String> _pressedKeys = {};
  bool _badgeAwarded = false;

  static const _noteColors = {
    'C': Color(0xFFE74C3C),
    'D': Color(0xFFE67E22),
    'E': Color(0xFFF1C40F),
    'F': Color(0xFF27AE60),
    'G': Color(0xFF2980B9),
    'A': Color(0xFF8E44AD),
    'B': Color(0xFFE91E8C),
  };

  void _pressKey(String note) {
    setState(() {
      _pressedKeys.add(note);
      _playedNotes.add(note.replaceAll('#', '♯'));
      if (_playedNotes.length > 32) _playedNotes.removeAt(0);
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _pressedKeys.remove(note));
    });

    // Award badge on first 5 notes
    if (_playedNotes.length >= 5 && !_badgeAwarded) {
      _badgeAwarded = true;
      ref.read(badgeProvider.notifier).award(
        'music_free_piano', 'ピアノ探検家', 'music', '🎹',
        'フリーピアノで音楽を楽しんだ',
      );
    }
  }

  void _clearNotes() => setState(() => _playedNotes.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('🎹 フリーピアノ'),
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        actions: [
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
            child: const FuriganaText(
              '✨ 鍵盤をタップして自由に演奏しよう！ドレミの音を耳と心で感じてね',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

          // 音符表示
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
                          FuriganaText(
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
                          final base = e.value.replaceAll('♯', '');
                          final color = _noteColors[base] ?? kMusicColor;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
                            ),
                            child: Text(
                              e.value,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _pressedKeys.map((note) {
                  final base = note.replaceAll('#', '');
                  final color = _noteColors[base] ?? kMusicColor;
                  final japanese = {
                    'C': 'ド', 'D': 'レ', 'E': 'ミ', 'F': 'ファ',
                    'G': 'ソ', 'A': 'ラ', 'B': 'シ',
                  }[base] ?? '';
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$note = $japanese',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
            ),

          // ピアノ鍵盤
          SizedBox(
            height: 180,
            child: _PianoKeyboard(
              onKeyPress: _pressKey,
              pressedKeys: _pressedKeys,
              noteColors: _noteColors,
            ),
          ),

          // ヒント
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF16213E),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FuriganaText('白鍵: ドレミファソラシ', style: TextStyle(color: Colors.white54, fontSize: 11)),
                FuriganaText('黒鍵: ♯（半音高い音）', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PianoKeyboard extends StatelessWidget {
  final void Function(String) onKeyPress;
  final Set<String> pressedKeys;
  final Map<String, Color> noteColors;

  const _PianoKeyboard({
    required this.onKeyPress,
    required this.pressedKeys,
    required this.noteColors,
  });

  static const _whiteKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B', 'C2', 'D2', 'E2', 'F2', 'G2', 'A2', 'B2'];
  static const _blackPositions = {1: 'C#', 2: 'D#', 4: 'F#', 5: 'G#', 6: 'A#', 8: 'C#2', 9: 'D#2', 11: 'F#2', 12: 'G#2', 13: 'A#2'};

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final whiteKeyWidth = constraints.maxWidth / _whiteKeys.length;
        final whiteKeyHeight = constraints.maxHeight;
        final blackKeyWidth = whiteKeyWidth * 0.6;
        final blackKeyHeight = whiteKeyHeight * 0.6;

        return Stack(
          children: [
            // White keys
            Row(
              children: _whiteKeys.asMap().entries.map((e) {
                final note = e.value;
                final baseNote = note.replaceAll('2', '');
                final color = noteColors[baseNote] ?? Colors.white;
                final isPressed = pressedKeys.contains(note);
                final japanese = {
                  'C': 'ド', 'D': 'レ', 'E': 'ミ', 'F': 'ファ',
                  'G': 'ソ', 'A': 'ラ', 'B': 'シ',
                }[baseNote] ?? '';

                return GestureDetector(
                  onTapDown: (_) => onKeyPress(note),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    width: whiteKeyWidth,
                    height: whiteKeyHeight,
                    decoration: BoxDecoration(
                      color: isPressed ? color.withValues(alpha: 0.7) : Colors.white,
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                      boxShadow: isPressed
                          ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 12)]
                          : [const BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))],
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          japanese,
                          style: TextStyle(
                            fontSize: 11,
                            color: isPressed ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Black keys
            ..._blackPositions.entries.map((e) {
              final idx = e.key;
              final note = e.value;
              final baseNote = note.replaceAll('#', '').replaceAll('2', '');
              final color = noteColors[baseNote] ?? Colors.grey[900]!;
              final isPressed = pressedKeys.contains(note);
              return Positioned(
                left: (idx * whiteKeyWidth) - (blackKeyWidth / 2),
                top: 0,
                child: GestureDetector(
                  onTapDown: (_) => onKeyPress(note),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    width: blackKeyWidth,
                    height: blackKeyHeight,
                    decoration: BoxDecoration(
                      color: isPressed ? color : Colors.grey[900],
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                      boxShadow: isPressed
                          ? [BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 10)]
                          : [const BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
