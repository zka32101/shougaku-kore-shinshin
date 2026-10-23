import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants/app_colors.dart';

/// 1本の線（色・太さ・点の列）。消しゴムは白い線として描く。
class DrawingStroke {
  final Color color;
  final double width;
  final List<Offset> points;
  DrawingStroke(this.color, this.width, [List<Offset>? points]) : points = points ?? [];
}

const List<Color> kDrawingColors = [
  Color(0xFF212121),
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFFFDD835),
  Color(0xFF43A047),
  Color(0xFF1E88E5),
  Color(0xFF8E24AA),
  Color(0xFF8D6E63),
];

const List<double> kDrawingWidths = [4, 10, 20];

/// 自由お絵かき。自由に描いて、端末の中にだけ保存できる（外には送らない）。
class FreeDrawingScreen extends StatefulWidget {
  const FreeDrawingScreen({super.key});

  @override
  State<FreeDrawingScreen> createState() => _FreeDrawingScreenState();
}

class _FreeDrawingScreenState extends State<FreeDrawingScreen> {
  final _repaintKey = GlobalKey();
  final List<DrawingStroke> _strokes = [];
  DrawingStroke? _current;
  Color _color = kDrawingColors[1];
  double _width = kDrawingWidths[1];
  bool _eraser = false;
  bool _saving = false;

  void _start(Offset p) {
    final s = DrawingStroke(_eraser ? Colors.white : _color, _eraser ? _width * 1.6 : _width, [p]);
    setState(() => _current = s);
  }

  void _move(Offset p) {
    final s = _current;
    if (s == null) return;
    setState(() => s.points.add(p));
  }

  void _end() {
    final s = _current;
    if (s == null) return;
    setState(() {
      _strokes.add(s);
      _current = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  Future<void> _clear() async {
    if (_strokes.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('ぜんぶ けす？'),
        content: const Text('かいた えを ぜんぶ けします。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('やめる')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('けす')),
        ],
      ),
    );
    if (ok == true && mounted) setState(() => _strokes.clear());
  }

  Future<void> _save() async {
    if (_strokes.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await drawingsDirectory();
      final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(data!.buffer.asUint8List());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ほぞん したよ！')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ほぞん できなかったよ。もういちど ためしてね。')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('おえかき'),
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('drawing_gallery'),
            tooltip: 'ほぞんした え',
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DrawingGalleryScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: Container(
                      color: Colors.white,
                      child: GestureDetector(
                        key: const Key('drawing_canvas'),
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (d) => _start(d.localPosition),
                        onPanUpdate: (d) => _move(d.localPosition),
                        onPanEnd: (_) => _end(),
                        onPanCancel: _end,
                        child: CustomPaint(
                          painter: _DrawingPainter([..._strokes, ?_current]),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in kDrawingColors)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _color = c;
                        _eraser = false;
                      }),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: !_eraser && _color == c ? Colors.black : Colors.black26,
                            width: !_eraser && _color == c ? 3 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final w in kDrawingWidths)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _width = w),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _width == w ? Colors.black12 : Colors.transparent,
                      ),
                      child: Container(
                        width: w + 4,
                        height: w + 4,
                        decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              _ToolButton(
                icon: Icons.auto_fix_normal,
                label: 'けしごむ',
                selected: _eraser,
                onTap: () => setState(() => _eraser = !_eraser),
              ),
              _ToolButton(icon: Icons.undo, label: 'もどす', onTap: _strokes.isEmpty ? null : _undo),
              _ToolButton(icon: Icons.delete_outline, label: 'ぜんぶけす', onTap: _strokes.isEmpty ? null : _clear),
              _ToolButton(
                key: const Key('drawing_save'),
                icon: Icons.save_alt,
                label: 'ほぞん',
                onTap: _strokes.isEmpty || _saving ? null : _save,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _ToolButton({super.key, required this.icon, required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? Colors.black12 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: enabled ? AppColors.textPrimary : Colors.black26),
            Text(label, style: TextStyle(fontSize: 10, color: enabled ? AppColors.textPrimary : Colors.black26)),
          ],
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length == 1) {
        canvas.drawCircle(s.points.first, s.width / 2, paint..style = PaintingStyle.fill);
        continue;
      }
      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (var i = 1; i < s.points.length; i++) {
        path.lineTo(s.points[i].dx, s.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter old) => true;
}

/// 保存した絵を置くフォルダ（端末の中だけ。なければ作る）。
Future<Directory> drawingsDirectory() async {
  final base = await getApplicationDocumentsDirectory();
  final dir = Directory('${base.path}/drawings');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// 保存した絵の一覧（新しい順）。タップで大きく見て、おとなの確認のあと消せる。
class DrawingGalleryScreen extends StatefulWidget {
  const DrawingGalleryScreen({super.key});

  @override
  State<DrawingGalleryScreen> createState() => _DrawingGalleryScreenState();
}

class _DrawingGalleryScreenState extends State<DrawingGalleryScreen> {
  List<File> _files = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final dir = await drawingsDirectory();
    final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.png')).toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    if (!mounted) return;
    setState(() {
      _files = files;
      _loading = false;
    });
  }

  Future<void> _open(File f) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        contentPadding: const EdgeInsets.all(12),
        content: Image.file(f),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('とじる')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('この えを けす')),
        ],
      ),
    );
    if (delete == true) {
      await f.delete();
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ほぞんした え'),
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? const Center(child: Text('まだ えが ないよ。かいて ほぞん してみよう！'))
              : GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(12),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (final f in _files)
                      InkWell(
                        onTap: () => _open(f),
                        child: DecoratedBox(
                          decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
                          child: Image.file(f, fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
    );
  }
}
