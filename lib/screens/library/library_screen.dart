import '../../features/shop/decor/decor_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/story.dart';
import '../../providers/story_provider.dart'; // weeklyThemeProvider
import '../../utils/grade_band.dart';
import '../../providers/child_provider.dart';
import '../../providers/progress_provider.dart';
import '../../utils/animation_constants.dart';
import '../../widgets/animations/index.dart';
import '../story/story_learning_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

const _primaryColor = Color(0xFF9B59B6);
const _bgColor = Color(0xFFF5F5F5);
const _cardColor = Color(0xFFFFFFFF);
const _textPrimary = Color(0xFF333333);
const _textSecondary = Color(0xFF999999);

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedTheme;
  GradeBand? _selectedBand;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DecorScope.pageBg(context, _bgColor),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: _primaryColor,
            title: const Text(
              'どうとく ストーリー',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'ぜんぶ'),
                Tab(text: 'クリアしたお話'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _AllStoriesTab(
              selectedTheme: _selectedTheme,
              selectedBand: _selectedBand,
              onThemeChanged: (t) => setState(() => _selectedTheme = t),
              onBandChanged: (b) => setState(() => _selectedBand = b),
            ),
            const _CompletedTab(),
          ],
        ),
      ),
    );
  }
}

/// 全ストーリー一覧(学年目安・テーマで絞り込み)。同梱データなのでオフラインでも出る。
class _AllStoriesTab extends ConsumerWidget {
  final String? selectedTheme;
  final GradeBand? selectedBand;
  final ValueChanged<String?> onThemeChanged;
  final ValueChanged<GradeBand?> onBandChanged;
  const _AllStoriesTab({
    required this.selectedTheme,
    required this.selectedBand,
    required this.onThemeChanged,
    required this.onBandChanged,
  });

  static const _themes = <(String, String?)>[
    ('すべて', null),
    ('思いやり', 'kindness'),
    ('正直さ', 'honesty'),
    ('責任感', 'responsibility'),
    ('勇気', 'courage'),
    ('礼儀', 'respect'),
    ('協調性', 'cooperation'),
  ];

  Widget _chipRow(List<Widget> chips) => Container(
        color: _cardColor,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: chips),
        ),
      );

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          selectedColor: _primaryColor.withAlpha(40),
          checkmarkColor: _primaryColor,
          labelStyle: TextStyle(
            color: selected ? _primaryColor : _textSecondary,
            fontSize: 12,
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(allLocalStoriesProvider);
    return Column(
      children: [
        _chipRow([
          _chip('ぜんぶ', selectedBand == null, () => onBandChanged(null)),
          for (final b in GradeBand.values)
            _chip(b.rangeLabel, selectedBand == b, () => onBandChanged(b)),
        ]),
        _chipRow([
          for (final t in _themes)
            _chip(t.$1, t.$2 == selectedTheme, () => onThemeChanged(t.$2)),
        ]),
        Expanded(
          child: storiesAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: _primaryColor)),
            error: (e, _) => _ErrorView(error: e.toString()),
            data: (all) {
              final stories = filterStories(
                all,
                theme: selectedTheme,
                band: selectedBand,
              );
              return stories.isEmpty
                  ? const _EmptyView(message: 'この条件のお話はまだないよ')
                  : _StoryList(stories: stories);
            },
          ),
        ),
      ],
    );
  }
}

/// 学年帯・テーマでストーリーを絞り込む(学年→テーマ順の並び)。
List<Story> filterStories(
  List<Story> all, {
  String? theme,
  GradeBand? band,
}) {
  final list = [
    for (final s in all)
      if ((theme == null || s.theme == theme) &&
          (band == null || gradeBandOf(s.gradeLevel) == band))
        s,
  ];
  list.sort((a, b) => a.gradeLevel.compareTo(b.gradeLevel));
  return list;
}

class _CompletedTab extends ConsumerWidget {
  const _CompletedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(selectedChildProvider);

    return childAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(error: e.toString()),
      data: (child) {
        if (child == null) {
          return const _EmptyView(message: 'お子さんを選択してください', emoji: '👶');
        }
        return _CompletedStoriesList(childId: child.id);
      },
    );
  }
}

class _CompletedStoriesList extends ConsumerWidget {
  final String childId;
  const _CompletedStoriesList({required this.childId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(completedStoriesProvider(childId));

    return completedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(error: e.toString()),
      data: (stories) {
        if (stories.isEmpty) {
          return const _EmptyView(
            message: 'まだ完了したストーリーはありません\nチャレンジしてみよう！',
            emoji: '🏆',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: stories.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            return AnimatedSlideIn(
              direction: SlideDirection.fromBottom,
              duration: AnimationDurations.medium,
              delay: Duration(milliseconds: 100 + (i * 75)),
              child: _CompletedStoryCard(story: stories[i], childId: childId),
            );
          },
        );
      },
    );
  }
}

