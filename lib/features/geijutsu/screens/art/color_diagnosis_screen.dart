import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/color_profile.dart';
import '../../theme/app_theme.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';

class ColorDiagnosisScreen extends ConsumerStatefulWidget {
  const ColorDiagnosisScreen({super.key});

  @override
  ConsumerState<ColorDiagnosisScreen> createState() => _ColorDiagnosisScreenState();
}

class _ColorDiagnosisScreenState extends ConsumerState<ColorDiagnosisScreen> {
  int _step = 0;
  final Set<int> _selectedColors = {};    // Step1: 12色選択
  final Set<int> _selectedReasons = {};   // Step2: 理由
  final List<int> _sceneAnswers = [];     // Step3: Q1-5

  static const _colorNames = [
    '赤', '橙', '黄', '黄緑', '緑', '青緑',
    '青', '紫', 'ピンク', '茶', 'グレー', '黒',
  ];

  static const _reasons = [
    '元気な感じ', '暖かい感じ', '好きなキャラの色',
    '目立つから', '自分の気持ちを表す', 'ただ好き',
  ];

  static const _scenes = [
    {
      'q': '朝起きたときの気分は?',
      'opts': ['赤・橙（元気・やる気）', '黄・黄緑（前向き・楽しい）', '青・紫（落ち着き）', 'グレー・黒（眠い）'],
    },
    {
      'q': '友達と遊ぶときの気分は?',
      'opts': ['赤・ピンク（楽しい・興奮）', '黄・黄緑（明るい）', '緑（落ち着き）', '紫・ピンク（優雅）'],
    },
    {
      'q': '困ったときの気分は?',
      'opts': ['赤（焦り・不安）', '青（冷静・落ち着き）', 'グレー（悩み）', '紫（深い思考）'],
    },
    {
      'q': '夜寝る前の気分は?',
      'opts': ['紫・紺（静寂）', '黒（深い休息）', '青（清々しさ）', 'グレー（リラックス）'],
    },
    {
      'q': '何かを作るときは?',
      'opts': ['赤・橙（情熱的に）', '黄・緑（伸びやかに）', '青・紫（思慮深く）', 'ピンク（優しく）'],
    },
  ];

