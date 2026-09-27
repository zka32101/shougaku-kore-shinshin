import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../data/achievement_checklist_data.dart';
import '../../models/achievement_checklist.dart';
import '../../providers/achievement_checklist_provider.dart';
import '../../providers/child_provider.dart';

/// 年齢（学年）に合わせて用意された「できたこと」チェックリスト画面
class AchievementChecklistScreen extends ConsumerWidget {
  const AchievementChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(currentChildProfileProvider);
    final checkedIds = ref.watch(achievementChecklistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('できたことチェックリスト'),
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.bgPrimary,
      body: childAsync.when(
        data: (child) {
          final grade = child?.grade ?? 1;
          final items = checklistItemsForGrade(grade);
          final grouped = <ChecklistCategory, List<AchievementChecklistItem>>{};
          for (final item in items) {
            grouped.putIfAbsent(item.category, () => []).add(item);
          }
          final completedCount =
              items.where((i) => checkedIds.contains(i.id)).length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppStyles.paddingMedium),
                  child: _ProgressHeader(
                    total: items.length,
                    completed: completedCount,
                  ),
                ),
              ),
              for (final category in grouped.keys)
                SliverToBoxAdapter(
                  child: _CategorySection(
                    category: category,
                    items: grouped[category]!,
                    checkedIds: checkedIds,
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppStyles.paddingLarge),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('読み込みに失敗しました: $e')),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int total;
  final int completed;

  const _ProgressHeader({required this.total, required this.completed});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      padding: const EdgeInsets.all(AppStyles.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'できたこと $completed / $total',
            style: AppStyles.headingSmall.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: AppStyles.paddingSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppStyles.radiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.white,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends ConsumerWidget {
  final ChecklistCategory category;
  final List<AchievementChecklistItem> items;
  final Set<String> checkedIds;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.checkedIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.paddingMedium,
        vertical: AppStyles.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppStyles.paddingSmall),
              Text(
                category.label,
                style: AppStyles.headingSmall.copyWith(color: category.color),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.paddingSmall),
          for (final item in items)
            _ChecklistTile(
              item: item,
              checked: checkedIds.contains(item.id),
              onToggle: () =>
                  ref.read(achievementChecklistProvider.notifier).toggle(item.id),
            ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final AchievementChecklistItem item;
  final bool checked;
  final VoidCallback onToggle;

  const _ChecklistTile({
    required this.item,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.paddingSmall),
      decoration: BoxDecoration(
        color: checked ? item.category.color.withOpacity(0.12) : AppColors.white,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        border: Border.all(
          color: checked ? item.category.color : AppColors.border,
        ),
      ),
      child: CheckboxListTile(
        value: checked,
        onChanged: (_) => onToggle(),
        activeColor: item.category.color,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          item.title,
          style: AppStyles.bodyMedium.copyWith(
            decoration: checked ? TextDecoration.lineThrough : null,
            color: checked ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
