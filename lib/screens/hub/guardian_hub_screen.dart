import 'package:flutter/material.dart';

import '../../features/geijutsu/geijutsu_app.dart' show GeijutsuModule;
import '../../features/taiku/taiku_app.dart' show TaikuModule;
import '../dashboard/dashboard_screen.dart';
import '../home/home_screen.dart' show HomeButton, HomeItem;
import '../report/report_screen.dart';

/// 「ほごしゃ」：保護者向けのレポート・統計・見まもりページをまとめた入口。
///
/// ホームから開くときに、大人であることの確認（計算）を済ませてある。
class GuardianHubScreen extends StatelessWidget {
  const GuardianHubScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final items = <HomeItem>[
      HomeItem('📊', 'ほごしゃ レポート', '成長を分析', const Color(0xFF00897B),
          () => _push(context, const ReportScreen())),
      HomeItem('📈', 'ダッシュボード', '学習統計', const Color(0xFF3949AB),
          () => _push(context, const DashboardScreen())),
      HomeItem('👪', 'たいいくの みまもり', '運動のようす', const Color(0xFF00838F),
          () => _push(context,
              const TaikuModule(initialRoute: '/parent', standalone: true))),
      HomeItem('👪', 'げいじゅつの みまもり', '作品のようす', const Color(0xFFAD1457),
          () => _push(context,
              const GeijutsuModule(initialRoute: '/parent', standalone: true))),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('ほごしゃ')),
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
