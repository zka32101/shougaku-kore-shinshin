import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/music_profile.dart';
import '../../theme/app_theme.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';

class MusicDiagnosisScreen extends ConsumerStatefulWidget {
  const MusicDiagnosisScreen({super.key});

  @override
  ConsumerState<MusicDiagnosisScreen> createState() => _MusicDiagnosisScreenState();
}

class _MusicDiagnosisScreenState extends ConsumerState<MusicDiagnosisScreen> {
  int _step = 0;
  final Set<int> _selectedSounds = {};
  final List<int> _quizAnswers = [];

  static const _sounds = [
    {'label': '鳥の鳴き声', 'emoji': '🐦', 'type': 'melody'},
    {'label': '雨の音', 'emoji': '🌧️', 'type': 'rhythm'},
    {'label': '風の音', 'emoji': '💨', 'type': 'dynamic'},
    {'label': '波の音', 'emoji': '🌊', 'type': 'calm'},
    {'label': '電車の音', 'emoji': '🚃', 'type': 'rhythm'},
    {'label': '子どもの笑い声', 'emoji': '😄', 'type': 'melody'},
    {'label': '犬の鳴き声', 'emoji': '🐕', 'type': 'dynamic'},
    {'label': '太鼓の音', 'emoji': '🥁', 'type': 'rhythm'},
  ];

  static const _quizItems = [
    {
      'q': '同じ曲を聞いて、覚えるのは？',
      'opts': ['すぐ覚える(1-2回)', '何回も聞いて', '歌いながら覚える', 'よく分からない'],
      'types': ['melody', 'rhythm', 'body', 'explore'],
    },
    {
      'q': 'リズムに乗る時、何が一番強い？',
      'opts': ['メロディを歌う', 'リズムを叩く', '体を動かす', '何もしない'],
      'types': ['melody', 'rhythm', 'body', 'calm'],
    },
    {
      'q': '楽器で難しいと思うのは？',
      'opts': ['音の場所が分からない', 'リズムが取れない', '力加減が難しい', '楽器経験ゼロ'],
      'types': ['melody', 'rhythm', 'dynamic', 'none'],
    },
    {
      'q': '得意な表現方法は？',
      'opts': ['歌う・高音担当', 'リズム楽器(太鼓)', 'メロディ楽器(ピアノ)', 'ダンス・体を動かす'],
      'types': ['vocal', 'rhythm', 'melody', 'body'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FuriganaText('音感タイプ診断 (${_step + 1}/3)'),
        backgroundColor: kMusicColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: kMusicColor.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(kMusicColor),
            minHeight: 4,
          ),
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _soundSelectStep();
      case 1: return _quizStep();
      case 2: return _resultStep();
      default: return const SizedBox();
    }
  }

