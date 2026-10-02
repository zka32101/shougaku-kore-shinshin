import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_providers.dart';
import '../../models/composition.dart';
import '../../theme/app_theme.dart';

class CompositionScreen extends ConsumerStatefulWidget {
  final int stage;
  const CompositionScreen({super.key, required this.stage});

  @override
  ConsumerState<CompositionScreen> createState() => _CompositionScreenState();
}

class _CompositionScreenState extends ConsumerState<CompositionScreen>
    with TickerProviderStateMixin {
  static const _notes = ['ド', 'レ', 'ミ', 'ファ', 'ソ'];
  static const _noteKeys = ['C4', 'D4', 'E4', 'F4', 'G4'];
  static const _noteColors = [
    Color(0xFFE74C3C), Color(0xFFE67E22), Color(0xFFF1C40F),
    Color(0xFF27AE60), Color(0xFF2980B9),
  ];

  final List<int> _melody = []; // note indices
  int? _playingNote;
  String _selectedPattern = 'ascending';
  String _selectedInstrument = 'ピアニカ';
  String _selectedTimeSig = '4/4';
  int _tempo = 120;
  bool _hasDrums = false;
  final List<int> _kickPattern = [0, 0, 0, 0];  // 4拍
  final List<int> _snarePattern = [0, 0, 0, 0];
  final _titleCtrl = TextEditingController();
  final _themeCtrl = TextEditingController();

  late AnimationController _noteAnimCtrl;
  int? _animatedNote;

  @override
  void initState() {
    super.initState();
    _noteAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _noteAnimCtrl.dispose();
    _titleCtrl.dispose();
    _themeCtrl.dispose();
    super.dispose();
  }

  void _tapNote(int idx) {
    if (_melody.length >= 12) return;
    setState(() {
      _melody.add(idx);
      _playingNote = idx;
      _animatedNote = idx;
    });
    _noteAnimCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _playingNote = null);
    });
  }

  void _removeLastNote() {
    if (_melody.isEmpty) return;
    setState(() => _melody.removeLast());
  }

  Future<void> _save() async {
    if (_melody.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('まず音符を並べてみよう！')),
      );
      return;
    }

    final notes = _melody.map((i) => NoteEntry(note: _noteKeys[i], duration: 1.0)).toList();
    final comp = Composition(
      id: const Uuid().v4(),
      stage: CompositionStage.values[widget.stage - 1],
      title: _titleCtrl.text.isEmpty ? 'Stage ${widget.stage} の作品' : _titleCtrl.text,
      theme: _themeCtrl.text.isEmpty ? '楽しさ' : _themeCtrl.text,
      instrument: _selectedInstrument,
      pattern: _selectedPattern,
      melody: notes,
      timesignature: widget.stage >= 2 ? _selectedTimeSig : null,
      tempo: widget.stage >= 2 ? _tempo : null,
      chords: widget.stage >= 3 ? ['C', 'G'] : [],
      hasDrums: widget.stage >= 4 ? _hasDrums : false,
      badges: ['music_s${widget.stage}'],
      createdAt: DateTime.now(),
    );

    await ref.read(compositionProvider.notifier).add(comp);

    final badgeDefs = {
      1: ['music_s1', '5音メロディスト', '🎹', '5音で初メロディを作曲した'],
      2: ['music_s2', 'リズムマスター', '🥁', 'リズムパターンを加えた'],
      3: ['music_s3', 'ハーモニスト', '🎸', '伴奏コードを追加した'],
      4: ['music_s4', 'グルーヴマスター', '🔥', 'ドラムトラックを追加した'],
    };
    final bd = badgeDefs[widget.stage];
    if (bd != null) {
      await ref.read(badgeProvider.notifier).award(bd[0], bd[1], 'music', bd[2], bd[3]);
    }

    // 次のステージへ
    final nextStage = widget.stage + 1;
    await ref.read(settingsProvider.notifier).setCurrentMusicStage(nextStage.clamp(1, 8));

    if (mounted) {
      final msg = bd != null ? '曲を保存しました！ バッジ「${bd[1]}」獲得！' : '曲を保存しました！';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: kMusicColor),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stage ${widget.stage}: ${_stageTitle()}'),
        backgroundColor: kMusicColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StageInfoCard(stage: widget.stage),
            const SizedBox(height: 16),
            // メロディ表示
            _MelodyDisplay(melody: _melody, removeLastNote: _removeLastNote),
            const SizedBox(height: 16),
            // 鍵盤
            _PianoKeyboard(
              noteNames: _notes,
              noteColors: _noteColors,
              playingNote: _playingNote,
              onTap: _tapNote,
              animCtrl: _noteAnimCtrl,
              animatedNote: _animatedNote,
            ),
            const SizedBox(height: 16),
            if (widget.stage == 1) ...[
              _PatternSelector(
                selected: _selectedPattern,
                onChanged: (v) => setState(() => _selectedPattern = v),
              ),
              const SizedBox(height: 12),
              _InstrumentSelector(
                selected: _selectedInstrument,
                onChanged: (v) => setState(() => _selectedInstrument = v),
              ),
            ],
            if (widget.stage >= 2) ...[
              _RhythmSection(
                timeSig: _selectedTimeSig,
                tempo: _tempo,
                onTimeSigChanged: (v) => setState(() => _selectedTimeSig = v),
                onTempoChanged: (v) => setState(() => _tempo = v.toInt()),
              ),
            ],
            if (widget.stage >= 3)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kMusicColorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '🎸 コード伴奏: C・G・Fを自動追加します',
                  style: TextStyle(fontSize: 14, color: kMusicColor),
                ),
              ),
            if (widget.stage >= 4) ...[
              const SizedBox(height: 12),
              _DrumSection(
                hasDrums: _hasDrums,
                kickPattern: _kickPattern,
                snarePattern: _snarePattern,
                onToggleDrums: (v) => setState(() => _hasDrums = v),
                onKickChanged: (i, v) => setState(() => _kickPattern[i] = v ? 1 : 0),
                onSnareChanged: (i, v) => setState(() => _snarePattern[i] = v ? 1 : 0),
              ),
            ],
            const SizedBox(height: 16),
            // タイトル・テーマ
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: '作品タイトル',
                hintText: '例：楽しい朝のメロディ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kMusicColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _themeCtrl,
              decoration: InputDecoration(
                labelText: 'このメロディで表したいこと',
                hintText: '例：楽しさ・朝の元気',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: kMusicColor,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('完成・保存する 🎵', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  String _stageTitle() {
    const titles = [
      '5音のメロディ', 'リズムパターン', '伴奏を加える',
      'ドラムを加える', 'マルチトラック', 'ダイナミクス',
      'ボーカル', 'フルミックス',
    ];
    return widget.stage <= titles.length ? titles[widget.stage - 1] : 'ステージ${widget.stage}';
  }
}

class _StageInfoCard extends StatelessWidget {
  final int stage;
  const _StageInfoCard({required this.stage});

  static const _descriptions = [
    'ドレミファソの5音だけでメロディを作ろう！\n「上昇」「下降」「往復」「ジャンプ」のパターンを選んで',
    '作ったメロディに「拍子」と「テンポ」を合わせよう！\n4拍子か3拍子？テンポも自由に調整して',
    'コード伴奏を加えてハーモニーを表現しよう！\nC・G・Fの3コードで音に厚みを出す',
    'キックとスネアでグルーヴを作ろう！\nリズムパターンを自分でデザインする',
    '全てのトラックを組み合わせて1曲に仕上げよう！',
    '強弱（フォルテ・ピアニッシモ）で表現力を加えよう！',
    'あなたの声を曲に乗せよう！',
    '全要素をバランスして最高の1曲に仕上げよう！',
  ];

  @override
  Widget build(BuildContext context) {
    final desc = stage <= _descriptions.length ? _descriptions[stage - 1] : '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kMusicColorLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stage $stage の目標',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kMusicColor),
          ),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }
}

