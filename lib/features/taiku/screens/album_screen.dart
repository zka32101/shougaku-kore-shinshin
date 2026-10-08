import '../../shop/decor/decor_scope.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/activity_memory.dart';
import '../providers/album_provider.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

/// ② 体験アルバム画面
class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(filteredAlbumProvider);
    final filter = ref.watch(albumThemeFilterProvider);

    return Scaffold(
      backgroundColor: DecorScope.pageBg(context, const Color(0xFFF8F9FA)),
      appBar: AppBar(
        title: const Text('体験アルバム 📷'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        titleTextStyle: const TextStyle(
          color: Color(0xFF2D3748),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '${memories.length}件',
                style: const TextStyle(color: Color(0xFF718096), fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _ThemeFilterBar(currentFilter: filter),
          Expanded(
            child: memories.isEmpty
                ? _EmptyAlbum(filter: filter)
                : _AlbumGrid(memories: memories),
          ),
        ],
      ),
    );
  }
}

class _ThemeFilterBar extends ConsumerWidget {
  final String? currentFilter;
  const _ThemeFilterBar({required this.currentFilter});

  static const _themes = [
    (null, '全部', '📚'),
    ('sports', 'スポーツ', '⚽'),
    ('disaster', '防災', '🛡️'),
    ('nutrition', '栄養', '🥗'),
    ('career', 'キャリア', '💼'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _themes.length,
        itemBuilder: (_, i) {
          final (theme, label, emoji) = _themes[i];
          final isSelected = currentFilter == theme;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => ref
                  .read(albumThemeFilterProvider.notifier)
                  .state = theme,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$emoji $label',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF555555),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AlbumGrid extends StatelessWidget {
  final List<ActivityMemory> memories;
  const _AlbumGrid({required this.memories});

  @override
  Widget build(BuildContext context) {
    // 月ごとにグルーピング
    final byMonth = <String, List<ActivityMemory>>{};
    for (final m in memories) {
      final key = '${m.completedAt.year}年${m.completedAt.month}月';
      (byMonth[key] ??= []).add(m);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: byMonth.length,
      itemBuilder: (_, i) {
        final month = byMonth.keys.elementAt(i);
        final items = byMonth[month]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                month,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: items.length,
              itemBuilder: (_, j) => _MemoryCard(memory: items[j]),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _MemoryCard extends ConsumerWidget {
  final ActivityMemory memory;
  const _MemoryCard({required this.memory});

  Color get _themeColor {
    switch (memory.theme) {
      case 'sports':
        return const Color(0xFF2196F3);
      case 'disaster':
        return const Color(0xFFFF5722);
      case 'nutrition':
        return const Color(0xFF4CAF50);
      case 'career':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF607D8B);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: () => _showDeleteDialog(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 写真 or テーマカラー背景
            Expanded(
              child: memory.imagePath != null &&
                      File(memory.imagePath!).existsSync()
                  ? Image.file(
                      File(memory.imagePath!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      width: double.infinity,
                      color: _themeColor.withValues(alpha: 0.15),
                      child: Center(
                        child: UkalabEmoji(memory.themeEmoji, size: 40),
                      ),
                    ),
            ),
            // 情報部分
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    memory.activityTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _themeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          memory.themeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: _themeColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${memory.completedAt.month}/${memory.completedAt.day}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: const Text('記録を削除'),
        content: Text('「${memory.activityTitle}」の記録を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(albumProvider.notifier).removeMemory(memory.id);
              Navigator.pop(dctx);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlbum extends StatelessWidget {
  final String? filter;
  const _EmptyAlbum({this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📷', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            filter == null ? 'まだ体験を記録していないよ' : 'この分野の記録はまだないよ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '活動を完了したとき\nしゃしんをとって記録しよう！',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF718096)),
          ),
        ],
      ),
    );
  }
}
