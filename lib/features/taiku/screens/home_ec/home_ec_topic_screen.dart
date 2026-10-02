import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/home_ec.dart';
import '../../providers/home_ec_progress_provider.dart';

class HomeEcTopicScreen extends ConsumerWidget {
  final HomeEcTopicData topic;

  const HomeEcTopicScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const homeEcColor = Color(0xFFE91E63);
    final topicId = topic.id.toString();
    final progressAsync = ref.watch(homeEcProgressProvider);
    final completed = {
      for (final activity in topic.activities)
        activity.id: progressAsync.valueOrNull?['$topicId-${activity.id}'] ?? false,
    };
    final completedCount = completed.values.where((v) => v).length;
    final totalCount = topic.activities.length;
    final progressPercent = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${topic.emoji} ${topic.name}'),
        backgroundColor: homeEcColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 学習効果説明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: homeEcColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 ${topic.why}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: homeEcColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: topic.whyPoints.map((point) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('▸ ', style: TextStyle(color: homeEcColor)),
                            Expanded(
                              child: Text(
                                point,
                                style: const TextStyle(fontSize: 12, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 進捗バー
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'アクティビティ進捗',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation(homeEcColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: homeEcColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$completedCount/$totalCount',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: homeEcColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // アクティビティリスト
            Text(
              'チャレンジしよう',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: topic.activities.map((activity) {
                final isCompleted = completed[activity.id] ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => ref.read(homeEcProgressProvider.notifier).toggle(topicId, activity.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCompleted ? homeEcColor.withValues(alpha: 0.1) : Colors.grey.shade50,
                        border: Border.all(
                          color: isCompleted ? homeEcColor : Colors.grey.shade300,
                          width: isCompleted ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCompleted ? homeEcColor : Colors.grey.shade400,
                                width: 2,
                              ),
                              color: isCompleted ? homeEcColor : Colors.transparent,
                            ),
                            child: isCompleted
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${activity.emoji} ${activity.title}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? homeEcColor : Colors.black,
                                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activity.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // 完了メッセージ
            if (completedCount == totalCount)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: homeEcColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: homeEcColor),
                ),
                child: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'すべてのアクティビティが完了！',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: homeEcColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${topic.name}のすべてを学びました！',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
