import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/virtue_constants.dart';
import '../../features/shop/decor/decor_scope.dart';
import '../../providers/child_provider.dart';
import '../../providers/growth_note_provider.dart';
import '../../services/local_reflection_store.dart';

const _primaryColor = Color(0xFF2E7D32);
const _bgColor = Color(0xFFF5F5F5);

/// せいちょうノート：これまでの「考えてみよう」（相手の気持ち・ひとこと）を月ごとに見返せる。
class GrowthNoteScreen extends ConsumerWidget {
  const GrowthNoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(selectedChildProvider);
    return Scaffold(
      backgroundColor: DecorScope.pageBg(context, _bgColor),
      appBar: AppBar(
        title: const Text('📓 せいちょうノート'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: childAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const _Message('データを読み込めませんでした。もう一度ためしてね。'),
        data: (child) => child == null
            ? const _Message('お子さんを選んでください')
            : _NoteBody(childId: child.id),
      ),
    );
  }
}

class _NoteBody extends ConsumerWidget {
  final String childId;
  const _NoteBody({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(growthNoteProvider(childId));
    return note.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const _Message('データを読み込めませんでした。もう一度ためしてね。'),
      data: (data) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryRow(
            storiesRead: data.summary.storiesRead,
            reflections: data.summary.reflections,
            notes: data.summary.notes,
          ),
          const SizedBox(height: 16),
          if (data.months.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: _Message(
                'まだ ノートは からっぽだよ。\nお話を よんだあとの「考えてみよう」を かくと、ここに のこるよ。',
              ),
            )
          else
            for (final m in data.months) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  '${m.year}年${m.month}月',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
              for (final e in m.entries) _EntryCard(entry: e),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int storiesRead;
  final int reflections;
  final int notes;
  const _SummaryRow({
    required this.storiesRead,
    required this.reflections,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, int n) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('$n',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        );
    return Row(
      key: const Key('growth_summary'),
      children: [
        cell('よんだ お話', storiesRead),
        const SizedBox(width: 8),
        cell('考えた こと', reflections),
        const SizedBox(width: 8),
        cell('かいた ひとこと', notes),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  final ReflectionEntry entry;
  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final feeling =
        entry.feeling == null ? null : kReflectionFeelings[entry.feeling!];
    final note = (entry.note ?? '').trim();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _primaryColor.withValues(alpha: 0.7), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.storyTitle.isEmpty ? '（お話）' : entry.storyTitle,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Text('${entry.at.month}/${entry.at.day}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (entry.theme.isNotEmpty)
                _Chip(
                  '${VirtueConstants.getVirtueEmoji(entry.theme)} '
                  '${VirtueConstants.getVirtueLabel(entry.theme)}',
                ),
              if (feeling != null)
                _Chip('あいては ${feeling.$1} ${feeling.$2}'),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(note, style: const TextStyle(fontSize: 14, height: 1.5)),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      );
}

class _Message extends StatelessWidget {
  final String text;
  const _Message(this.text);

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.7)),
        ),
      );
}
