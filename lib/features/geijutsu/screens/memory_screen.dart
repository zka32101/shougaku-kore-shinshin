import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/artwork.dart';
import '../models/composition.dart';
import '../models/home_challenge.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

/// ふりかえり画面に並べる1件分の記録。
class MemoryEntry {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;

  /// 月ごとのグループ見出し用(図工・家庭科は月 1-12、音楽はステージ番号)。
  final int groupNo;
  final String? imagePath;
  final List<String> imagePaths;
  final List<String> lines;
  final DateTime createdAt;

  const MemoryEntry({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.groupNo,
    required this.createdAt,
    this.imagePath,
    this.imagePaths = const [],
    this.lines = const [],
  });
}

/// 図工の作品 → 記録(月の昇順→新しい順)
List<MemoryEntry> artMemories(ArtworkCollection c) {
  final list = [
    for (final a in c.items)
      MemoryEntry(
        id: a.id,
        emoji: a.imagePath != null ? '🖼️' : '📷',
        title: a.title.isEmpty ? '作品 Lv${a.level.index + 1}' : a.title,
        subtitle: '${a.month}月「${a.colorName}」 Lv${a.level.index + 1}',
        groupNo: a.month,
        createdAt: a.createdAt,
        imagePath: a.imagePath,
        imagePaths: a.discoveredImagePaths,
        lines: [
          if (a.description.isNotEmpty) a.description,
          if (a.emotionKeywords.isNotEmpty)
            'かんじた気持ち: ${a.emotionKeywords.join('、')}',
          if (a.techniques.isNotEmpty) 'つかった技: ${a.techniques.join('、')}',
        ],
      ),
  ];
  return _sorted(list);
}

/// 家庭科の記録 → 記録
List<MemoryEntry> homeMemories(HomeChallengeCollection c) {
  final list = [
    for (final h in c.items)
      MemoryEntry(
        id: h.id,
        emoji: h.cooking != null ? '🍳' : '👕',
        title: h.cooking?.menuName ?? h.fashion?.occasion ?? '家庭科の記録',
        subtitle: '${h.month}月 Lv${h.level.index + 1}',
        groupNo: h.month,
        createdAt: h.createdAt,
        imagePaths: [
          ...?h.cooking?.photoPaths,
          ...?h.fashion?.photoPaths,
        ],
        lines: [
          if (h.cooking != null && h.cooking!.notes.isNotEmpty)
            'りょうりメモ: ${h.cooking!.notes}',
          if (h.fashion != null && h.fashion!.notes.isNotEmpty)
            'ふくそうメモ: ${h.fashion!.notes}',
          if (h.parentConversation.isNotEmpty)
            'おうちの人と話したこと: ${h.parentConversation}',
          if (h.emotionalInsight.isNotEmpty) 'きづき: ${h.emotionalInsight}',
        ],
      ),
  ];
  return _sorted(list);
}

/// 音楽の作品 → 記録(グループ=ステージ)
List<MemoryEntry> musicMemories(CompositionCollection c) {
  final list = [
    for (final m in c.items)
      MemoryEntry(
        id: m.id,
        emoji: '🎵',
        title: m.title.isEmpty ? 'ステージ${m.stageNumber}の曲' : m.title,
        subtitle: 'Stage ${m.stageNumber} ・ テーマ: ${m.theme}',
        groupNo: m.stageNumber,
        createdAt: m.createdAt,
        lines: [
          'がっき: ${m.instrument}',
          if (m.tempo != null) 'テンポ: ${m.tempo}',
          'メロディ: ${m.melody.length}音',
        ],
      ),
  ];
  return _sorted(list);
}

List<MemoryEntry> _sorted(List<MemoryEntry> l) => l
  ..sort((a, b) {
    final g = a.groupNo.compareTo(b.groupNo);
    return g != 0 ? g : b.createdAt.compareTo(a.createdAt);
  });

