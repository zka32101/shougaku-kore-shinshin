import 'dart:convert';

class CompositionNote {
  final String note; // "C", "C#", "D" ...
  final int durationMs;

  const CompositionNote({required this.note, required this.durationMs});

  Map<String, dynamic> toJson() => {
    'note': note,
    'durationMs': durationMs,
  };

  factory CompositionNote.fromJson(Map<String, dynamic> j) => CompositionNote(
    note: j['note'] as String,
    durationMs: j['durationMs'] as int,
  );
}

class Composition {
  final String id;
  final String title;
  final List<CompositionNote> notes;
  final DateTime createdAt;

  const Composition({
    required this.id,
    required this.title,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'notes': notes.map((n) => n.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Composition.fromJson(Map<String, dynamic> j) => Composition(
    id: j['id'] as String,
    title: j['title'] as String,
    notes: (j['notes'] as List)
        .map((n) => CompositionNote.fromJson(n as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

class CompositionCollection {
  final List<Composition> items;
  CompositionCollection(this.items);

  String toJsonString() => jsonEncode(items.map((c) => c.toJson()).toList());

  factory CompositionCollection.fromJsonString(String s) {
    final list = jsonDecode(s) as List;
    return CompositionCollection(
      list.map((e) => Composition.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
