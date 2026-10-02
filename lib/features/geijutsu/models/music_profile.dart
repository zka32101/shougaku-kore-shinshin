import 'dart:convert';

class MusicProfile {
  final String musicType;        // リズム感応型・メロディ感応型・身体感応型・純粋聴覚型
  final double melodyAffinity;   // 0-100
  final double rhythmAffinity;
  final double bodyMemory;
  final double dynamicsAffinity;
  final double emotionResponse;
  final List<String> strengths;
  final List<String> preferredInstruments;
  final DateTime diagnosticDate;

  const MusicProfile({
    required this.musicType,
    required this.melodyAffinity,
    required this.rhythmAffinity,
    required this.bodyMemory,
    required this.dynamicsAffinity,
    required this.emotionResponse,
    required this.strengths,
    required this.preferredInstruments,
    required this.diagnosticDate,
  });

  factory MusicProfile.empty() => MusicProfile(
    musicType: '',
    melodyAffinity: 0,
    rhythmAffinity: 0,
    bodyMemory: 0,
    dynamicsAffinity: 0,
    emotionResponse: 0,
    strengths: [],
    preferredInstruments: [],
    diagnosticDate: DateTime.now(),
  );

  bool get isCompleted => musicType.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'musicType': musicType,
    'melodyAffinity': melodyAffinity,
    'rhythmAffinity': rhythmAffinity,
    'bodyMemory': bodyMemory,
    'dynamicsAffinity': dynamicsAffinity,
    'emotionResponse': emotionResponse,
    'strengths': strengths,
    'preferredInstruments': preferredInstruments,
    'diagnosticDate': diagnosticDate.toIso8601String(),
  };

  factory MusicProfile.fromJson(Map<String, dynamic> j) => MusicProfile(
    musicType: j['musicType'] as String,
    melodyAffinity: (j['melodyAffinity'] as num).toDouble(),
    rhythmAffinity: (j['rhythmAffinity'] as num).toDouble(),
    bodyMemory: (j['bodyMemory'] as num).toDouble(),
    dynamicsAffinity: (j['dynamicsAffinity'] as num).toDouble(),
    emotionResponse: (j['emotionResponse'] as num).toDouble(),
    strengths: List<String>.from(j['strengths'] ?? []),
    preferredInstruments: List<String>.from(j['preferredInstruments'] ?? []),
    diagnosticDate: DateTime.parse(j['diagnosticDate'] as String),
  );

  String toJsonString() => jsonEncode(toJson());
  factory MusicProfile.fromJsonString(String s) => MusicProfile.fromJson(jsonDecode(s));
}
