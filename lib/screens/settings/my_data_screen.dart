import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/child_provider.dart';
import '../../providers/local_data_provider.dart';
import '../../utils/local_data_summary.dart';

String _fmt(DateTime d) => '${d.year}年${d.month}月${d.day}日';

/// 設定：このアプリが端末の中に覚えていること（件数と期間）を見て、消せる画面。
///
/// 開く前に大人確認を済ませてある。お子さんが書いたひとこと本文は表示しない。
class MyDataScreen extends ConsumerWidget {
  const MyDataScreen({super.key});

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String childId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('どうとくの きろくを 消しますか？'),
        content: const Text(
          '読んだお話の記録と、「考えてみよう」の記録が、この端末から消えます。'
          'この操作は取り消せません。\n\n'
          'バッジなど、記録をもとにした表示も変わることがあります。'
          'プロフィール・学年・たいいく／げいじゅつの記録は消えません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dctx).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dctx).pop(true),
            child: const Text('消す', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await deleteLocalDoutokuData(ref, childId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('どうとくの きろくを 消しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider).valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('このアプリが覚えていること')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'どうとくの学習の記録は、この端末の中にだけ保存されています。'
              'サーバーには送られません。',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 16),
            if (child == null)
              const Text('お子様のプロフィールを作ると、ここに記録の件数が表示されます。')
            else
              _Body(childId: child.id, onDelete: _confirmDelete),
            const SizedBox(height: 24),
            const Text(
              'アカウントとサーバー上のデータの削除は、アプリについて欄のサポートメールからご連絡ください。',
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final String childId;
  final Future<void> Function(BuildContext, WidgetRef, String) onDelete;
  const _Body({required this.childId, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(localDataSummaryProvider(childId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Text('記録を読み込めませんでした。'),
      data: (LocalDataSummary s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            key: const Key('my_data_summary'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('読んだお話：${s.storyCount}話'),
                  const SizedBox(height: 6),
                  Text('考えてみよう の記録：${s.reflectionCount}件'),
                  const SizedBox(height: 6),
                  Text(s.firstAt == null
                      ? '記録のある期間：まだありません'
                      : '記録のある期間：${_fmt(s.firstAt!)} 〜 ${_fmt(s.lastAt!)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            key: const Key('delete_doutoku_data'),
            onPressed:
                s.isEmpty ? null : () => onDelete(context, ref, childId),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('どうとくの きろくを 消す'),
          ),
        ],
      ),
    );
  }
}