/// グループ番号ごとにまとめる(昇順)。
Map<int, List<MemoryEntry>> groupMemories(List<MemoryEntry> list) {
  final out = <int, List<MemoryEntry>>{};
  for (final e in list) {
    out.putIfAbsent(e.groupNo, () => []).add(e);
  }
  return out;
}

/// 図工・音楽・家庭科の作品や記録を、あとから見返せる画面。
class MemoryScreen extends ConsumerWidget {
  /// 0=図工 1=音楽 2=家庭科
  final int initialTab;
  const MemoryScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final art = artMemories(ref.watch(artworkProvider));
    final music = musicMemories(ref.watch(compositionProvider));
    final home = homeMemories(ref.watch(homeChallengeProvider));
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ふりかえり'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: '🎨 図工'),
              Tab(text: '🎵 音楽'),
              Tab(text: '🏠 家庭科'),
            ],
          ),
        ),
        body: TabBarView(children: [
          _MemoryList(
              entries: art,
              color: kArtColor,
              groupLabel: (n) => '$n月',
              emptyText: 'まだ作品がないよ。\n図工で作品をつくると ここに のこるよ！'),
          _MemoryList(
              entries: music,
              color: kMusicColor,
              groupLabel: (n) => 'ステージ $n',
              emptyText: 'まだ曲がないよ。\n音楽で作曲すると ここに のこるよ！'),
          _MemoryList(
              entries: home,
              color: kHomeEcColor,
              groupLabel: (n) => '$n月',
              emptyText: 'まだ記録がないよ。\n家庭科のチャレンジを記録すると ここに のこるよ！'),
        ]),
      ),
    );
  }
}

class _MemoryList extends StatelessWidget {
  final List<MemoryEntry> entries;
  final Color color;
  final String Function(int) groupLabel;
  final String emptyText;
  const _MemoryList({
    required this.entries,
    required this.color,
    required this.groupLabel,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.7)),
        ),
      );
    }
    final groups = groupMemories(entries);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final g in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text('${groupLabel(g.key)}  (${g.value.length})',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ),
          for (final e in g.value) _MemoryTile(entry: e, color: color),
        ],
      ],
    );
  }
}

Widget _thumb(String? path, String emoji, {double size = 56}) {
  if (path != null) {
    final f = File(path);
    if (f.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(f,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _emojiBox(emoji, size)),
      );
    }
  }
  return _emojiBox(emoji, size);
}

Widget _emojiBox(String emoji, double size) => SizedBox(
    width: size,
    height: size,
    child: Center(child: Text(emoji, style: TextStyle(fontSize: size * 0.6))));

class _MemoryTile extends StatelessWidget {
  final MemoryEntry entry;
  final Color color;
  const _MemoryTile({required this.entry, required this.color});

  @override
  Widget build(BuildContext context) {
    final first = entry.imagePath ??
        (entry.imagePaths.isNotEmpty ? entry.imagePaths.first : null);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        key: Key('memory_${entry.id}'),
        leading: _thumb(first, entry.emoji),
        title: Text(entry.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(entry.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showMemoryDetail(context, entry, color),
      ),
    );
  }
}

/// 記録の詳しい中身を下から出して見せる。
void showMemoryDetail(BuildContext context, MemoryEntry e, Color color) {
  final paths = [
    if (e.imagePath != null) e.imagePath!,
    ...e.imagePaths,
  ].where((p) => File(p).existsSync()).toList();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${e.emoji} ${e.title}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(e.subtitle, style: TextStyle(color: color)),
          const SizedBox(height: 12),
          if (paths.isEmpty)
            Container(
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(e.emoji, style: const TextStyle(fontSize: 48)),
            )
          else
            for (final p in paths)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(p), fit: BoxFit.cover),
                ),
              ),
          const SizedBox(height: 8),
          for (final l in e.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(l, style: const TextStyle(height: 1.6)),
            ),
          const SizedBox(height: 4),
          Text(
              '${e.createdAt.year}年${e.createdAt.month}月${e.createdAt.day}日に のこしたよ',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    ),
  );
}
