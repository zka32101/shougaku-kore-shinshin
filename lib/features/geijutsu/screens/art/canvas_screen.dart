import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../providers/app_providers.dart';
import '../../models/artwork.dart';
import '../../theme/app_theme.dart';

class CanvasScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;
  const CanvasScreen({super.key, required this.args});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  final _repaintKey = GlobalKey();
  final List<_Stroke> _strokes = [];
  _Stroke? _current;
  Color _selectedColor = kColorRed;
  double _brushSize = 8.0;
  int _brushType = 0; // 0=通常, 1=太筆, 2=柔らか
  bool _isSaving = false;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  late final int _month;
  late final int _level;
  late final String _colorName;
  late final String _colorHex;

  @override
  void initState() {
    super.initState();
    _month = widget.args['month'] as int;
    _level = widget.args['level'] as int;
    _colorName = widget.args['color'] as String;
    _colorHex = widget.args['colorHex'] as String;
    _selectedColor = kMonthColors[_month - 1]['color'] as Color;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  List<Color> get _palette {
    final base = kMonthColors[_month - 1]['color'] as Color;
    final r = (base.r * 255.0).round();
    final g = (base.g * 255.0).round();
    final b = (base.b * 255.0).round();
    return [
      base,
      Color.fromARGB(255, (r * 0.7).toInt(), (g * 0.7).toInt(), (b * 0.7).toInt()),
      Color.fromARGB(255,
        (r + (255 - r) * 0.3).toInt(),
        (g + (255 - g) * 0.3).toInt(),
        (b + (255 - b) * 0.3).toInt(),
      ),
      Color.fromARGB(255,
        (r + (255 - r) * 0.6).toInt(),
        (g + (255 - g) * 0.6).toInt(),
        (b + (255 - b) * 0.6).toInt(),
      ),
      if (_level >= 3) ...[
        const Color(0xFF2C3E50),
        const Color(0xFF5D6D7E),
        Colors.white,
      ],
      if (_level == 4) ...[
        Color.fromARGB(255, r, ((g * 0.5 + b * 0.5)).toInt(), b),
        Color.fromARGB(255, (r * 0.8 + 40).clamp(0, 255).toInt(), g, (b * 1.2).clamp(0, 255).toInt()),
      ],
    ];
  }

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _current = _Stroke(
        color: _selectedColor,
        width: _brushSize * (_brushType == 1 ? 2.5 : _brushType == 2 ? 1.5 : 1.0),
        isSmooth: _brushType == 2,
        points: [d.localPosition],
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_current == null) return;
    setState(() => _current!.points.add(d.localPosition));
  }

  void _onPanEnd(DragEndDetails d) {
    if (_current == null) return;
    setState(() {
      _strokes.add(_current!);
      _current = null;
    });
  }

  Future<String?> _saveToFile() async {
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      final bytes = byteData.buffer.asUint8List();
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/artwork_m${_month}_lv${_level}_${const Uuid().v4().substring(0, 8)}.png';
      await File(path).writeAsBytes(bytes);
      return path;
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('まず何か描いてみよう！')),
      );
      return;
    }
    await _showSaveDialog();
  }

  Future<void> _showSaveDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '作品を保存しよう',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: kMonthColors[_month - 1]['color'] as Color),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: '作品タイトル',
                hintText: '例：夜明けへの赤',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '何を表現したか (20-50字)',
                hintText: '例：赤だけで「情熱」を描きました...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                setState(() => _isSaving = true);
                Navigator.pop(context);
                await _doSave();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kMonthColors[_month - 1]['color'] as Color,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('保存する ✓', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doSave() async {
    final imagePath = await _saveToFile();
    final colorData = kMonthColors[_month - 1];
    final artwork = Artwork(
      id: const Uuid().v4(),
      month: _month,
      level: ArtLevel.values[_level - 1],
      colorName: _colorName,
      colorHex: _colorHex,
      title: _titleCtrl.text.isEmpty ? '作品 Lv$_level' : _titleCtrl.text,
      description: _descCtrl.text,
      imagePath: imagePath,
      badges: ['art_m${_month}_lv$_level'],
      createdAt: DateTime.now(),
    );

    await ref.read(artworkProvider.notifier).add(artwork);

    final badgeId = 'art_m${_month}_lv$_level';
    final badgeDefs = {
      1: ['${_colorName}の探検家', '🔴', '${_colorName}の探検家バッジ'],
      2: ['${_colorName}の表現者', '🎭', '${_colorName}だけで表現した'],
      3: ['対比の大師', '⚔️', '2色の対比を表現した'],
      4: ['${_colorName}の哲学者', '🏆', '${_colorName}の世界を完全表現した'],
    };
    final bd = badgeDefs[_level]!;
    await ref.read(badgeProvider.notifier).award(badgeId, bd[0], 'art', bd[1], bd[2]);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('作品を保存しました！バッジ「${bd[0]}」獲得！'),
          backgroundColor: colorData['color'] as Color,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = kMonthColors[_month - 1]['color'] as Color;
    final canvasSize = _level == 4 ? 500.0 : _level == 3 ? 400.0 : 350.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lv$_level: ${_colorName}で描こう'),
        backgroundColor: color,
        foregroundColor: Colors.white,
        actions: [
          if (_strokes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => setState(() => _strokes.removeLast()),
              tooltip: 'やり直す',
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('全消去'),
                content: const Text('全てのストロークを消しますか？'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
                  TextButton(
                    onPressed: () { setState(() => _strokes.clear()); Navigator.pop(context); },
                    child: const Text('消す', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            tooltip: '全消去',
          ),
        ],
      ),
      body: Column(
        children: [
          // コーチングメッセージ
          Container(
            color: color.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _getCoachingMessage(),
              style: TextStyle(fontSize: 13, color: color, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          // キャンバス
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: Container(
                      width: canvasSize,
                      height: canvasSize,
                      color: Colors.white,
                      child: GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: CustomPaint(
                          painter: _CanvasPainter(
                            strokes: _strokes,
                            current: _current,
                          ),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // ツールバー
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                // カラーパレット
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: _palette.map((c) {
                      final sel = _selectedColor.value == c.value;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: sel ? 40 : 32,
                          height: sel ? 40 : 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: sel ? Border.all(color: Colors.black, width: 3) : null,
                            boxShadow: sel ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)] : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // ブラシサイズ・種類
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.brush, size: 16),
                      Expanded(
                        child: Slider(
                          value: _brushSize,
                          min: 2, max: 24,
                          onChanged: (v) => setState(() => _brushSize = v),
                          activeColor: _selectedColor,
                        ),
                      ),
                      ...List.generate(3, (i) {
                        const labels = ['通常', '太筆', '柔らか'];
                        return GestureDetector(
                          onTap: () => setState(() => _brushType = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _brushType == i ? color : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                fontSize: 11,
                                color: _brushType == i ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 保存ボタン
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('作品を保存する ✓', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCoachingMessage() {
    const msgs = {
      1: '身の回りの「色」を思い出しながら、感情を描いてみよう！',
      2: '「濃い色と薄い色」、使い分けてる？奥行きを出してみて！',
      3: '「2色の対比」で、葛藤や決意を表現しよう！',
      4: '色相・明度・彩度の全てを使いこなして「あなたの世界」を完成させよう！',
    };
    return msgs[_level] ?? '';
  }
}

class _Stroke {
  final Color color;
  final double width;
  final bool isSmooth;
  final List<Offset> points;

  _Stroke({
    required this.color,
    required this.width,
    required this.isSmooth,
    required this.points,
  });
}

class _CanvasPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final _Stroke? current;

  _CanvasPainter({required this.strokes, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, if (current != null) current!]) {
      _drawStroke(canvas, stroke);
    }
  }

  void _drawStroke(Canvas canvas, _Stroke stroke) {
    if (stroke.points.isEmpty) return;
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.isSmooth) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    }

    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points.first, stroke.width / 2, paint..style = PaintingStyle.fill);
      return;
    }

    final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length - 1; i++) {
      final mid = Offset(
        (stroke.points[i].dx + stroke.points[i + 1].dx) / 2,
        (stroke.points[i].dy + stroke.points[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(stroke.points[i].dx, stroke.points[i].dy, mid.dx, mid.dy);
    }
    path.lineTo(stroke.points.last.dx, stroke.points.last.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CanvasPainter old) => true;
}
