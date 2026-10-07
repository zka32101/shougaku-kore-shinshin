import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/glossary.dart';
import '../providers/furigana_provider.dart';
import '../utils/furigana.dart';

/// 文章の中のむずかしい言葉(語彙集にある言葉)を見つけて分割する。
/// 長い語を優先。語彙に当たらない部分は glossary=null の断片になる。
List<({String text, String? term})> splitByGlossary(
  String text,
  Iterable<String> terms,
) {
  final sorted = terms.toList()..sort((a, b) => b.length.compareTo(a.length));
  final out = <({String text, String? term})>[];
  final buf = StringBuffer();
  var i = 0;
  while (i < text.length) {
    String? hit;
    for (final t in sorted) {
      if (text.startsWith(t, i)) {
        hit = t;
        break;
      }
    }
    if (hit == null) {
      buf.write(text[i]);
      i++;
    } else {
      if (buf.isNotEmpty) {
        out.add((text: buf.toString(), term: null));
        buf.clear();
      }
      out.add((text: hit, term: hit));
      i += hit.length;
    }
  }
  if (buf.isNotEmpty) out.add((text: buf.toString(), term: null));
  return out;
}

/// 学年に合わせて「漢字（かんじ）」形式のふりがなを付けるテキスト。
/// [glossary] が true のとき、語彙集にある言葉はタップで意味を表示する。
class FuriganaText extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool glossary;

  /// テストや特別な画面で学年を固定したいとき。
  final int? gradeOverride;

  const FuriganaText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.glossary = false,
    this.gradeOverride,
  });

  @override
  ConsumerState<FuriganaText> createState() => _FuriganaTextState();
}

class _FuriganaTextState extends ConsumerState<FuriganaText> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  List<InlineSpan> _ruby(
    String text,
    FuriganaEngine? engine,
    int grade,
    TextStyle base,
    TextStyle? override,
  ) {
    if (engine == null) return [TextSpan(text: text, style: override)];
    final fs = base.fontSize ?? 14;
    final rubyStyle = TextStyle(
      fontSize: fs * 0.62,
      fontWeight: FontWeight.w400,
      color: (override?.color ?? base.color)?.withValues(alpha: 0.72),
    );
    return [
      for (final p in engine.convert(text, grade)) ...[
        TextSpan(text: p.text, style: override),
        if (p.reading != null) TextSpan(text: '（${p.reading}）', style: rubyStyle),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final base = DefaultTextStyle.of(context).style.merge(widget.style);
    final engine = ref.watch(furiganaEngineProvider).valueOrNull;
    final int grade = widget.gradeOverride ?? ref.watch(readingGradeProvider);

    final spans = <InlineSpan>[];
    if (widget.glossary) {
      for (final seg in splitByGlossary(widget.text, kGlossary.keys)) {
        if (seg.term == null) {
          spans.addAll(_ruby(seg.text, engine, grade, base, null));
        } else {
          final rec = TapGestureRecognizer()
            ..onTap = () => showGlossarySheet(context, seg.term!);
          _recognizers.add(rec);
          final inner = _ruby(seg.text, engine, grade, base, null);
          spans.add(TextSpan(
            children: inner,
            recognizer: rec,
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: Theme.of(context).colorScheme.primary,
              decorationThickness: 2,
            ),
          ));
        }
      }
    } else {
      spans.addAll(_ruby(widget.text, engine, grade, base, null));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}

/// 言葉の意味を下から出して見せる。
void showGlossarySheet(BuildContext context, String term) {
  final meaning = kGlossary[term];
  if (meaning == null) return;
  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.menu_book, size: 20),
              const SizedBox(width: 8),
              Text('ことばの いみ',
                  style: Theme.of(ctx)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.grey[700])),
            ]),
            const SizedBox(height: 12),
            FuriganaText(term,
                gradeOverride: null,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FuriganaText(meaning, style: const TextStyle(fontSize: 17, height: 1.6)),
          ],
        ),
      ),
    ),
  );
}
