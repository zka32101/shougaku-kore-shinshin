import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../models/achievement_checklist.dart';
import '../../models/daily_effort_record.dart';
import '../../providers/daily_effort_record_provider.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

/// 「今日、やさしくできた」など、日々の取り組みを自由に記録できる画面
class DailyRecordScreen extends ConsumerWidget {
  const DailyRecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(dailyEffortRecordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日のできごと記録'),
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.bgPrimary,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: const Text('きろくする', style: TextStyle(color: AppColors.white)),
      ),
      body: records.isEmpty
          ? _EmptyState(onAdd: () => _showAddRecordDialog(context, ref))
          : ListView.builder(
              padding: const EdgeInsets.all(AppStyles.paddingMedium),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return _RecordCard(
                  record: record,
                  onDelete: () => ref
                      .read(dailyEffortRecordProvider.notifier)
                      .deleteRecord(record.id),
                );
              },
            ),
    );
  }

  Future<void> _showAddRecordDialog(BuildContext context, WidgetRef ref) async {
    ChecklistCategory selectedCategory = ChecklistCategory.kindness;
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('今日のできごとを記録'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ChecklistCategory.values.map((category) {
                      final selected = category == selectedCategory;
                      return ChoiceChip(
                        label: Text('${category.emoji} ${category.label}'),
                        selected: selected,
                        selectedColor: category.color.withValues(alpha: 0.3),
                        onSelected: (_) =>
                            setState(() => selectedCategory = category),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppStyles.paddingMedium),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      hintText: '例）ともだちにやさしくできた',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    ref.read(dailyEffortRecordProvider.notifier).addRecord(
                          category: selectedCategory,
                          text: text,
                        );
                    Navigator.of(context).pop();
                  },
                  child: const Text('きろくする'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📝', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppStyles.paddingMedium),
            Text(
              'まだきろくがありません\n今日できたことを記録してみよう！',
              textAlign: TextAlign.center,
              style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppStyles.paddingLarge),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('さいしょのきろく'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final DailyEffortRecord record;
  final VoidCallback onDelete;

  const _RecordCard({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('M月d日 HH:mm').format(record.recordedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingSmall),
      padding: const EdgeInsets.all(AppStyles.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        border: Border(
          left: BorderSide(color: record.category.color, width: 4),
        ),
        boxShadow: AppStyles.shadowSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UkalabEmoji(record.category.emoji, size: 24),
          const SizedBox(width: AppStyles.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.text, style: AppStyles.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  '$dateLabel ・ ${record.category.label}',
                  style: AppStyles.captionSmall
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.textTertiary),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
