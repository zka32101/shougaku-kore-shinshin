import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart'
    show
        RetentionKpi,
        notificationPlanProvider,
        onboardingProvider,
        retentionTrackerProvider,
        weeklyChallengeProvider;

import 'study_reminder_service.dart';

/// 週次チャレンジの目標（今週に体験するお話の数）と達成コイン。
const int kWeeklyStoryTarget = 3;
const int kWeeklyStoryRewardCoins = 50;

/// 定着率施策（shared_core の retention）の保存データを起動時に読み込む。
/// 失敗しても起動は止めない。
///
/// 道徳アプリは正誤のあるクイズではないので、連続正解ボーナス・間違い復習・
/// 都道府県コレクションは使わない。
Future<void> initRetention(ProviderContainer container) async {
  try {
    final weekly = container.read(weeklyChallengeProvider.notifier);
    weekly.target = kWeeklyStoryTarget;
    weekly.rewardCoins = kWeeklyStoryRewardCoins;
    await Future.wait([
      container.read(onboardingProvider.notifier).load(),
      weekly.load(),
      container.read(notificationPlanProvider.notifier).load(),
      container.read(retentionTrackerProvider.notifier).load(),
    ]);
  } catch (e) {
    debugPrint('[Retention] 初期化スキップ: $e');
  }
}

/// ストーリーを1つ体験し終えたときに呼ぶ。週次チャレンジ（体験したお話の数）・
/// 学習日の記録・学習時間帯の記録・リマインダーの予約し直しをまとめて行う。
///
/// ref の read はすべて await より前に行う（画面が閉じた後でも安全）。
/// 失敗しても学習の流れは止めない。
Future<void> onStoryCompleted(WidgetRef ref, {BuildContext? context}) async {
  try {
    final weekly = ref.read(weeklyChallengeProvider.notifier);
    final tracker = ref.read(retentionTrackerProvider.notifier);
    final plan = ref.read(notificationPlanProvider.notifier);
    final messenger =
        context == null ? null : ScaffoldMessenger.maybeOf(context);

    final weeklyReward = await weekly.recordCorrectAnswer();
    await tracker.markActiveToday();
    await plan.recordActivity();

    final streak = RetentionKpi.currentStreak(
      ref.read(retentionTrackerProvider).activeDateKeys,
      DateTime.now(),
    );
    // このアプリには復習キューが無いので、復習件数は 0
    await StudyReminderService.instance.reschedule(
      plan: plan,
      streak: streak,
      dueReviewTomorrow: 0,
    );

    if (messenger != null && weeklyReward > 0) {
      messenger.showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('🎉 今週のチャレンジ達成！ +$weeklyReward コイン'),
      ));
    }
  } catch (e) {
    debugPrint('[Retention] ストーリー完了の記録をスキップ: $e');
  }
}