  Widget _soundSelectStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FuriganaText('あなたが好きな「音」は？',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const FuriganaText('複数選択OK', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 2.5, crossAxisSpacing: 8, mainAxisSpacing: 8,
              ),
              itemCount: _sounds.length,
              itemBuilder: (ctx, i) {
                final s = _sounds[i];
                final sel = _selectedSounds.contains(i);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) {
                      _selectedSounds.remove(i);
                    } else {
                      _selectedSounds.add(i);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: sel ? kMusicColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? kMusicColor : Colors.grey[300]!),
                      boxShadow: sel ? [BoxShadow(color: kMusicColor.withValues(alpha: 0.3), blurRadius: 6)] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s['emoji']!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        FuriganaText(
                          s['label']!,
                          style: TextStyle(
                            color: sel ? Colors.white : kTextDark,
                            fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: ElevatedButton(
              onPressed: () => setState(() => _step = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: kMusicColor,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const FuriganaText('次へ ▶', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizStep() {
    final qIdx = _quizAnswers.length;
    if (qIdx >= _quizItems.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _step = 2));
      return const Center(child: CircularProgressIndicator(color: kMusicColor));
    }
    final q = _quizItems[qIdx];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Q${qIdx + 1}/${_quizItems.length}',
              style: const TextStyle(color: kMusicColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FuriganaText(q['q'] as String,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4)),
          const SizedBox(height: 24),
          ...(q['opts'] as List).asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () => setState(() => _quizAnswers.add(e.key)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kTextDark,
                minimumSize: const Size(double.infinity, 54),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: FuriganaText(e.value as String, textAlign: TextAlign.center),
            ),
          )),
          if (qIdx > 0)
            TextButton(
              onPressed: () => setState(() => _quizAnswers.removeLast()),
              child: const FuriganaText('前の問いに戻る'),
            ),
        ],
      ),
    );
  }

  Widget _resultStep() {
    // タイプ集計
    final Map<String, int> typeCounts = {};
    for (final a in _quizAnswers) {
      final idx = _quizAnswers.indexOf(a);
      if (idx < _quizItems.length) {
        final types = _quizItems[idx]['types'] as List;
        if (a < types.length) {
          final t = types[a] as String;
          typeCounts[t] = (typeCounts[t] ?? 0) + 1;
        }
      }
    }

    // 音感タイプ判定
    final rhythmCount = typeCounts['rhythm'] ?? 0;
    final melodyCount = typeCounts['melody'] ?? 0;
    final bodyCount = typeCounts['body'] ?? 0;

    final String typeStr;
    final String typeEmoji;
    final List<String> strengths;
    if (rhythmCount >= melodyCount && rhythmCount >= bodyCount) {
      typeStr = 'リズム感応型';
      typeEmoji = '🥁';
      strengths = ['リズムを敏感に感じ取る', 'グルーヴ感が強い', 'パーカッション向き'];
    } else if (bodyCount >= melodyCount) {
      typeStr = '身体記憶型';
      typeEmoji = '💃';
      strengths = ['体で音楽を覚える', 'ダンスとの相性バツグン', 'リズムダンス向き'];
    } else {
      typeStr = 'メロディ感応型';
      typeEmoji = '🎵';
      strengths = ['メロディを敏感に感じ取る', '歌唱・鼻歌が得意', 'ピアノ・フルート向き'];
    }

    final melodyPct = (melodyCount * 30.0 + 40).clamp(40.0, 100.0);
    final rhythmPct = (rhythmCount * 30.0 + 40).clamp(40.0, 100.0);
    final bodyPct = (bodyCount * 30.0 + 40).clamp(40.0, 100.0);
    final dynamicsPct = (_selectedSounds.where((i) => _sounds[i]['type'] == 'dynamic').length * 40.0 + 30).clamp(30.0, 100.0);
    final emotionPct = (_selectedSounds.length * 12.0 + 40).clamp(40.0, 100.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kMusicColor, kMusicColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                UkalabEmoji(typeEmoji, size: 56),
                const SizedBox(height: 12),
                const FuriganaText('あなたの音感タイプは…',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                FuriganaText(typeStr,
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: strengths.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FuriganaText(s, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildMusicBar('メロディ感応度', melodyPct),
          const SizedBox(height: 6),
          _buildMusicBar('リズム感応度', rhythmPct),
          const SizedBox(height: 6),
          _buildMusicBar('身体記憶力', bodyPct),
          const SizedBox(height: 6),
          _buildMusicBar('音量感知度', dynamicsPct),
          const SizedBox(height: 6),
          _buildMusicBar('情動反応度', emotionPct),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final profile = MusicProfile(
                musicType: typeStr,
                melodyAffinity: melodyPct,
                rhythmAffinity: rhythmPct,
                bodyMemory: bodyPct,
                dynamicsAffinity: dynamicsPct,
                emotionResponse: emotionPct,
                strengths: strengths,
                preferredInstruments: typeStr == 'リズム感応型' ? ['太鼓', 'ドラム'] : ['ピアノ', 'フルート'],
                diagnosticDate: DateTime.now(),
              );
              await ref.read(musicProfileProvider.notifier).save(profile);
              await ref.read(badgeProvider.notifier).award(
                'music_diagnosis', '音感タイプ発見', 'music', '🎵', '音感タイプ診断を完了した',
              );
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/music/compose', arguments: 1);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kMusicColor,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const FuriganaText('作曲を始める！ 🎵', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicBar(String label, double value) {
    return Row(
      children: [
        SizedBox(width: 110, child: FuriganaText(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(kMusicColor),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${value.toInt()}%',
            style: const TextStyle(fontSize: 12, color: kMusicColor, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