class _MelodyDisplay extends StatelessWidget {
  final List<int> melody;
  final VoidCallback removeLastNote;

  static const _notes = ['ド', 'レ', 'ミ', 'ファ', 'ソ'];
  static const _noteColors = [
    Color(0xFFE74C3C), Color(0xFFE67E22), Color(0xFFF1C40F),
    Color(0xFF27AE60), Color(0xFF2980B9),
  ];

  const _MelodyDisplay({required this.melody, required this.removeLastNote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('あなたのメロディ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              if (melody.isNotEmpty)
                TextButton.icon(
                  onPressed: removeLastNote,
                  icon: const Icon(Icons.backspace, size: 16),
                  label: const Text('削除', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 8),
          melody.isEmpty
              ? const Text(
                  '下の鍵盤をタップして音符を並べよう！',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                )
              : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: melody.asMap().entries.map((e) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _noteColors[e.value],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _notes[e.value],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )).toList(),
                ),
        ],
      ),
    );
  }
}

class _PianoKeyboard extends StatelessWidget {
  final List<String> noteNames;
  final List<Color> noteColors;
  final int? playingNote;
  final int? animatedNote;
  final void Function(int) onTap;
  final AnimationController animCtrl;

  const _PianoKeyboard({
    required this.noteNames, required this.noteColors,
    required this.playingNote, required this.animatedNote,
    required this.onTap, required this.animCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final isPlaying = playingNote == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: isPlaying ? 110 : 100,
              decoration: BoxDecoration(
                color: isPlaying
                    ? noteColors[i]
                    : noteColors[i].withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isPlaying
                    ? [BoxShadow(color: noteColors[i].withOpacity(0.5), blurRadius: 12)]
                    : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isPlaying)
                    const Icon(Icons.music_note, color: Colors.white, size: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      noteNames[i],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PatternSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  const _PatternSelector({required this.selected, required this.onChanged});

  static const _patterns = [
    {'key': 'ascending', 'label': '上昇', 'desc': 'だんだん元気に', 'emoji': '📈'},
    {'key': 'descending', 'label': '下降', 'desc': 'だんだん穏やかに', 'emoji': '📉'},
    {'key': 'loop', 'label': '往復', 'desc': '遊び心・やさしさ', 'emoji': '🔄'},
    {'key': 'jump', 'label': 'ジャンプ', 'desc': '元気・サプライズ', 'emoji': '🚀'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('メロディのパターンを選ぼう',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 2.5, crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: _patterns.length,
          itemBuilder: (ctx, i) {
            final p = _patterns[i];
            final sel = selected == p['key'];
            return GestureDetector(
              onTap: () => onChanged(p['key']!),
              child: Container(
                decoration: BoxDecoration(
                  color: sel ? kMusicColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? kMusicColor : Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(p['emoji']!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['label']!,
                            style: TextStyle(
                              color: sel ? Colors.white : kTextDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            )),
                        Text(p['desc']!,
                            style: TextStyle(
                              color: sel ? Colors.white70 : Colors.grey,
                              fontSize: 11,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InstrumentSelector extends StatelessWidget {
  final String selected;
  final void Function(String) onChanged;

  static const _instruments = [
    {'name': 'ピアニカ', 'emoji': '🎹'},
    {'name': 'フルート', 'emoji': '🎺'},
    {'name': 'ハーモニカ', 'emoji': '🎸'},
    {'name': 'ベルリーラ', 'emoji': '🔔'},
    {'name': 'ボーカル', 'emoji': '🎤'},
  ];

  const _InstrumentSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('楽器を選ぼう',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _instruments.map((inst) {
              final sel = selected == inst['name'];
              return GestureDetector(
                onTap: () => onChanged(inst['name']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? kMusicColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? kMusicColor : Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Text(inst['emoji']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        inst['name']!,
                        style: TextStyle(
                          color: sel ? Colors.white : kTextDark,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RhythmSection extends StatelessWidget {
  final String timeSig;
  final int tempo;
  final void Function(String) onTimeSigChanged;
  final void Function(double) onTempoChanged;

  const _RhythmSection({
    required this.timeSig, required this.tempo,
    required this.onTimeSigChanged, required this.onTempoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('リズム設定', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: ['4/4', '3/4'].map((ts) {
            final sel = timeSig == ts;
            return GestureDetector(
              onTap: () => onTimeSigChanged(ts),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? kMusicColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? kMusicColor : Colors.grey[300]!),
                ),
                child: Text(
                  '$ts 拍子',
                  style: TextStyle(
                    color: sel ? Colors.white : kTextDark,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('テンポ: ', style: TextStyle(fontSize: 14)),
            Text('$tempo BPM',
                style: const TextStyle(color: kMusicColor, fontWeight: FontWeight.bold)),
            Expanded(
              child: Slider(
                value: tempo.toDouble(),
                min: 60, max: 180,
                divisions: 12,
                onChanged: onTempoChanged,
                activeColor: kMusicColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DrumSection extends StatelessWidget {
  final bool hasDrums;
  final List<int> kickPattern;
  final List<int> snarePattern;
  final void Function(bool) onToggleDrums;
  final void Function(int, bool) onKickChanged;
  final void Function(int, bool) onSnareChanged;

  const _DrumSection({
    required this.hasDrums, required this.kickPattern, required this.snarePattern,
    required this.onToggleDrums, required this.onKickChanged, required this.onSnareChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🥁 ドラムトラック',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Switch(
              value: hasDrums,
              onChanged: onToggleDrums,
              activeColor: kMusicColor,
            ),
          ],
        ),
        if (hasDrums) ...[
          const SizedBox(height: 8),
          _DrumRow('キック', '🥁', kickPattern, onKickChanged),
          const SizedBox(height: 8),
          _DrumRow('スネア', '💥', snarePattern, onSnareChanged),
        ],
      ],
    );
  }
}

class _DrumRow extends StatelessWidget {
  final String label;
  final String emoji;
  final List<int> pattern;
  final void Function(int, bool) onChanged;

  const _DrumRow(this.label, this.emoji, this.pattern, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text('$emoji $label', style: const TextStyle(fontSize: 13)),
        ),
        ...List.generate(4, (i) => GestureDetector(
          onTap: () => onChanged(i, pattern[i] == 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: pattern[i] == 1 ? kMusicColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '拍${i + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: pattern[i] == 1 ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }
}
