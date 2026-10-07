import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/disaster_mission.dart';
import '../providers/disaster_provider.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

/// ⑨ 防災の日ドリル画面（9/1・3/11）
class DisasterDrillScreen extends ConsumerWidget {
  const DisasterDrillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionState = ref.watch(disasterMissionProvider);
    final mission = missionState.mission;

    if (mission == null) {
      return const Scaffold(body: Center(child: Text('今日は防災の日ではありません')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text('${mission.emoji} ${mission.title}'),
        backgroundColor: const Color(0xFFFF5722),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MissionHeader(mission: mission, state: missionState),
            const SizedBox(height: 16),
            _ProgressBar(state: missionState),
            const SizedBox(height: 16),
            ...mission.tasks.asMap().entries.map((e) => _TaskCard(
                  task: e.value,
                  index: e.key,
                  isCompleted: missionState.completions[e.value.id] ?? false,
                )),
            const SizedBox(height: 24),
            if (missionState.isAllDone)
              _CertificateCard(mission: mission),
          ],
        ),
      ),
    );
  }
}

class _MissionHeader extends StatelessWidget {
  final DisasterMission mission;
  final DisasterMissionState state;
  const _MissionHeader({required this.mission, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          UkalabEmoji(mission.emoji, size: 48),
          const SizedBox(height: 8),
          Text(
            mission.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF5722),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mission.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF718096), fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            '${state.completedCount} / ${mission.tasks.length} 完了',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final DisasterMissionState state;
  const _ProgressBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.mission == null
        ? 0.0
        : state.completedCount / state.mission!.tasks.length;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5722)),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${(progress * 100).toInt()}% 完了',
          style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
        ),
      ],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final DisasterMissionTask task;
  final int index;
  final bool isCompleted;

  const _TaskCard({
    required this.task,
    required this.index,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
          ],
        ),
        child: InkWell(
          onTap: () =>
              ref.read(disasterMissionProvider.notifier).toggleTask(task.id),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 番号・チェックマーク
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF5F5F5),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          UkalabEmoji(task.emoji, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF2D3748),
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final DisasterMission mission;
  const _CertificateCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5722).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          const Text(
            'ぼうさいファミリー',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '認定証',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${now.year}年${now.month}月${now.day}日\n全ミッション達成！',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              '家族みんなでよく頑張りました！',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
