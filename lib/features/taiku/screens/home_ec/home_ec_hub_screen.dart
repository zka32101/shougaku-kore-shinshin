import '../../../shop/decor/decor_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/home_ec.dart';
import '../stage_learn_screen.dart';
import 'home_ec_topic_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

class HomeEcHubScreen extends ConsumerWidget {
  const HomeEcHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const homeEcColor = Color(0xFFE91E63);

    return Scaffold(
      backgroundColor: DecorScope.pageBg(context, Colors.white),
      appBar: AppBar(
        title: const Text('🍳 家庭科'),
        backgroundColor: homeEcColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Text('🍳', style: TextStyle(fontSize: 18)),
            tooltip: '料理クイズに挑戦',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const StageLearnScreen(
                stageNum: 32,
                emoji: '🍳',
                title: '料理の基本',
                theme: 'home_ec',
                color: homeEcColor,
              ),
            )),
          ),
          IconButton(
            icon: const Text('🧵', style: TextStyle(fontSize: 18)),
            tooltip: 'ソーイングクイズに挑戦',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const StageLearnScreen(
                stageNum: 33,
                emoji: '🧵',
                title: 'ソーイング',
                theme: 'home_ec',
                color: homeEcColor,
              ),
            )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー説明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: homeEcColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '日常生活のスキルを学ぼう',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '家庭科は「生きる力」を育みます。料理・整理・清掃・環境など、大人になって必ず必要なスキルを楽しみながら学びましょう。',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // トピックグリッド
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: homeEcTopics.length,
              itemBuilder: (context, index) {
                final topic = homeEcTopics.values.toList()[index];
                return _TopicCard(topic: topic);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final HomeEcTopicData topic;

  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => HomeEcTopicScreen(topic: topic),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UkalabEmoji(topic.emoji, size: 40),
            const SizedBox(height: 8),
            Text(
              topic.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${topic.activities.length} アクティビティ',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
