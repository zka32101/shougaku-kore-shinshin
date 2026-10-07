import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../data/sport_encyclopedia.dart';
import '../taiku_app.dart';
import '../widgets/sport_radar_chart.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

// ─── カテゴリフィルタ用 StateProvider ───

final _selectedCategoryProvider = StateProvider<String>((ref) => 'すべて');

// ─── メイン画面 ───

class SportEncyclopediaScreen extends ConsumerWidget {
  const SportEncyclopediaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeLevelProvider);
    final selectedCategory = ref.watch(_selectedCategoryProvider);
    final isLow = grade == GradeLevel.low;

    final filtered = getSportsByCategory(selectedCategory);

    return Scaffold(
      backgroundColor: LiteracyColors.backgroundFor(grade),
      body: CustomScrollView(
        slivers: [
          _AppBar(grade: grade, isLow: isLow),
          SliverToBoxAdapter(
            child: _CategoryFilter(
              selected: selectedCategory,
              isLow: isLow,
              onChanged: (cat) =>
                  ref.read(_selectedCategoryProvider.notifier).state = cat,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _SportCard(
                  sport: filtered[i],
                  grade: grade,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SportDetailScreen(
                        sport: filtered[i],
                        grade: grade,
                      ),
                    ),
                  ),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AppBar ───

class _AppBar extends StatelessWidget {
  final GradeLevel grade;
  final bool isLow;
  const _AppBar({required this.grade, required this.isLow});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 90,
      pinned: true,
      backgroundColor: TaikuColors.sports,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TaikuColors.sports, Color(0xFFE65100)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titlePadding:
            const EdgeInsets.only(left: 56, bottom: 14, right: 16),
        title: Text(
          isLow ? '⚽ スポーツずかん' : '⚽ スポーツ図鑑',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

// ─── カテゴリフィルタ ───

class _CategoryFilter extends StatelessWidget {
  final String selected;
  final bool isLow;
  final ValueChanged<String> onChanged;

  const _CategoryFilter({
    required this.selected,
    required this.isLow,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: sportCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = sportCategories[i];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onChanged(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? TaikuColors.sports : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? TaikuColors.sports
                      : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: TaikuColors.sports.withValues(alpha: 0.3),
                          blurRadius: 6,
                        )
                      ]
                    : [],
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── 競技カード（グリッド） ───

class _SportCard extends StatelessWidget {
  final SportEntry sport;
  final GradeLevel grade;
  final VoidCallback onTap;

  const _SportCard({
    required this.sport,
    required this.grade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = grade == GradeLevel.low;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UkalabEmoji(sport.emoji, size: 40),
            const SizedBox(height: 8),
            Text(
              sport.name,
              style: TextStyle(
                fontSize: isLow ? 13 : 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              popularityStars(sport.popularityScore),
              style: const TextStyle(
                  fontSize: 12, color: Colors.amber),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _categoryColor(sport.category)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                sport.category,
                style: TextStyle(
                  fontSize: 10,
                  color: _categoryColor(sport.category),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case '球技':
        return TaikuColors.sports;
      case '陸上競技':
        return TaikuColors.primary;
      case '水泳':
        return TaikuColors.disaster;
      case '武道・格闘技':
        return TaikuColors.career;
      case '体操':
        return TaikuColors.nutrition;
      default:
        return Colors.grey;
    }
  }
}

// ─── 詳細画面 ───

class SportDetailScreen extends StatelessWidget {
  final SportEntry sport;
  final GradeLevel grade;

  const SportDetailScreen({
    super.key,
    required this.sport,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = grade == GradeLevel.low;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          _DetailAppBar(sport: sport),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 基本情報チップ行
                  _InfoChipRow(sport: sport, isLow: isLow),
                  const SizedBox(height: 16),
                  // イラスト
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/explain/sport_${sport.id.replaceFirst('sp_', '')}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 説明
                  _Section(
                    emoji: '📖',
                    title: isLow ? 'どんなスポーツ？' : 'どんな競技？',
                    isLow: isLow,
                    child: Text(
                      sport.description,
                      style: TextStyle(
                          fontSize: isLow ? 15 : 14, height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 人気度
                  _Section(
                    emoji: '⭐',
                    title: isLow ? 'にんきど' : '人気度',
                    isLow: isLow,
                    child: Row(
                      children: [
                        Text(
                          popularityStars(sport.popularityScore),
                          style: const TextStyle(
                              fontSize: 22, color: Colors.amber),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${sport.popularityScore} / 5',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 特徴レーダーチャート
                  _Section(
                    emoji: '🕸️',
                    title: isLow ? 'とくちょう グラフ' : 'スポーツの特徴チャート',
                    isLow: isLow,
                    child: Column(
                      children: [
                        SportRadarChart(
                          values: sportRadarValues(sport.id, sport.popularityScore),
                        ),
                        Text(
                          isLow
                              ? 'おおきいほど そのちからが つよいよ（5が いちばん）'
                              : '外側ほど特徴が強い（最大5）。人気度・運動量・持久力・パワー・チームワーク・判断力で比べよう',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 身につく力
                  _Section(
                    emoji: '💪',
                    title: isLow ? 'みにつく ちから' : '身につく力',
                    isLow: isLow,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: sport.skills
                          .map((s) => _SkillChip(label: s))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 基本ルール
                  _Section(
                    emoji: '📋',
                    title: isLow ? 'きほんの ルール' : '基本ルール',
                    isLow: isLow,
                    child: Column(
                      children: sport.basicRules
                          .asMap()
                          .entries
                          .map((e) => _RuleRow(
                                index: e.key + 1,
                                rule: e.value,
                                isLow: isLow,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 成り立ち
                  _Section(
                    emoji: '🏛️',
                    title: isLow ? 'なりたち' : '成り立ち・歴史',
                    isLow: isLow,
                    child: Text(
                      sport.origin,
                      style: TextStyle(
                          fontSize: isLow ? 14 : 13, height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 用具
                  if (sport.equipment.isNotEmpty) ...[
                    _Section(
                      emoji: '🎒',
                      title: isLow ? 'ひつようなもの' : '必要な用具',
                      isLow: isLow,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: sport.equipment
                            .map((e) => Chip(
                                  label: Text(e,
                                      style: const TextStyle(fontSize: 12)),
                                  backgroundColor:
                                      Colors.grey.shade100,
                                  side: BorderSide.none,
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 詳細AppBar ───

class _DetailAppBar extends StatelessWidget {
  final SportEntry sport;
  const _DetailAppBar({required this.sport});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: TaikuColors.sports,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TaikuColors.sports, Color(0xFFE65100)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                UkalabEmoji(sport.emoji, size: 56),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
        titlePadding:
            const EdgeInsets.only(left: 56, bottom: 14, right: 16),
        title: Text(
          sport.name,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
    );
  }
}

// ─── 基本情報チップ行 ───

class _InfoChipRow extends StatelessWidget {
  final SportEntry sport;
  final bool isLow;
  const _InfoChipRow({required this.sport, required this.isLow});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _InfoChip(
          icon: Icons.people,
          label: sport.playerCount,
          color: TaikuColors.sports,
        ),
        _InfoChip(
          icon: Icons.category,
          label: sport.category,
          color: TaikuColors.career,
        ),
        _InfoChip(
          icon: Icons.school,
          label: isLow
              ? sport.beginnerFriendly
              : 'むずかしさ：${sport.beginnerFriendly}',
          color: _beginnerColor(sport.beginnerFriendly),
        ),
      ],
    );
  }

  Color _beginnerColor(String level) {
    switch (level) {
      case 'かんたん':
        return const Color(0xFF4CAF50);
      case 'ふつう':
        return const Color(0xFFFF9800);
      case 'むずかしい':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ─── セクション ───

class _Section extends StatelessWidget {
  final String emoji;
  final String title;
  final bool isLow;
  final Widget child;

  const _Section({
    required this.emoji,
    required this.title,
    required this.isLow,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UkalabEmoji(emoji, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: isLow ? 15 : 14,
                  fontWeight: FontWeight.bold,
                  color: TaikuColors.sports,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ─── スキルチップ ───

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: TaikuColors.sports.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: TaikuColors.sports.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: TaikuColors.sports,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── ルール行 ───

class _RuleRow extends StatelessWidget {
  final int index;
  final String rule;
  final bool isLow;

  const _RuleRow({
    required this.index,
    required this.rule,
    required this.isLow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: TaikuColors.sports,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(fontSize: isLow ? 14 : 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
