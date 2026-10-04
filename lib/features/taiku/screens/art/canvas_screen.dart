import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../../models/artwork.dart';
import '../stage_learn_screen.dart';

class CanvasScreen extends ConsumerStatefulWidget {
  final int month;
  final ArtLevel level;
  final String colorName;
  final Color themeColor;
  final int stageNum;

  const CanvasScreen({
    super.key,
    required this.month,
    required this.level,
    required this.colorName,
    required this.themeColor,
    required this.stageNum,
  });

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  final _repaintKey = GlobalKey();
  final List<_Stroke> _strokes = [];
  _Stroke? _current;
  late Color _selectedColor;
  double _brushSize = 8.0;
  int _brushType = 0;
  bool _isSaving = false;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.themeColor;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  List<Color> get _palette {
    final base = widget.themeColor;
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
      if (widget.level != ArtLevel.lv1) ...[
        const Color(0xFF2C3E50),
        const Color(0xFF5D6D7E),
        Colors.white,
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
      final path = '${dir.path}/artwork_m${widget.month}_lv${widget.level.index + 1}_${const Uuid().v4().substring(0, 8)}.png';
      await File(path).writeAsBytes(bytes);
      return path;
    } catch (_) {
      return null;
    }
  }

  String _getCoachingMessage() {
    switch (widget.level) {
      case ArtLevel.lv1:
        return '🎨 1色だけで表現してみよう！情熱・静けさ・喜び...何を感じますか？';
      case ArtLevel.lv2:
        return '🎨 2色を組み合わせて表現しよう！対比する色の関係を探そう。';
      case ArtLevel.lv3:
        return '🎨 3色以上で豊かな世界を描こう！色の調和を感じながら...';
      case ArtLevel.lv4:
        return '🎨 色の深さで感情を表現しよう。濃淡や透明感を使い分けて...';
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
      builder: (context) {
        String? descError;
        return StatefulBuilder(builder: (context, setSheet) {
          return Padding(
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: widget.themeColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: '作品タイトル',
                hintText: '例：熱い心',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 50,
              decoration: InputDecoration(
                labelText: '何を表現したか (20-50字)',
                hintText: '例：赤だけで「情熱」を描きました...',
                border: const OutlineInputBorder(),
                errorText: descError,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving ? null : () async {
                final len = _descCtrl.text.trim().characters.length;
                if (len < 20) {
                  setSheet(() => descError = 'あと${20 - len}字以上書いてね（20〜50字）');
                  return;
                }
                setState(() => _isSaving = true);
                Navigator.pop(context);
                await _doSave();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('保存する ✓', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
        });
      },
    );
  }

  Future<void> _doSave() async {
    await _saveToFile();

    // TODO: Phase 3 で Firestore への保存を実装

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('作品を保存しました！'),
          backgroundColor: widget.themeColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasSize = widget.level == ArtLevel.lv4 ? 500.0 :
                       widget.level == ArtLevel.lv3 ? 400.0 : 350.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lv${widget.level.index + 1}: ${widget.colorName}で描こう'),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'クイズに挑戦',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => StageLearnScreen(
                stageNum: widget.stageNum,
                emoji: widget.level == ArtLevel.lv1 ? '🎨' : '🎭',
                title: widget.level == ArtLevel.lv1 ? '1色で表現' : '2色で対比',
                theme: 'art',
                color: widget.themeColor,
              ),
            )),
          ),
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
          Container(
            color: widget.themeColor.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _getCoachingMessage(),
              style: TextStyle(fontSize: 13, color: widget.themeColor, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
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
                          painter: _CanvasPainter(_strokes, _current),
                          size: Size(canvasSize, canvasSize),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('色を選ぶ', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _palette.map((color) {
                            final isSelected = _selectedColor == color;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedColor = color),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color,
                                    border: isSelected ? Border.all(width: 3, color: Colors.black) : null,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text('ブラシサイズ', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                          Slider(
                            value: _brushSize,
                            min: 2,
                            max: 20,
                            onChanged: (v) => setState(() => _brushSize = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text('ブラシ', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(label: Text('通常'), value: 0),
                            ButtonSegment(label: Text('太'), value: 1),
                            ButtonSegment(label: Text('柔'), value: 2),
                          ],
                          selected: {_brushType},
                          onSelectionChanged: (s) => setState(() => _brushType = s.first),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('保存する'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  _CanvasPainter(this.strokes, this.current);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _paintStroke(canvas, stroke);
    }
    if (current != null) {
      _paintStroke(canvas, current!);
    }
  }

  void _paintStroke(Canvas canvas, _Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points[0], stroke.width / 2, paint);
    } else {
      if (stroke.isSmooth) {
        _drawSmoothPath(canvas, stroke.points, paint);
      } else {
        for (int i = 0; i < stroke.points.length - 1; i++) {
          canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
        }
      }
    }
  }

  void _drawSmoothPath(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.length < 2) return;
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    if (points.length == 2) {
      path.lineTo(points[1].dx, points[1].dy);
    } else {
      for (int i = 0; i < points.length - 1; i++) {
        final xc = (points[i].dx + points[i + 1].dx) / 2;
        final yc = (points[i].dy + points[i + 1].dy) / 2;
        path.quadraticBezierTo(points[i].dx, points[i].dy, xc, yc);
      }
      path.lineTo(points.last.dx, points.last.dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CanvasPainter oldDelegate) => true;
}
