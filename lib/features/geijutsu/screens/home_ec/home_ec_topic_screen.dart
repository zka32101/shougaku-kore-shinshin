import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';

// トピックデータ定義
class _TopicData {
  final String id;
  final String emoji;
  final String name;
  final Color color;
  final String why;
  final List<String> whyPoints;
  final List<_Activity> activities;

  const _TopicData({
    required this.id,
    required this.emoji,
    required this.name,
    required this.color,
    required this.why,
    required this.whyPoints,
    required this.activities,
  });
}

class _Activity {
  final String id;
  final String title;
  final String description;
  final String emoji;
  const _Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

class HomeEcTopicScreen extends ConsumerStatefulWidget {
  final String topicId;
  const HomeEcTopicScreen({super.key, required this.topicId});

  @override
  ConsumerState<HomeEcTopicScreen> createState() => _HomeEcTopicScreenState();
}

class _HomeEcTopicScreenState extends ConsumerState<HomeEcTopicScreen> {
  final Map<String, bool> _checked = {};
  final List<String> _photoPaths = [];
  final _notesCtrl = TextEditingController();
  bool _saved = false;

  static final _topics = {
    'tidying': _TopicData(
      id: 'tidying',
      emoji: '🗂️',
      name: '整理整頓',
      color: const Color(0xFF2196F3),
      why: '整理整頓は「考える力」を育てます',
      whyPoints: [
        '物の場所を決めることで、「どこに何があるか」を論理的に考える力が育ちます',
        'きれいな空間では集中力が高まり、勉強や遊びの効率がアップします',
        '不要な物を手放す判断力は、大人になっても必要な「決断力」の練習です',
        '自分の部屋を管理することで、自立心と責任感が芽生えます',
      ],
      activities: [
        _Activity(id: 'sort', title: '持ち物を「必要・不要」に分ける', description: '1年使っていない物はどうする？考えてみよう', emoji: '📦'),
        _Activity(id: 'place', title: '物の定位置を決める', description: '「ここに戻す」を決めると片付けが楽になる', emoji: '📍'),
        _Activity(id: 'label', title: '引き出し・棚にラベルを貼る', description: 'どこに何があるか一目でわかるようにしよう', emoji: '🏷️'),
        _Activity(id: 'desk', title: '学習机を整理する', description: '毎日使う場所だから特にきれいに！', emoji: '📚'),
        _Activity(id: 'report', title: '家族に「整理整頓した場所」を報告する', description: 'どこをどう片付けたか伝えてみよう', emoji: '💬'),
      ],
    ),
    'cleaning': _TopicData(
      id: 'cleaning',
      emoji: '🧹',
      name: '清掃',
      color: const Color(0xFF4CAF50),
      why: '清掃は「健康」と「感謝の心」を育てます',
      whyPoints: [
        '清潔な環境はウイルスや細菌を減らし、家族全員の健康を守ります',
        '汚れに気づいて掃除する習慣は、問題発見能力（注意力）を鍛えます',
        '家を掃除することで「住む場所を大切にする心」と家族への感謝が生まれます',
        '掃除道具の正しい使い方を学ぶことで、安全に作業する力が育ちます',
      ],
      activities: [
        _Activity(id: 'sweep', title: '床の掃き掃除をする', description: 'ほうきやモップで床をきれいにしよう', emoji: '🧹'),
        _Activity(id: 'wipe', title: 'テーブルや窓を拭き掃除する', description: '雑巾を絞る力加減も練習！', emoji: '🧽'),
        _Activity(id: 'vacuum', title: '掃除機をかける', description: '隅までしっかりかけるとピカピカ！', emoji: '🌀'),
        _Activity(id: 'bathroom', title: '洗面台・シンクを磨く', description: '水垢はどうすれば落ちる？調べてみよう', emoji: '🚿'),
        _Activity(id: 'schedule', title: '1週間の清掃スケジュールを作る', description: 'どの曜日に何を掃除するか計画しよう', emoji: '📅'),
      ],
    ),
    'shopping': _TopicData(
      id: 'shopping',
      emoji: '🛒',
      name: '買い物とお金',
      color: const Color(0xFFFF9800),
      why: 'お金の知識は「賢い判断力」を育てます',
      whyPoints: [
        'お金の価値を知ることで、物を大切にする気持ちと感謝の心が育ちます',
        '予算を立てて買い物する習慣は、目標に向けて計画する力の基礎になります',
        '比較して買う力（消費者リテラシー）は、将来の生活を豊かにします',
        'おつりの計算などの実践的な算数は、生きた学びになります',
      ],
      activities: [
        _Activity(id: 'list', title: '買い物リストを作って買いに行く', description: '何が必要かリストアップしてから買おう', emoji: '📋'),
        _Activity(id: 'budget', title: '500円でおやつを買う', description: '予算内でどれが一番お得？計算してみよう', emoji: '💴'),
        _Activity(id: 'compare', title: '同じ商品で値段を比べる', description: 'スーパーとコンビニ、どちらが安い？', emoji: '🔍'),
        _Activity(id: 'change', title: 'おつりを暗算で確かめる', description: '1000円で480円買ったらおつりは？', emoji: '🧮'),
        _Activity(id: 'save', title: '1週間のお小遣い帳をつける', description: '何にいくら使ったか記録しよう', emoji: '📒'),
      ],
    ),
    'chores': _TopicData(
      id: 'chores',
      emoji: '🍳',
      name: '家庭の仕事',
      color: const Color(0xFFE91E63),
      why: '家庭の仕事は「協力する心」と「生きる力」を育てます',
      whyPoints: [
        '料理・洗濯・食器洗いは、一人暮らしになっても絶対に必要なスキルです',
        '家族の仕事を分担することで「みんなで支え合う」という協力の精神が育ちます',
        '手伝いを通じて家族への感謝が深まり、思いやりの心が豊かになります',
        '包丁や火の扱いなど、安全管理の知識も日常生活で非常に大切です',
      ],
      activities: [
        _Activity(id: 'cooking', title: '簡単な料理を1品作る', description: 'サラダ・卵料理など、簡単なものから挑戦！', emoji: '🍳'),
        _Activity(id: 'dishes', title: '食器を洗って片付ける', description: '食後は自分の食器くらい洗えると◎', emoji: '🍽️'),
        _Activity(id: 'laundry', title: '洗濯物をたたんで片付ける', description: 'Tシャツやタオルのたたみ方を覚えよう', emoji: '👕'),
        _Activity(id: 'groceries', title: '食材の買い出しを手伝う', description: '何が必要かリストを見ながら選ぼう', emoji: '🛍️'),
        _Activity(id: 'plan', title: '1日の家族の食事メニューを提案する', description: 'バランスを考えてメニューを考えてみよう', emoji: '📝'),
      ],
    ),
    'eco': _TopicData(
      id: 'eco',
      emoji: '🌱',
      name: '環境の配慮',
      color: const Color(0xFF009688),
      why: '環境への配慮は「地球市民の責任」を育てます',
      whyPoints: [
        '地球温暖化や資源不足は今の子どもたちが大人になる頃に直面する問題です',
        'ゴミの分別・節電・節水などの小さな行動が地球を守る大きな力になります',
        '環境問題を学ぶことで、科学的な思考力と問題解決力が育ちます',
        'エコな行動を選ぶ力は、将来の消費行動や職業選択にも影響します',
      ],
      activities: [
        _Activity(id: 'sort_garbage', title: 'ゴミを正しく分別する', description: '燃えるゴミ・プラスチック・缶…分け方を確認！', emoji: '♻️'),
        _Activity(id: 'save_power', title: '使っていない電気を消す習慣をつける', description: '部屋を出るとき電気はどうしてる？', emoji: '💡'),
        _Activity(id: 'save_water', title: '水の使いすぎに気をつける', description: '歯磨きのとき水を出しっぱなしにしない', emoji: '💧'),
        _Activity(id: 'reuse', title: '物を修理したり再利用したりする', description: '捨てる前に「まだ使える？」と考えてみよう', emoji: '🔧'),
        _Activity(id: 'research', title: 'エコな商品を1つ探す', description: 'エコマーク・フェアトレードって何？調べよう', emoji: '🔍'),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = ref.read(sharedPrefsProvider);
    final pid = ref.read(profileProvider).activeId;
    final topic = _topics[widget.topicId];
    if (topic == null) return;
    for (final act in topic.activities) {
      final key = '${pid}_topic_${widget.topicId}_${act.id}';
      _checked[act.id] = prefs.getBool(key) ?? false;
    }
    setState(() {});
  }

  Future<void> _toggleActivity(String actId, bool value) async {
    final prefs = ref.read(sharedPrefsProvider);
    final pid = ref.read(profileProvider).activeId;
    final key = '${pid}_topic_${widget.topicId}_$actId';
    await prefs.setBool(key, value);
    setState(() => _checked[actId] = value);
  }

  Future<void> _pickPhoto() async {
    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery, maxWidth: 800, imageQuality: 80,
    );
    if (xfile != null) setState(() => _photoPaths.add(xfile.path));
  }

  Future<void> _save() async {
    final topic = _topics[widget.topicId]!;
    final completed = _checked.values.where((v) => v).length;
    final badgeId = 'home_${widget.topicId}_complete';
    await ref.read(badgeProvider.notifier).award(
      badgeId,
      '${topic.emoji}${topic.name}マスター',
      'home_ec',
      topic.emoji,
      '${topic.name}のチャレンジを完了した',
    );
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${topic.name}チャレンジ完了！バッジ獲得🎉 ($completed/${topic.activities.length}活動)'),
          backgroundColor: topic.color,
        ),
      );
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topic = _topics[widget.topicId];
    if (topic == null) return const Scaffold(body: Center(child: Text('トピックが見つかりません')));
    final completedCount = _checked.values.where((v) => v).length;
    final total = topic.activities.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${topic.emoji} ${topic.name}'),
        backgroundColor: topic.color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // なぜ学ぶ？
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [topic.color, topic.color.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(topic.emoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.why,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white30),
                const SizedBox(height: 8),
                ...topic.whyPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✦ ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 進捗バー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: topic.color.withValues(alpha: 0.1), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'チャレンジ進捗',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: topic.color),
                    ),
                    Text(
                      '$completedCount / $total 完了',
                      style: TextStyle(fontSize: 14, color: topic.color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completedCount / total : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(topic.color),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // アクティビティリスト
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: topic.color.withValues(alpha: 0.1), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    '📋 チャレンジリスト',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: topic.color,
                    ),
                  ),
                ),
                ...topic.activities.map((act) {
                  final isDone = _checked[act.id] ?? false;
                  return ListTile(
                    leading: Text(act.emoji, style: const TextStyle(fontSize: 28)),
                    title: Text(
                      act.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDone ? Colors.grey : kTextDark,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      act.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDone ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    trailing: Checkbox(
                      value: isDone,
                      activeColor: topic.color,
                      onChanged: (v) => _toggleActivity(act.id, v ?? false),
                    ),
                    onTap: () => _toggleActivity(act.id, !isDone),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 写真セクション
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: topic.color.withValues(alpha: 0.1), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📸 写真で記録',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: topic.color),
                    ),
                    TextButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.add_a_photo, size: 16),
                      label: const Text('追加'),
                      style: TextButton.styleFrom(foregroundColor: topic.color),
                    ),
                  ],
                ),
                if (_photoPaths.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photoPaths.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_photoPaths[i]),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(() => _photoPaths.removeAt(i)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'やってみた様子を写真に撮ろう！',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // メモ
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'やってみた感想・気づき',
              hintText: '例: 部屋がきれいになったら勉強に集中できた！',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: topic.color),
              ),
            ),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: (_saved || completedCount == 0) ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: topic.color,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              disabledBackgroundColor: Colors.grey[200],
            ),
            child: Text(
              _saved
                  ? '✓ バッジ獲得済み！'
                  : completedCount == 0
                      ? 'チャレンジを始めよう！'
                      : '$completedCount個完了！バッジをもらう',
              style: TextStyle(
                fontSize: 16,
                color: (_saved || completedCount == 0) ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