  // 種別: 0=暖色 1=冷色 2=中間。_colorNames と同じ並び / _scenes の選択肢と同じ並び。
  static const _colorKinds = [
    0, 0, 0, 2, 1, 1, // 赤 橙 黄 黄緑 緑 青緑
    1, 1, 0, 2, 2, 2, // 青 紫 ピンク 茶 グレー 黒
  ];
  static const _sceneKinds = [
    [0, 0, 1, 2], // 朝: 赤橙 / 黄黄緑 / 青紫 / グレー黒
    [0, 0, 1, 1], // 友達: 赤ピンク / 黄黄緑 / 緑 / 紫ピンク
    [0, 1, 2, 1], // 困った: 赤 / 青 / グレー / 紫
    [1, 2, 1, 2], // 夜: 紫紺 / 黒 / 青 / グレー
    [0, 0, 1, 0], // 作る: 赤橙 / 黄緑 / 青紫 / ピンク
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FuriganaText('色彩タイプ診断 (${_step + 1}/4)'),
        backgroundColor: kArtColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / 4,
            backgroundColor: kArtColor.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(kArtColor),
            minHeight: 4,
          ),
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _colorSelectStep();
      case 1:
        return _reasonStep();
      case 2:
        return _sceneStep();
      case 3:
        return _resultStep();
      default:
        return const SizedBox();
    }
  }

  Widget _colorSelectStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FuriganaText(
            'あなたの「色」は何色ですか？',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const FuriganaText('複数選択OK', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12,
              itemBuilder: (context, i) {
                final color = (kMonthColors[i]['color'] as Color);
                final selected = _selectedColors.contains(i);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedColors.remove(i);
                    } else {
                      _selectedColors.add(i);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? color : color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: selected ? Border.all(color: color, width: 3) : null,
                      boxShadow: selected ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        FuriganaText(
                          _colorNames[i],
                          style: TextStyle(
                            color: selected ? Colors.white : color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
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
              onPressed: _selectedColors.isEmpty ? null : () => setState(() => _step = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: kArtColor,
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

  Widget _reasonStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '「${_selectedColors.map((i) => _colorNames[i]).take(2).join('・')}」を選んだ理由は？',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const FuriganaText('複数選択OK', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _reasons.length,
              itemBuilder: (context, i) {
                final sel = _selectedReasons.contains(i);
                return CheckboxListTile(
                  value: sel,
                  onChanged: (_) => setState(() {
                    if (sel) {
                      _selectedReasons.remove(i);
                    } else {
                      _selectedReasons.add(i);
                    }
                  }),
                  title: FuriganaText(_reasons[i]),
                  activeColor: kArtColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  tileColor: sel ? kArtColor.withValues(alpha: 0.08) : null,
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _step = 0),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(80, 54)),
                  child: const FuriganaText('戻る'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() { _step = 2; _sceneAnswers.clear(); }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kArtColor,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const FuriganaText('次へ ▶', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sceneStep() {
    final qIdx = _sceneAnswers.length;
    if (qIdx >= _scenes.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _step = 3));
      return const Center(child: CircularProgressIndicator());
    }
    final scene = _scenes[qIdx];
    final opts = scene['opts'] as List;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${qIdx + 1}/${_scenes.length}',
            style: TextStyle(color: kArtColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FuriganaText(
            scene['q'] as String,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 24),
          ...List.generate(opts.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () => setState(() {
                _sceneAnswers.add(i);
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: kTextDark,
                minimumSize: const Size(double.infinity, 54),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: FuriganaText(opts[i] as String, textAlign: TextAlign.center),
            ),
          )),
          if (qIdx > 0)
            TextButton(
              onPressed: () => setState(() => _sceneAnswers.removeLast()),
              child: const FuriganaText('前の問いに戻る'),
            ),
        ],
      ),
    );
  }

  Widget _resultStep() {
    // スコア計算: 場面の答え(各1票)と選んだ色(各0.5票)を、暖色/冷色/中間に振り分けて割合にする
    var warmVotes = 0.0, coolVotes = 0.0, neutralVotes = 0.0;
    void vote(int kind, double w) {
      if (kind == 0) {
        warmVotes += w;
      } else if (kind == 1) {
        coolVotes += w;
      } else {
        neutralVotes += w;
      }
    }

    for (var q = 0; q < _sceneAnswers.length && q < _sceneKinds.length; q++) {
      final a = _sceneAnswers[q];
      if (a >= 0 && a < _sceneKinds[q].length) vote(_sceneKinds[q][a], 1);
    }
    for (final i in _selectedColors) {
      if (i >= 0 && i < _colorKinds.length) vote(_colorKinds[i], 0.5);
    }
    final totalVotes = warmVotes + coolVotes + neutralVotes;
    double pct(double v) => totalVotes == 0 ? 0.0 : v / totalVotes * 100;
    final warmPct = pct(warmVotes);
    final coolPct = pct(coolVotes);
    final neutralPct = pct(neutralVotes);

    final String typeStr;
    final String typeMsg;
    if (neutralPct > warmPct && neutralPct > coolPct) {
      typeStr = '中間色系・バランス派';
      typeMsg = 'あなたは「落ち着いて全体を見渡すバランスタイプ」。グレーや茶、黒などの落ち着いた色に、好きな色を一点だけ足すと、「あなたらしさ」が引き立つ！';
    } else if (warmPct >= coolPct) {
      typeStr = '暖色系・情熱派';
      typeMsg = 'あなたは「情熱的な表現者タイプ」。赤・橙・ピンクを使った表現をすると、「あなたらしさ」が最も引き出される！';
    } else {
      typeStr = '冷色系・思索派';
      typeMsg = 'あなたは「深く考える思索者タイプ」。青・紫・緑を使った表現をすると、「あなたらしさ」が最も引き出される！';
    }

    final primaryColorName = _selectedColors.isEmpty
        ? '赤'
        : _colorNames[_selectedColors.first];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kArtColor, kArtColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🎨', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                const FuriganaText('あなたの色彩タイプは…',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                FuriganaText(
                  typeStr,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildAffinityBar('暖色への親和度', warmPct, kColorRed),
          const SizedBox(height: 8),
          _buildAffinityBar('冷色への親和度', coolPct, kColorBlue),
          const SizedBox(height: 8),
          _buildAffinityBar('ニュートラルへの親和度', neutralPct, kColorGray),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kArtColorLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '💡 $typeMsg',
              style: const TextStyle(fontSize: 14, height: 1.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final profile = ColorProfile(
                warmAffinity: warmPct,
                coolAffinity: coolPct,
                neutralAffinity: neutralPct,
                primaryColor: primaryColorName,
                secondaryColors: _selectedColors.map((i) => _colorNames[i]).toList(),
                expressionStyle: typeStr,
                diagnosticDate: DateTime.now(),
              );
              await ref.read(colorProfileProvider.notifier).save(profile);
              await ref.read(badgeProvider.notifier).award(
                'art_diagnosis', '色彩診断マスター', 'art', '🎨', '色彩タイプ診断を完了した',
              );
              if (mounted) {
                final settings = ref.read(settingsProvider);
                final artMonth = settings['currentArtMonth'] as int? ?? 1;
                Navigator.pushReplacementNamed(context, '/art/month', arguments: artMonth);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kArtColor,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const FuriganaText('図工を始める！ 🎨', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildAffinityBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 130, child: FuriganaText(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${value.toInt()}%',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
