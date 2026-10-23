import 'package:flutter/material.dart';

import '../../features/geijutsu/geijutsu_app.dart' show GeijutsuModule;
import '../../features/taiku/taiku_app.dart' show TaikuModule;
import '../badge/badge_showcase_screen.dart';
import '../checklist/achievement_checklist_screen.dart';
import '../checklist/daily_record_screen.dart';
import '../growth/growth_note_screen.dart';
import '../home/home_screen.dart' show HomeButton, HomeItem;
import '../ranking/ranking_screen.dart';

/// 「きろく」：バッジ・ノート・アルバム・ランキングなど、がんばりを見返す画面をまとめた入口。
class RecordsHubScreen extends StatelessWidget {
  const RecordsHubScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final items = <HomeItem>[
      HomeItem('🎖️', 'バッジ', 'あつめた バッジ', const Color(0xFFF9A825),
          () => _push(context, const BadgeShowcaseScreen())),
      HomeItem('📓', 'せいちょうノート', 'かんがえた ことを みかえそう',
          const Color(0xFF2E7D32),
          () => _push(context, const GrowthNoteScreen())),
      HomeItem('📝', 'きょうのきろく', '日々の取り組み', const Color(0xFF546E7A),
          () => _push(context, const DailyRecordScreen())),
      HomeItem('✅', 'できたことチェック', '成長を確認', const Color(0xFF6D4C41),
          () => _push(context, const AchievementChecklistScreen())),
      HomeItem('🏆', 'ランキング', '成績を確認', const Color(0xFF8E24AA),
          () => _push(context, const RankingScreen())),
      HomeItem('🏅', 'たいいくのバッジ', 'たいいくで あつめた', const Color(0xFFE64A19),
          () => _push(context,
              const TaikuModule(initialRoute: '/badges', standalone: true))),
      HomeItem('📷', 'たいいくのアルバム', '体験のきろく', const Color(0xFFFF6D00),
          () => _push(context,
              const TaikuModule(initialRoute: '/album', standalone: true))),
      HomeItem('⭐', 'げいじゅつのバッジ', 'げいじゅつで あつめた', const Color(0xFFD81B60),
          () => _push(context,
              const GeijutsuModule(initialRoute: '/badges', standalone: true))),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('きろく')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            for (final item in items)
              HomeButton(item: item, height: 72, titleSize: 18),
          ],
        ),
      ),
    );
  }
}
