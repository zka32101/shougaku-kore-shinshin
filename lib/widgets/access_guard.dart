import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';

/// Wraps a gated learning/activity screen and enforces the trial/subscription
/// access check. While the check is loading, shows a spinner. Once resolved,
/// if the user has no access (trial expired and not subscribed), redirects
/// to the subscription (paywall) screen instead of rendering [child].
///
/// This mirrors the QuizAccessGuard pattern used in sibling apps in the
/// 小学コレ series to make sure the trial-expiry gate is actually enforced
/// on screens where the user performs the gated activity, not just shown
/// as a cosmetic countdown.
class AccessGuard extends ConsumerWidget {
  final Widget child;

  const AccessGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessAsync = ref.watch(hasAccessProvider);

    return accessAsync.when(
      data: (hasAccess) {
        if (hasAccess) return child;

        // Trial expired and no active subscription: redirect to paywall.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          Navigator.of(context).pushReplacementNamed('/subscription');
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // If the access check fails (e.g. offline / not signed in yet),
      // fail open rather than blocking the app entirely on a network error.
      error: (_, __) => child,
    );
  }
}
