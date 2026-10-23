import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_provider.dart';

/// 学習画面のロック。
///
/// 初回起動から14日間（無料期間）と、プレミアム購読中は常に [child] を表示する。
/// 無料期間が終わった後は、[requirePremium] が true の画面だけ購入画面へ誘導する。
/// 無料で使える内容（[requirePremium] が false）は、期間後もそのまま表示する。
class AccessGuard extends ConsumerWidget {
  final Widget child;
  final bool requirePremium;

  const AccessGuard({super.key, required this.child, this.requirePremium = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumProvider);
    if (!requirePremium || premium.hasAccess) return child;

    return Scaffold(
      appBar: AppBar(title: const Text('プレミアム')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                '無料期間は終了しました',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'つづきを学ぶには、プレミアムへの登録が必要です。',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/subscription'),
                child: const Text('プレミアムを見る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
