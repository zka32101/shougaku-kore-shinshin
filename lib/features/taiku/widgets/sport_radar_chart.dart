import 'dart:math' as math;

import 'package:flutter/material.dart';

/// スポーツごとの特徴（各 1〜5）。レーダーチャート用。
/// 順番: 人気度 / 運動量 / 持久力 / パワー・瞬発力 / チームワーク / 判断力・頭脳
const sportRadarLabels = <String>[
  '人気度',
  '運動量',
  '持久力',
  'パワー',
  'チームワーク',
  '判断力',
];

const _profiles = <String, List<int>>{
  'sp_soccer': [5, 5, 5, 3, 5, 4],
  'sp_basketball': [4, 5, 4, 4, 5, 4],
  'sp_baseball': [5, 3, 2, 4, 4, 5],
  'sp_volleyball': [4, 4, 3, 4, 5, 4],
  'sp_dodgeball': [4, 4, 3, 3, 4, 4],
  'sp_tennis': [4, 4, 4, 4, 1, 5],
  'sp_badminton': [4, 4, 4, 3, 2, 5],
  'sp_tabletennis': [4, 3, 3, 3, 2, 5],
  'sp_sprint': [5, 3, 1, 5, 1, 2],
  'sp_marathon': [4, 5, 5, 2, 1, 3],
  'sp_relay': [4, 3, 2, 5, 5, 3],
  'sp_longjump': [3, 2, 1, 5, 1, 3],
  'sp_freestyle': [5, 5, 5, 4, 1, 2],
  'sp_backstroke': [3, 4, 4, 3, 1, 2],
  'sp_swimming_breast': [3, 5, 4, 4, 1, 2],
  'sp_judo': [4, 4, 3, 5, 2, 4],
  'sp_kendo': [3, 4, 3, 4, 2, 5],
  'sp_karate': [3, 4, 3, 5, 2, 4],
  'sp_sumo': [3, 3, 2, 5, 2, 3],
  'sp_gymnastics': [3, 3, 2, 5, 1, 3],
  'sp_skiing': [4, 4, 3, 4, 1, 4],
  'sp_snowboard': [4, 4, 3, 4, 1, 4],
  'sp_rugby': [4, 5, 5, 5, 5, 4],
  'sp_handball': [3, 5, 4, 4, 5, 4],
  'sp_rhythmic': [3, 3, 3, 3, 3, 3],
  'sp_dance': [4, 4, 4, 4, 2, 3],
  'sp_archery': [3, 1, 2, 2, 2, 4],
  'sp_golf': [3, 2, 2, 3, 1, 5],
  'sp_para': [4, 4, 3, 3, 4, 5],
  'sp_jumprope': [5, 4, 4, 3, 2, 3],
};

/// 登録のない競技は人気度だけを反映した標準値にする。
List<int> sportRadarValues(String id, int popularity) =>
    _profiles[id] ?? [popularity, 3, 3, 3, 3, 3];

/// 6角形のレーダーチャート。
class SportRadarChart extends StatelessWidget {
  final List<int> values;
  final Color color;
  final double size;

  const SportRadarChart({
    super.key,
    required this.values,
    this.color = const Color(0xFFFF6D00),
    this.size = 290,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: size,
      child: CustomPaint(painter: _RadarPainter(values, color)),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<int> values;
  final Color color;
  _RadarPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final n = sportRadarLabels.length;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 58;
    Offset point(int i, double r) {
      final a = -math.pi / 2 + 2 * math.pi * i / n;
      return center + Offset(math.cos(a), math.sin(a)) * r;
    }

    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.grey.shade300;
    for (var level = 1; level <= 5; level++) {
      final path = Path();
      for (var i = 0; i < n; i++) {
        final p = point(i, radius * level / 5);
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path..close(), grid);
    }
    for (var i = 0; i < n; i++) {
      canvas.drawLine(center, point(i, radius), grid);
    }

    final data = Path();
    for (var i = 0; i < n; i++) {
      final v = values[i].clamp(0, 5).toDouble();
      final p = point(i, radius * v / 5);
      i == 0 ? data.moveTo(p.dx, p.dy) : data.lineTo(p.dx, p.dy);
    }
    data.close();
    canvas.drawPath(data, Paint()..color = color.withValues(alpha: 0.28));
    canvas.drawPath(
      data,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color,
    );
    for (var i = 0; i < n; i++) {
      final v = values[i].clamp(0, 5).toDouble();
      canvas.drawCircle(point(i, radius * v / 5), 4, Paint()..color = color);
    }

    for (var i = 0; i < n; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${sportRadarLabels[i]}\n${values[i]}',
          style: const TextStyle(
              fontSize: 12, height: 1.2, color: Color(0xFF444444)),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      final p = point(i, radius + 30);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.values != values || old.color != color;
}
