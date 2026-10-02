import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';

class HomeDiagnosisScreen extends ConsumerStatefulWidget {
  const HomeDiagnosisScreen({super.key});

  @override
  ConsumerState<HomeDiagnosisScreen> createState() => _HomeDiagnosisScreenState();
}

class _HomeDiagnosisScreenState extends ConsumerState<HomeDiagnosisScreen> {
  int _step = 0;

  static const _rooms = [
    {'label': 'キッチンの色', 'emoji': '🍳', 'hint': 'お皿・食べ物・壁'},
    {'label': 'リビングの色', 'emoji': '🛋️', 'hint': 'ソファ・クッション'},
    {'label': '自分の部屋の色', 'emoji': '🛏️', 'hint': 'ベッド・本・ポスター'},
    {'label': '好きな服の色', 'emoji': '👕', 'hint': '好きな3着'},
    {'label': '好きな食べ物の色', 'emoji': '🍎', 'hint': '3-5個'},
  ];

  final Map<int, String> _selectedColors = {};
  String _favoriteColorReason = '';
  int _favoriteColorIdx = 0;

  static const _reasons = [
    'かわいいから', 'お母さん/お父さんの色だから',
    '温かい感じがするから', '元気が出るから', '特に理由はない',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('家庭の色彩診断 (${_step + 1}/3)'),
        backgroundColor: kHomeEcColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step + 1) / 3,
            backgroundColor: kHomeEcColor.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(kHomeEcColor),
            minHeight: 4,
          ),
          Expanded(child: _buildStep()),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0: return _colorPickStep();
      case 1: return _reasonStep();
      case 2: return _resultStep();
      default: return const SizedBox();
    }
  }

  Widget _colorPickStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('お家の中の「色」を探そう！',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('各場所の「好きな色」をタップして選ぼう', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _rooms.length,
              itemBuilder: (ctx, i) {
                final room = _rooms[i];
                return _ColorRoomCard(
                  emoji: room['emoji']!,
                  label: room['label']!,
                  hint: room['hint']!,
                  selectedColorIdx: _selectedColors[i] != null
                      ? int.tryParse(_selectedColors[i]!)
                      : null,
                  onColorSelected: (colorIdx) => setState(() =>
                      _selectedColors[i] = colorIdx.toString()),
                );
              },
            ),
          ),
          SafeArea(
            child: ElevatedButton(
              onPressed: () => setState(() => _step = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: kHomeEcColor,
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

  Widget _reasonStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('一番「心が落ち着く色」は？',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(12, (i) {
                final c = kMonthColors[i];
                final sel = _favoriteColorIdx == i;
                return GestureDetector(
                  onTap: () => setState(() => _favoriteColorIdx = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    width: sel ? 56 : 44,
                    height: sel ? 56 : 44,
                    decoration: BoxDecoration(
                      color: c['color'] as Color,
                      shape: BoxShape.circle,
                      border: sel ? Border.all(color: Colors.black, width: 3) : null,
                    ),
                    child: sel ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '「${kMonthColors[_favoriteColorIdx]['name']}」が好きな理由は？',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RadioGroup<String>(
              groupValue: _favoriteColorReason,
              onChanged: (v) => setState(() => _favoriteColorReason = v!),
              child: ListView.builder(
                itemCount: _reasons.length,
                itemBuilder: (ctx, i) => RadioListTile<String>(
                  value: _reasons[i],
                  title: Text(_reasons[i]),
                  activeColor: kHomeEcColor,
                ),
              ),
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
                    onPressed: () => setState(() => _step = 2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kHomeEcColor,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('診断結果を見る ▶', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultStep() {
    // 色傾向を計算
    int warmCount = 0, coolCount = 0, neutralCount = 0;
    for (final v in _selectedColors.values) {
      final idx = int.tryParse(v) ?? 0;
      if (idx < 3) {
        warmCount++;
      } else if (idx < 6 || idx >= 9) {
        neutralCount++;
      } else {
        coolCount++;
      }
    }
    final total = warmCount + coolCount + neutralCount;
    final warmPct = total > 0 ? (warmCount / total * 100).round() : 33;
    final coolPct = total > 0 ? (coolCount / total * 100).round() : 33;
    final neutralPct = total > 0 ? (neutralCount / total * 100).round() : 34;

    final dominantType = warmCount >= coolCount && warmCount >= neutralCount
        ? '暖色系'
        : coolCount >= neutralCount
            ? '冷色系'
            : 'ニュートラル系';

    final favoriteColorName = kMonthColors[_favoriteColorIdx]['name'] as String;
    final favoriteColor = kMonthColors[_favoriteColorIdx]['color'] as Color;
    final recommendMonth = _favoriteColorIdx + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kHomeEcColor, kHomeEcColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text('🏠', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                const Text('あなたのお家の色彩バランス',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '$dominantType $warmPct%',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildHomeBar('暖色系', warmPct.toDouble(), kColorRed),
          const SizedBox(height: 6),
          _buildHomeBar('冷色系', coolPct.toDouble(), kColorBlue),
          const SizedBox(height: 6),
          _buildHomeBar('ニュートラル', neutralPct.toDouble(), kColorGray),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: favoriteColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: favoriteColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 今月のテーマ: $favoriteColorName',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: favoriteColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '「$favoriteColorName」を使った料理とファッションで\n色彩ライフを楽しもう！',
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await ref.read(badgeProvider.notifier).award(
                'home_diagnosis', '色彩ライフ診断完了', 'home_ec', '🏠', '家庭の色彩診断を完了した',
              );
              await ref.read(settingsProvider.notifier).setCurrentHomeMonth(recommendMonth);
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/home-ec/month', arguments: recommendMonth);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kHomeEcColor,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('$favoriteColorNameチャレンジを始める！ 🍳', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 12))),
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

class _ColorRoomCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String hint;
  final int? selectedColorIdx;
  final void Function(int) onColorSelected;

  const _ColorRoomCard({
    required this.emoji, required this.label, required this.hint,
    required this.selectedColorIdx, required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(hint, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(12, (i) {
                final c = kMonthColors[i]['color'] as Color;
                final sel = selectedColorIdx == i;
                return GestureDetector(
                  onTap: () => onColorSelected(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 6),
                    width: sel ? 36 : 28,
                    height: sel ? 36 : 28,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: sel ? Border.all(color: Colors.black, width: 2.5) : null,
                    ),
                    child: sel
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