class _CompletedStoryCard extends StatelessWidget {
  final Story story;
  final String childId;

  static const _themeColors = <String, Color>{
    'kindness': Color(0xFF9B59B6),
    'honesty': Color(0xFFF1C40F),
    'responsibility': Color(0xFF3498DB),
    'courage': Color(0xFFE74C3C),
    'respect': Color(0xFF27AE60),
    'cooperation': Color(0xFFE67E22),
  };

  const _CompletedStoryCard({required this.story, required this.childId});

  @override
  Widget build(BuildContext context) {
    final themeColor = _themeColors[story.theme] ?? _primaryColor;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withAlpha(30)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StoryLearningScreen(
              storyId: story.id,
              childId: childId,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 完了バッジ
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: themeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.check_circle, color: themeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: _textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Tag(label: gradeBandLabel(story.gradeLevel), color: _textPrimary),
                        const SizedBox(width: 6),
                        _Tag(label: story.theme, color: themeColor),
                        const SizedBox(width: 6),
                        _Tag(
                          label: '${story.durationSeconds ~/ 60}分',
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.replay, color: _textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryList extends ConsumerWidget {
  final List<Story> stories;
  const _StoryList({required this.stories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childAsync = ref.watch(selectedChildProvider);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stories.length,
      itemBuilder: (context, i) => AnimatedSlideIn(
        direction: SlideDirection.fromBottom,
        duration: AnimationDurations.medium,
        delay: Duration(milliseconds: 100 + (i * 75)),
        child: _LibraryStoryCard(
          story: stories[i],
          onTap: () => childAsync.whenData((child) {
            if (child == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('子供プロフィールを作成してください')),
              );
              return;
            }
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => StoryLearningScreen(storyId: stories[i].id, childId: child.id),
            ));
          }),
        ),
      ),
    );
  }
}

class _LibraryStoryCard extends StatefulWidget {
  final Story story;
  final VoidCallback onTap;
  const _LibraryStoryCard({required this.story, required this.onTap});

  static const _themeColors = <String, Color>{
    'kindness': Color(0xFF9B59B6), 'honesty': Color(0xFFF1C40F),
    'responsibility': Color(0xFF3498DB), 'courage': Color(0xFFE74C3C),
    'respect': Color(0xFF2ECC71), 'cooperation': Color(0xFFE67E22),
  };
  static const _themeLabels = <String, String>{
    'kindness': '思いやり', 'honesty': '正直さ', 'responsibility': '責任感',
    'courage': '勇気', 'respect': '礼儀', 'cooperation': '協調性',
    'friendship': '友情', 'family': '家族', 'self_discovery': '自分らしさ', 'society': '社会',
  };
  static const _themeEmojis = <String, String>{
    'kindness': '💜', 'honesty': '💛', 'responsibility': '💙',
    'courage': '❤️', 'respect': '💚', 'cooperation': '🧡',
  };

  @override
  State<_LibraryStoryCard> createState() => _LibraryStoryCardState();
}

class _LibraryStoryCardState extends State<_LibraryStoryCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.short,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.snappyEasing),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = _LibraryStoryCard._themeColors[widget.story.theme] ?? _primaryColor;
    final label = _LibraryStoryCard._themeLabels[widget.story.theme] ?? widget.story.theme;
    final emoji = _LibraryStoryCard._themeEmojis[widget.story.theme] ?? '📖';

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: color, width: 4)),
            boxShadow: [BoxShadow(
              color: Colors.black.withAlpha(_isPressed ? 20 : 12),
              blurRadius: _isPressed ? 4 : 8,
              offset: const Offset(0, 2),
            )],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                child: Center(child: UkalabEmoji(emoji, size: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.story.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPrimary)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _Tag(label: gradeBandLabel(widget.story.gradeLevel), color: _textPrimary),
                        const SizedBox(width: 6),
                        _Tag(label: label, color: color),
                        const SizedBox(width: 6),
                        _Tag(label: '${(widget.story.durationSeconds / 60).round()}分', color: _textSecondary),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
  );
}

class _EmptyView extends StatelessWidget {
  final String message;
  final String emoji;
  const _EmptyView({required this.message, this.emoji = '📖'});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UkalabEmoji(emoji, size: 56),
        const SizedBox(height: 16),
        Text(message,
            style: const TextStyle(fontSize: 15, color: _textSecondary),
            textAlign: TextAlign.center),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('データを読み込めませんでした。通信状態を確認して、もう一度ためしてね。', style: const TextStyle(color: Colors.red)),
    ),
  );
}
