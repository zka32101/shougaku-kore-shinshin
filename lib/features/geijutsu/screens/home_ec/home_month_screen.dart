import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_providers.dart';
import '../../models/home_challenge.dart';
import '../../theme/app_theme.dart';

class HomeMonthScreen extends ConsumerStatefulWidget {
  final int month;
  const HomeMonthScreen({super.key, required this.month});

  @override
  ConsumerState<HomeMonthScreen> createState() => _HomeMonthScreenState();
}

class _HomeMonthScreenState extends ConsumerState<HomeMonthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorData = kMonthColors[widget.month - 1];
    final color = colorData['color'] as Color;
    final colorName = colorData['name'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.month}月: $colorName'),
        backgroundColor: color,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          labelPadding: EdgeInsets.zero,
          tabs: const [
            Tab(text: 'Lv.1\n色学習', height: 44),
            Tab(text: 'Lv.2\n料理', height: 44),
            Tab(text: 'Lv.3\nファッション', height: 44),
            Tab(text: 'Lv.4\n親子', height: 44),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ColorLessonTab(month: widget.month, color: color, colorName: colorName),
          _CookingTab(month: widget.month, color: color, colorName: colorName),
          _FashionTab(month: widget.month, color: color, colorName: colorName),
          _ParentSessionTab(month: widget.month, color: color, colorName: colorName),
        ],
      ),
    );
  }
}

// ─── Lv.1: 色彩学習 ───────────────────────────────────────────────
class _ColorLessonTab extends ConsumerWidget {
  final int month;
  final Color color;
  final String colorName;
  const _ColorLessonTab({required this.month, required this.color, required this.colorName});

  static const _colorFoods = [
    ['トマト', 'イチゴ', 'パプリカ', '赤キャベツ'],
    ['みかん', 'かぼちゃ', 'にんじん', 'さつまいも'],
    ['バナナ', 'コーン', '卵', '黄ピーマン'],
    ['キウイ', 'ほうれん草', 'アボカド', '枝豆'],
    ['ほうれん草', 'きゅうり', 'ブロッコリー', 'ピーマン'],
    ['ハーブ', 'ミントアイス', '青いゼリー', 'ターコイズお菓子'],
    ['ブルーベリー', 'なす', '青い花', 'ブルーグミ'],
    ['紫キャベツ', '紫芋', 'ブルーベリー', '紫たまねぎ'],
    ['いちご', 'ピンクのお菓子', 'さくら餅', 'グレープフルーツ'],
    ['栗', 'チョコレート', '醤油', 'きのこ'],
    ['塩', '白身魚', '大根おろし', '白だし'],
    ['ごま', '黒豆', 'いか墨パスタ', '白飯'],
  ];

