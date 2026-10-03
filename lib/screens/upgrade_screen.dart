import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/premium_provider.dart';

/// プレミアム購読画面（月額¥300 / 年額¥2,400、小学コレシリーズ共通価格）。
class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  bool _busy = false;

  Future<void> _run(Future<bool> Function() action, String successMessage,
      String failureMessage) async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? successMessage : failureMessage)),
    );
    if (ok) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumProvider);
    final notifier = ref.read(premiumProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌟 プレミアム'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('🌱', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    '英語コレ！を\nずっと使おう',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                        .copyWith(color: Colors.white, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    premium.isPremium
                        ? 'プレミアム会員です。ありがとうございます！'
                        : premium.isTrialActive
                            ? '無料期間 のこり${premium.trialDaysLeft}日'
                            : '無料期間は終了しました',
                    style: const TextStyle(fontSize: 14)
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!premium.isPremium) ...[
              _PlanTile(
                title: '年額プラン',
                price: '¥2,400 / 年',
                note: '月あたり¥200 · おとく',
                recommended: true,
                onTap: _busy
                    ? null
                    : () => _run(notifier.purchaseYearly, 'ご購入ありがとうございます！',
                        '購入できませんでした'),
              ),
              const SizedBox(height: 8),
              _PlanTile(
                title: '月額プラン',
                price: '¥300 / 月',
                note: 'いつでも解約できます',
                onTap: _busy
                    ? null
                    : () => _run(notifier.purchaseMonthly, 'ご購入ありがとうございます！',
                        '購入できませんでした'),
              ),
              const SizedBox(height: 16),
            ],
            TextButton(
              onPressed: _busy
                  ? null
                  : () => _run(notifier.restorePurchases, '購入を復元しました',
                      '復元できる購入が見つかりませんでした'),
              child: const Text('購入を復元'),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 16),
            Text(
              '初回起動から14日間は全機能を無料でお使いいただけます。'
              '購読は Google Play の定期購入で、期間終了の24時間前までに解約しない限り自動更新されます。'
              '解約は Google Play の「定期購入」からいつでもできます。',
              style: const TextStyle(fontSize: 12)
                  .copyWith(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String title;
  final String price;
  final String note;
  final bool recommended;
  final VoidCallback? onTap;

  const _PlanTile({
    required this.title,
    required this.price,
    required this.note,
    required this.onTap,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: recommended ? Colors.orange : Colors.green.withAlpha(60),
          width: recommended ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        if (recommended) ...[
                          const SizedBox(width: 8),
                          Text('おすすめ',
                              style: const TextStyle(fontSize: 12).copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                    Text(note,
                        style: const TextStyle(fontSize: 12)
                            .copyWith(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Text(price,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      .copyWith(color: const Color(0xFF4CAF50))),
            ],
          ),
        ),
      ),
    );
  }
}
