import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/geijutsu/providers/app_providers.dart' as gj;
import '../../features/taiku/providers/album_provider.dart';
import '../../features/taiku/providers/composition_provider.dart' as tk;
import '../../features/taiku/providers/disaster_provider.dart';
import '../../features/taiku/providers/home_ec_progress_provider.dart';
import '../../features/taiku/providers/mistake_note_provider.dart';
import '../../features/taiku/providers/parent_diary_provider.dart';
import '../../features/taiku/providers/sibling_quest_provider.dart';
import '../../features/taiku/providers/taiku_providers.dart';
import '../../services/module_data_reset.dart';

/// 設定：たいいく／げいじゅつの学習データだけを消す（アプリ全体のデータは消えない）
class ModuleDataResetSection extends ConsumerWidget {
  const ModuleDataResetSection({super.key});

  Future<void> _confirmAndReset(
    BuildContext context,
    WidgetRef ref, {
    required String name,
    required Future<int> Function(SharedPreferences) reset,
    required void Function() refresh,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text('$nameのデータをリセットしますか？'),
        content: Text(
          '$nameのバッジ・進捗・きろくが消えます。この操作は取り消せません。\n\n'
          'プロフィール・学年・どうとくの記録・ほかの設定は消えません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dctx).pop(true),
            child: const Text('リセット', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final prefs = await SharedPreferences.getInstance();
    await reset(prefs);
    refresh();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$nameのデータをリセットしました')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'データの管理',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          key: const Key('reset_taiku_data'),
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('たいいくのデータをリセット'),
          subtitle: const Text('バッジ・進捗・きろく（プロフィールは残る）'),
          onTap: () => _confirmAndReset(
            context,
            ref,
            name: 'たいいく',
            reset: ModuleDataReset.resetTaiku,
            refresh: () {
              ref.invalidate(taikuProgressProvider);
              ref.invalidate(acquiredBadgesProvider);
              ref.invalidate(parentThemeProvider);
              ref.invalidate(streakProvider);
              ref.invalidate(activityCountProvider);
              ref.invalidate(albumProvider);
              ref.invalidate(mistakeNoteProvider);
              ref.invalidate(parentDiaryProvider);
              ref.invalidate(siblingQuestProvider);
              ref.invalidate(disasterMissionProvider);
              ref.invalidate(tk.compositionProvider);
              ref.invalidate(homeEcProgressProvider);
            },
          ),
        ),
        const Divider(height: 0),
        ListTile(
          key: const Key('reset_geijutsu_data'),
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('げいじゅつのデータをリセット'),
          subtitle: const Text('さくひん・バッジ・進捗（プロフィールは残る）'),
          onTap: () => _confirmAndReset(
            context,
            ref,
            name: 'げいじゅつ',
            reset: ModuleDataReset.resetGeijutsu,
            refresh: () {
              ref.invalidate(gj.settingsProvider);
              ref.invalidate(gj.colorProfileProvider);
              ref.invalidate(gj.musicProfileProvider);
              ref.invalidate(gj.artworkProvider);
              ref.invalidate(gj.compositionProvider);
              ref.invalidate(gj.homeChallengeProvider);
              ref.invalidate(gj.badgeProvider);
            },
          ),
        ),
      ],
    );
  }
}