  static const _colorFashion = [
    '赤いスカーフ・ソックスがコーデのポイントに！',
    'オレンジのバッグが全体を明るくする！',
    '黄色い帽子で元気な印象に！',
    '黄緑のシャツが爽やかさを演出！',
    '緑の小物でナチュラルテイストを！',
    '青緑のアクセサリーが涼しげ！',
    '青のデニムは万能コーデの基本！',
    '紫の靴下でミステリアスに！',
    'ピンクのリボンで優雅に！',
    '茶色のベルトで全体をまとめる！',
    'グレーのセーターで洗練された印象に！',
    '白×黒のモノトーンでスタイリッシュに！',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final foods = _colorFoods[(month - 1).clamp(0, 11)];
    final fashion = _colorFashion[(month - 1).clamp(0, 11)];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '「$colorName」を知ろう',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('代表食材:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: foods.map((f) => Chip(
                  // 地色が月の色なので、白地+月色の文字で読めるようにする
                  label: Text(f, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                )).toList(),
              ),
              const SizedBox(height: 8),
              const Text('ファッションのポイント:', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text(fashion, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _QuizCard(colorName: colorName, color: color, month: month),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final challenge = HomeChallenge(
              id: const Uuid().v4(),
              month: month,
              level: HomeChallengeLevel.lv1,
              colorName: colorName,
              colorHex: kMonthColors[month - 1]['hex'] as String,
              badges: ['home_m${month}_lv1'],
              createdAt: DateTime.now(),
            );
            await ref.read(homeChallengeProvider.notifier).add(challenge);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lv.1「$colorName学習」完了！'), backgroundColor: color),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Lv.1 完了！ ✓', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

class _QuizCard extends StatefulWidget {
  final String colorName;
  final Color color;
  final int month;
  const _QuizCard({required this.colorName, required this.color, required this.month});

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  int? _answer;

  static const _quizzes = [
    {'q': '赤色が一番多い季節は？', 'opts': ['春', '夏', '秋', '冬'], 'ans': 2},
    {'q': 'オレンジ色といえば何の果物？', 'opts': ['リンゴ', 'オレンジ', 'ぶどう', 'いちご'], 'ans': 1},
    {'q': '黄色といえば何の花？', 'opts': ['チューリップ', 'バラ', 'ひまわり', 'さくら'], 'ans': 2},
    {'q': '春に出てくる黄緑色のものは？', 'opts': ['紅葉', '新芽', '雪', '砂'], 'ans': 1},
    {'q': '緑の野菜といえば？', 'opts': ['にんじん', 'トマト', 'ほうれん草', 'とうもろこし'], 'ans': 2},
    {'q': '海の浅い場所の色は？', 'opts': ['黒', '赤', '青緑', '黄'], 'ans': 2},
    {'q': '晴れた空の色は？', 'opts': ['赤', '青', '緑', '紫'], 'ans': 1},
    {'q': '紫芋は何の芋？', 'opts': ['じゃがいも', 'さつまいも', '里芋', '長芋'], 'ans': 1},
    {'q': 'ピンク色といえば何の花？', 'opts': ['向日葵', 'さくら', 'あじさい', 'コスモス'], 'ans': 1},
    {'q': 'チョコレートは何色？', 'opts': ['白', '黄', '茶色', '黒'], 'ans': 2},
    {'q': 'グレーは何と何を混ぜた色？', 'opts': ['赤と青', '白と黒', '黄と緑', '橙と紫'], 'ans': 1},
    {'q': '白と黒を合わせると？', 'opts': ['グレー', '赤', '青', '緑'], 'ans': 0},
  ];

  @override
  Widget build(BuildContext context) {
    final quiz = _quizzes[(widget.month - 1).clamp(0, _quizzes.length - 1)];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('クイズ 🧠',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: widget.color)),
          const SizedBox(height: 8),
          Text(quiz['q'] as String,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...(quiz['opts'] as List<String>).asMap().entries.map((e) => GestureDetector(
            onTap: _answer == null ? () => setState(() => _answer = e.key) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _answer == null
                    ? Colors.white
                    : e.key == quiz['ans']
                        ? Colors.green.withValues(alpha: 0.15)
                        : e.key == _answer
                            ? Colors.red.withValues(alpha: 0.15)
                            : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _answer == null
                      ? Colors.grey[300]!
                      : e.key == quiz['ans']
                          ? Colors.green
                          : e.key == _answer
                              ? Colors.red
                              : Colors.grey[300]!,
                ),
              ),
              child: Text(e.value),
            ),
          )),
          if (_answer != null)
            Text(
              _answer == quiz['ans']
                  ? '正解！🎉'
                  : '惜しい！答えは「${(quiz['opts'] as List<String>)[quiz['ans'] as int]}」だよ',
              style: TextStyle(
                color: _answer == quiz['ans'] ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Lv.2: 料理チャレンジ ───────────────────────────────────────────
class _CookingTab extends ConsumerStatefulWidget {
  final int month;
  final Color color;
  final String colorName;
  const _CookingTab({required this.month, required this.color, required this.colorName});

  @override
  ConsumerState<_CookingTab> createState() => _CookingTabState();
}

class _CookingTabState extends ConsumerState<_CookingTab> {
  final List<String> _photoPaths = [];
  final _menuCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _menuCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  static const _menuSuggestions = [
    ['赤いご飯（トマトライス）', '赤い味噌汁', '赤いサラダ', '赤いスムージー'],
    ['オレンジのシチュー', 'かぼちゃスープ', 'にんじんサラダ', 'オレンジジュース'],
    ['卵焼き', 'コーンスープ', '黄色のカレー', 'バナナスムージー'],
    ['緑野菜炒め', 'アボカドサラダ', '枝豆ごはん', 'グリーンスムージー'],
    ['ほうれん草パスタ', '野菜スープ', 'ブロッコリー炒め', '抹茶ラテ'],
    ['ミント水', 'ハーブサラダ', '青いゼリー', 'ブルーゼリー'],
    ['ブルーベリースムージー', 'なすの炒め物', '青じそパスタ', 'ブルーゼリー'],
    ['紫芋ごはん', '紫キャベツのマリネ', 'ブルーベリータルト', '紫芋スープ'],
    ['いちご大福', 'ピンクのサラダ', 'いちごスムージー', 'ピンクゼリー'],
    ['栗ごはん', 'きのこの炒め物', 'チョコバナナ', 'コーヒーゼリー'],
    ['塩鍋', 'おにぎり', '白身魚の塩焼き', '豆腐スープ'],
    ['ごま塩ごはん', '黒ごまプリン', '白和え', 'モノクロお弁当'],
  ];

  Future<void> _pickPhoto() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery, maxWidth: 800, imageQuality: 80,
    );
    if (xfile != null) setState(() => _photoPaths.add(xfile.path));
  }

  Future<void> _save() async {
    if (_menuCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メニュー名を入力してね')),
      );
      return;
    }
    final cooking = CookingEntry(
      menuName: _menuCtrl.text,
      photoPaths: _photoPaths,
      notes: _notesCtrl.text,
    );
    final challenge = HomeChallenge(
      id: const Uuid().v4(),
      month: widget.month,
      level: HomeChallengeLevel.lv2,
      colorName: widget.colorName,
      colorHex: kMonthColors[widget.month - 1]['hex'] as String,
      cooking: cooking,
      badges: ['home_m${widget.month}_cooking'],
      createdAt: DateTime.now(),
    );
    await ref.read(homeChallengeProvider.notifier).add(challenge);
    await ref.read(badgeProvider.notifier).award(
      'home_m${widget.month}_cooking',
      '${widget.colorName}の料理人', 'home_ec', '🍳', '${widget.colorName}い料理を作って撮影した',
    );
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('料理チャレンジ保存！バッジ「${widget.colorName}の料理人」獲得！'),
          backgroundColor: widget.color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _menuSuggestions[(widget.month - 1).clamp(0, _menuSuggestions.length - 1)];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '「${widget.colorName}い料理」を作ろう！',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.color),
              ),
              const SizedBox(height: 8),
              const Text('メニュー候補（タップで入力）:', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: suggestions.map((s) => GestureDetector(
                  onTap: () => setState(() => _menuCtrl.text = s),
                  child: Chip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    backgroundColor: widget.color.withValues(alpha: 0.2),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _menuCtrl,
          decoration: InputDecoration(
            labelText: '作った料理の名前',
            hintText: '例: 赤いトマトライス',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.color),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PhotoSection(
          photoPaths: _photoPaths,
          onPickPhoto: _pickPhoto,
          onRemove: (i) => setState(() => _photoPaths.removeAt(i)),
          color: widget.color,
          hint: '料理の写真を撮ろう（材料・調理中・完成品）',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '工夫したこと（20-30字）',
            hintText: '例: トマトをたくさん入れてもっと赤くした',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saved ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            _saved ? '✓ 保存済み' : '料理チャレンジ完了！ ✓',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// ─── Lv.3: ファッション ────────────────────────────────────────────
class _FashionTab extends ConsumerStatefulWidget {
  final int month;
  final Color color;
  final String colorName;
  const _FashionTab({required this.month, required this.color, required this.colorName});

  @override
  ConsumerState<_FashionTab> createState() => _FashionTabState();
}

class _FashionTabState extends ConsumerState<_FashionTab> {
  final List<String> _photoPaths = [];
  String _occasion = '普段着';
  final _notesCtrl = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery, maxWidth: 800, imageQuality: 80,
    );
    if (xfile != null) setState(() => _photoPaths.add(xfile.path));
  }

  Future<void> _save() async {
    final fashion = FashionEntry(
      occasion: _occasion,
      photoPaths: _photoPaths,
      notes: _notesCtrl.text,
    );
    final challenge = HomeChallenge(
      id: const Uuid().v4(),
      month: widget.month,
      level: HomeChallengeLevel.lv3,
      colorName: widget.colorName,
      colorHex: kMonthColors[widget.month - 1]['hex'] as String,
      fashion: fashion,
      badges: ['home_m${widget.month}_fashion'],
      createdAt: DateTime.now(),
    );
    await ref.read(homeChallengeProvider.notifier).add(challenge);
    await ref.read(badgeProvider.notifier).award(
      'home_m${widget.month}_fashion',
      '${widget.colorName}のスタイリスト', 'home_ec', '👗', '${widget.colorName}いファッションをコーデした',
    );
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ファッション完了！「${widget.colorName}のスタイリスト」獲得！'),
          backgroundColor: widget.color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '「${widget.colorName}」を使ったファッションを考えよう！\n持っている服の中から${widget.colorName}を使ったコーデを組んで撮影しよう',
            style: TextStyle(color: widget.color, fontSize: 14, height: 1.6),
          ),
        ),
        const SizedBox(height: 16),
        const Text('どんな時に着る？', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: ['普段着', '誕生日パーティー', '運動会', 'おでかけ', '学校'].map((oc) => GestureDetector(
            onTap: () => setState(() => _occasion = oc),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _occasion == oc ? widget.color : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _occasion == oc ? widget.color : Colors.grey[300]!),
              ),
              child: Text(
                oc,
                style: TextStyle(
                  color: _occasion == oc ? Colors.white : kTextDark,
                  fontWeight: _occasion == oc ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
        _PhotoSection(
          photoPaths: _photoPaths,
          onPickPhoto: _pickPhoto,
          onRemove: (i) => setState(() => _photoPaths.removeAt(i)),
          color: widget.color,
          hint: 'コーデを着た写真を撮ろう（全身・詳細）',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'コーデの工夫',
            hintText: '例: 赤いスカートに白シャツを合わせて爽やかにした',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saved ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            _saved ? '✓ 保存済み' : 'ファッション完了！ ✓',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// ─── Lv.4: 親子セッション ─────────────────────────────────────────
class _ParentSessionTab extends ConsumerStatefulWidget {
  final int month;
  final Color color;
  final String colorName;
  const _ParentSessionTab({required this.month, required this.color, required this.colorName});

  @override
  ConsumerState<_ParentSessionTab> createState() => _ParentSessionTabState();
}

class _ParentSessionTabState extends ConsumerState<_ParentSessionTab> {
  final _convCtrl = TextEditingController();
  final _insightCtrl = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _convCtrl.dispose();
    _insightCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final challenge = HomeChallenge(
      id: const Uuid().v4(),
      month: widget.month,
      level: HomeChallengeLevel.lv4,
      colorName: widget.colorName,
      colorHex: kMonthColors[widget.month - 1]['hex'] as String,
      parentConversation: _convCtrl.text,
      emotionalInsight: _insightCtrl.text,
      badges: ['home_m${widget.month}_lv4'],
      createdAt: DateTime.now(),
    );
    await ref.read(homeChallengeProvider.notifier).add(challenge);
    if (widget.month < 12) {
      await ref.read(settingsProvider.notifier).setCurrentHomeMonth(widget.month + 1);
    }
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.month}月「${widget.colorName}」完了！'),
          backgroundColor: widget.color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextColorName = widget.month < 12
        ? kMonthColors[widget.month]['name'] as String
        : null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '「${widget.colorName}」月の振り返り',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.color),
              ),
              const SizedBox(height: 8),
              const Text('親子で今月を振り返って話し合おう！',
                  style: TextStyle(fontSize: 13, height: 1.6)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💬 話すきっかけ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _ConversationPrompt('「${widget.colorName}い料理」、作ってみてどうだった？'),
              _ConversationPrompt('「${widget.colorName}い服」を着てどんな気持ちだった？'),
              _ConversationPrompt('「${widget.colorName}」という色、どんなイメージになった？'),
              if (nextColorName != null)
                _ConversationPrompt('来月は「$nextColorName」！どんなイメージ？'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _convCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: '親子の会話メモ',
            hintText: '話した内容を記録しよう',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _insightCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: '今月の気づき',
            hintText: '例: 赤が「元気」の色だと感じた',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _saved ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.color,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            _saved ? '✓ ${widget.month}月 完了！' : '${widget.month}月を完了する ✓',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        if (_saved && nextColorName != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(
              context, '/home-ec/month', arguments: widget.month + 1,
            ),
            icon: const Icon(Icons.arrow_forward),
            label: Text('次の月: Month ${widget.month + 1}「$nextColorName」へ'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kMonthColors[widget.month]['color'] as Color,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConversationPrompt extends StatelessWidget {
  final String text;
  const _ConversationPrompt(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.grey)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }
}

// ─── 写真ギャラリー共通ウィジェット ──────────────────────────────────
class _PhotoSection extends StatelessWidget {
  final List<String> photoPaths;
  final VoidCallback onPickPhoto;
  final void Function(int) onRemove;
  final Color color;
  final String hint;

  const _PhotoSection({
    required this.photoPaths,
    required this.onPickPhoto,
    required this.onRemove,
    required this.color,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(hint, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            TextButton.icon(
              onPressed: onPickPhoto,
              icon: const Icon(Icons.add_a_photo, size: 16),
              label: const Text('写真を追加'),
              style: TextButton.styleFrom(foregroundColor: color),
            ),
          ],
        ),
        if (photoPaths.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photoPaths.length,
              itemBuilder: (ctx, i) => Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(photoPaths[i])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GestureDetector(
            onTap: onPickPhoto,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo, color: color.withValues(alpha: 0.5)),
                    Text('タップして写真を追加',
                        style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
