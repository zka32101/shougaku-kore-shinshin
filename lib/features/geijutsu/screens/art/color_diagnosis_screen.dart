import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/color_profile.dart';
import '../../theme/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('色彩タイプ診断 (${_step + 1}/4)'),
        backgroundColor: kArtColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / 4,
            backgroundColor: kArtColor.withOpacity(0.2),
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
        return _ColorSelectStep();
      case 1:
        return _ReasonStep();
      case 2:
        return _SceneStep();
      case 3:
        return _ResultStep();
      default:
        return const SizedBox();
    }
  }

  Widget _ColorSelectStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'あなたの「色」は何色ですか？',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text('複数選択OK', style: TextStyle(color: Colors.grey)),
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
                    if (selected) _selectedColors.remove(i); else _selectedColors.add(i);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? color : color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: selected ? Border.all(color: color, width: 3) : null,
                      boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
                        Text(
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
              child: const Text('次へ ▶', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ReasonStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '「${_selectedColors.map((i) => _colorNames[i]).take(2).join('・')}」を選んだ理由は？',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text('複数選択OK', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _reasons.length,
              itemBuilder: (context, i) {
                final sel = _selectedReasons.contains(i);
                return CheckboxListTile(
                  value: sel,
                  onChanged: (_) => setState(() {
                    if (sel) _selectedReasons.remove(i); else _selectedReasons.add(i);
                  }),
                  title: Text(_reasons[i]),
                  activeColor: kArtColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  tileColor: sel ? kArtColor.withOpacity(0.08) : null,
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
                  child: const Text('戻る'),
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
                    child: const Text('次へ ▶', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _SceneStep() {
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
          Text(
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
              child: Text(opts[i] as String, textAlign: TextAlign.center),
            ),
          )),
          if (qIdx > 0)
            TextButton(
              onPressed: () => setState(() => _sceneAnswers.removeLast()),
              child: const Text('前の問いに戻る'),
            ),
        ],
      ),
    );
  }

  Widget _ResultStep() {
    // スコア計算
    final warmVotes = _sceneAnswers.where((a) => a == 0).length;
    final coolVotes = _sceneAnswers.where((a) => a == 2 || a == 3).length;

    final warmPct = (warmVotes / 5 * 100 + (_selectedColors.where((i) => i < 3).length * 10)).clamp(0.0, 100.0);
    final coolPct = (coolVotes / 5 * 100 + (_selectedColors.where((i) => i > 6).length * 10)).clamp(0.0, 100.0);
    final neutralPct = (100 - warmPct * 0.5 - coolPct * 0.5).clamp(0.0, 100.0);

    final String typeStr;
    final String typeMsg;
    if (warmPct >= coolPct) {
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
                colors: [kArtColor, kArtColor.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🎨', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                const Text('あなたの色彩タイプは…',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
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
            child: const Text('図工を始める！ 🎨', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildAffinityBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 12))),
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
