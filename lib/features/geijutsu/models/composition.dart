import 'dart:convert';

enum CompositionStage {
  stage1, stage2, stage3, stage4, stage5, stage6, stage7, stage8
}

class NoteEntry {
  final String note;   // C4, D4, E4, F4, G4
  final double duration; // 拍数
  NoteEntry({required this.note, required this.duration});

  Map<String, dynamic> toJson() => {'note': note, 'duration': duration};
  factory NoteEntry.fromJson(Map<String, dynamic> j) =>
      NoteEntry(note: j['note'] as String, duration: (j['duration'] as num).toDouble());
}

class Composition {
  final String id;
  final CompositionStage stage;
  final String title;
  final String theme;        // 楽しさ、悲しみ、etc.
  final String instrument;
  final String pattern;      // ascending, descending, loop, jump
  final List<NoteEntry> melody;
  final String? timesignature; // 4/4, 3/4
  final int? tempo;
  final List<String> chords;
  final bool hasDrums;
  final bool hasVocal;
  final String? audioPath;
  final List<String> badges;
  final DateTime createdAt;

  const Composition({
    required this.id,
    required this.stage,
    required this.title,
    required this.theme,
    required this.instrument,
    required this.pattern,
    required this.melody,
    this.timesignature,
    this.tempo,
    this.chords = const [],
    this.hasDrums = false,
    this.hasVocal = false,
    this.audioPath,
    this.badges = const [],
    required this.createdAt,
  });

  int get stageNumber => stage.index + 1;

  Map<String, dynamic> toJson() => {
    'id': id,
    'stage': stage.index,
    'title': title,
    'theme': theme,
    'instrument': instrument,
    'pattern': pattern,
    'melody': melody.map((n) => n.toJson()).toList(),
    'timesignature': timesignature,
    'tempo': tempo,
    'chords': chords,
    'hasDrums': hasDrums,
    'hasVocal': hasVocal,
    'audioPath': audioPath,
    'badges': badges,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Composition.fromJson(Map<String, dynamic> j) => Composition(
    id: j['id'] as String,
    stage: CompositionStage.values[j['stage'] as int],
    title: j['title'] as String,
    theme: j['theme'] as String,
    instrument: j['instrument'] as String,
    pattern: j['pattern'] as String,
    melody: (j['melody'] as List).map((e) => NoteEntry.fromJson(e)).toList(),
    timesignature: j['timesignature'] as String?,
    tempo: j['tempo'] as int?,
    chords: List<String>.from(j['chords'] ?? []),
    hasDrums: j['hasDrums'] as bool? ?? false,
    hasVocal: j['hasVocal'] as bool? ?? false,
    audioPath: j['audioPath'] as String?,
    badges: List<String>.from(j['badges'] ?? []),
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

class CompositionCollection {
  final List<Composition> items;
  CompositionCollection(this.items);

  int get maxStageCompleted => items.isEmpty
      ? 0
      : items.map((c) => c.stageNumber).reduce((a, b) => a > b ? a : b);

  Composition? forStage(CompositionStage stage) {
    final matches = items.where((c) => c.stage == stage).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matches.isEmpty ? null : matches.first;
  }

  String toJsonString() => jsonEncode(items.map((c) => c.toJson()).toList());

  factory CompositionCollection.fromJsonString(String s) {
    final list = jsonDecode(s) as List;
    return CompositionCollection(list.map((e) => Composition.fromJson(e)).toList());
  }
}
