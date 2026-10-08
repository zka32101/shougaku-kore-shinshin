import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_profile_provider.dart';
import 'profile_edit_dialog.dart';

/// ホームに出す「なまえを いれよう」カード。入れたら消える／『あとで』で閉じられる。
class ProfileNameCard extends ConsumerWidget {
  const ProfileNameCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(showNameCardProvider)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        key: const Key('profile_name_card'),
        color: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✏️ なまえを いれよう',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('なまえと がくねんを きめると、よみがなも ぴったりになるよ。',
                  style: TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () =>
                        ref.read(profileCardDismissedProvider.notifier).dismiss(),
                    child: const Text('あとで'),
                  ),
                  FilledButton(
                    onPressed: () => showProfileEditDialog(context),
                    child: const Text('いれる'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
