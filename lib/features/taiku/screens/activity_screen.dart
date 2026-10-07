import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/widgets/photo_source_chooser.dart';
import '../../literacy_core/literacy_core.dart';
import '../data/activity_catalog.dart';
import '../data/activity_memory.dart';
import '../data/taiku_questions.dart';
import '../taiku_app.dart';
import '../providers/album_provider.dart';
import '../providers/taiku_providers.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

/// 実体験カタログ画面 — ステージクリア後または単体で表示
class ActivityScreen extends ConsumerStatefulWidget {
  final int stage;
  const ActivityScreen({super.key, required this.stage});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  ActivityDifficulty _selected = ActivityDifficulty.easy;
  final Set<String> _done = {};

  @override
  Widget build(BuildContext context) {
    final grade = ref.watch(gradeLevelProvider);
    final theme = stageThemes[widget.stage] ?? 'sports';
    final color = TaikuColors.forTheme(theme);

    final allActivities = getActivitiesForStage(widget.stage);
    final activities = allActivities
        .where((a) => a.difficulty == _selected)
        .toList();

    // この難易度に活動がない場合、easy に自動切り替え
    if (activities.isEmpty && _selected != ActivityDifficulty.easy) {
      Future.microtask(() {
        if (mounted) {
          setState(() => _selected = ActivityDifficulty.easy);
        }
      });
    }

    // 各難易度に活動があるかを確認
    final availableDifficulties = {
      ActivityDifficulty.easy:
          allActivities.any((a) => a.difficulty == ActivityDifficulty.easy),
      ActivityDifficulty.normal:
          allActivities.any((a) => a.difficulty == ActivityDifficulty.normal),
      ActivityDifficulty.hard:
          allActivities.any((a) => a.difficulty == ActivityDifficulty.hard),
    };

    return Scaffold(
      backgroundColor: LiteracyColors.backgroundFor(grade),
      appBar: AppBar(
        backgroundColor: color,
        title: Row(
          children: [
            Text(stageEmoji[widget.stage] ?? '🏃',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '実体験チャレンジ',
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (_done.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${_done.length} 完了',
                  style: const TextStyle(color: Colors.white,
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 難易度タブ（活動がある難易度のみ表示）
          _DifficultyTabs(
            selected: _selected,
            color: color,
            onChanged: (d) => setState(() => _selected = d),
            availableDifficulties: availableDifficulties,
          ),

          // 活動リスト
          Expanded(
            child: activities.isEmpty
                ? Center(
                    child: Text(
                      'このステージの活動は\nまだ準備中です',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: activities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final activity = activities[i];
                      final isDone = _done.contains(activity.id);
                      return _ActivityCard(
                        activity: activity,
                        isDone: isDone,
                        color: color,
                        grade: grade,
                        onToggle: () async {
                          setState(() {
                            if (isDone) {
                              _done.remove(activity.id);
                            } else {
                              _done.add(activity.id);
                            }
                          });
                          if (!isDone) {
                            await ref
                                .read(activityCountProvider.notifier)
                                .increment();
                            // バッジ確認
                            final progress = ref
                                .read(taikuProgressProvider)
                                .valueOrNull;
                            final streak = ref.read(streakProvider);
                            final count =
                                ref.read(activityCountProvider);
                            if (progress != null) {
                              await ref
                                  .read(acquiredBadgesProvider.notifier)
                                  .checkAndAwardBadges(
                                    progress: progress,
                                    stage: widget.stage,
                                    accuracy: 0,
                                    streak: streak,
                                    activityCount: count,
                                  );
                            }
                            // ② アルバム：写真撮影ダイアログ
                            if (context.mounted) {
                              await _showPhotoMemoryDialog(
                                  context, ref, activity, theme);
                            }
                          }
                        },
                      );
                    },
                  ),
          ),

          // ホームへ戻るボタン
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed('/home'),
                  child: Text(
                    grade == GradeLevel.low ? 'ホームへ' : 'ホームに戻る',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPhotoMemoryDialog(
    BuildContext context,
    WidgetRef ref,
    TaikuActivity activity,
    String theme,
  ) async {
    // ダイアログは自分の context で閉じる（入れ子 Navigator の画面 context で pop すると
    // 画面側が閉じてしまい、「とる」が反応しなくなる）
    final source = await showPhotoSourceDialog(
      context,
      title: '📷 しゃしんをのこそう！',
      message: '「${activity.title}」を\nアルバムに保存しますか？',
    );
    if (source == null || !context.mounted) return;

    // 撮影中に端末がアプリを終了しても、起動時に写真を拾えるよう保存先の情報を残す
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingKey,
      jsonEncode({
        'activityId': activity.id,
        'activityTitle': activity.title,
        'theme': theme,
        'stage': widget.stage,
      }),
    );
    if (!context.mounted) return;
    final XFile? file = await pickPhotoWithMessage(context, source);
    await prefs.remove(_pendingKey);
    if (file == null) return;

    final memory = ActivityMemory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activityId: activity.id,
      activityTitle: activity.title,
      theme: theme,
      relatedStage: widget.stage,
      completedAt: DateTime.now(),
      imagePath: file.path,
    );

    await ref.read(albumProvider.notifier).addMemory(memory);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('アルバムに保存したよ！📷'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// ─── 難易度タブ ───

class _DifficultyTabs extends StatelessWidget {
  final ActivityDifficulty selected;
  final Color color;
  final ValueChanged<ActivityDifficulty> onChanged;
  final Map<ActivityDifficulty, bool> availableDifficulties;

  const _DifficultyTabs({
    required this.selected,
    required this.color,
    required this.onChanged,
    required this.availableDifficulties,
  });

  @override
  Widget build(BuildContext context) {
    final visibleDifficulties = ActivityDifficulty.values
        .where((d) => availableDifficulties[d] ?? false)
        .toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: visibleDifficulties.map((d) {
          final isSelected = d == selected;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onChanged(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      UkalabEmoji(d.emoji, size: 16),
                      const SizedBox(height: 2),
                      Text(
                        d.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── 活動カード ───

class _ActivityCard extends StatefulWidget {
  final TaikuActivity activity;
  final bool isDone;
  final Color color;
  final GradeLevel grade;
  final VoidCallback onToggle;

  const _ActivityCard({
    required this.activity,
    required this.isDone,
    required this.color,
    required this.grade,
    required this.onToggle,
  });

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLow = widget.grade == GradeLevel.low;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.isDone
            ? widget.color.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDone ? widget.color : Colors.grey.shade200,
          width: widget.isDone ? 2 : 1,
        ),
        boxShadow: widget.isDone
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ヘッダー
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  UkalabEmoji(widget.activity.emoji, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.activity.title,
                          style: TextStyle(
                            fontSize: isLow ? 14 : 13,
                            fontWeight: FontWeight.bold,
                            color: widget.isDone ? widget.color : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.activity.description,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      if (widget.activity.needsParent)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text('👨‍👩‍👧',
                              style: TextStyle(fontSize: 14)),
                        ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 展開内容（ステップ＋ヒント）
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLow ? 'やりかた' : '手順',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.color),
                  ),
                  const SizedBox(height: 8),
                  ...widget.activity.steps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: widget.color,
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (widget.activity.tip != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.activity.tip!,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isDone
                            ? Colors.grey.shade400
                            : widget.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: widget.onToggle,
                      icon: Icon(widget.isDone
                          ? Icons.check_circle
                          : Icons.emoji_events),
                      label: Text(
                        widget.isDone
                            ? (isLow ? 'かんりょう！' : '完了済み')
                            : (isLow ? 'やった！' : 'チャレンジ完了！'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _pendingKey = 'pending_photo_memory';

/// 撮影中にアプリのプロセスが終了した場合、起動時に写真をアルバムへ保存し直す。
/// 保存したら true を返す。
Future<bool> recoverLostPhotoMemory(AlbumNotifier album) async {
  try {
    final lost = await ImagePicker().retrieveLostData();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    await prefs.remove(_pendingKey);
    final file = lost.file ?? (lost.files?.isNotEmpty == true ? lost.files!.first : null);
    if (lost.isEmpty || file == null || raw == null) return false;
    final m = jsonDecode(raw) as Map<String, dynamic>;
    await album.addMemory(ActivityMemory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activityId: m['activityId'] as String,
      activityTitle: m['activityTitle'] as String,
      theme: m['theme'] as String,
      relatedStage: m['stage'] as int,
      completedAt: DateTime.now(),
      imagePath: file.path,
    ));
    return true;
  } catch (_) {
    return false;
  }
}
