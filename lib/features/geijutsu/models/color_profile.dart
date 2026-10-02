import 'dart:convert';

class ColorProfile {
  final double warmAffinity;   // 0-100
  final double coolAffinity;
  final double neutralAffinity;
  final String primaryColor;
  final List<String> secondaryColors;
  final String expressionStyle; // 情熱派・癒し系・思索派・バランス型
  final DateTime diagnosticDate;

  const ColorProfile({
    required this.warmAffinity,
    required this.coolAffinity,
    required this.neutralAffinity,
    required this.primaryColor,
    required this.secondaryColors,
    required this.expressionStyle,
    required this.diagnosticDate,
  });

  factory ColorProfile.empty() => ColorProfile(
    warmAffinity: 0,
    coolAffinity: 0,
    neutralAffinity: 0,
    primaryColor: '',
    secondaryColors: [],
    expressionStyle: '',
    diagnosticDate: DateTime.now(),
  );

  bool get isCompleted => primaryColor.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'warmAffinity': warmAffinity,
    'coolAffinity': coolAffinity,
    'neutralAffinity': neutralAffinity,
    'primaryColor': primaryColor,
    'secondaryColors': secondaryColors,
    'expressionStyle': expressionStyle,
    'diagnosticDate': diagnosticDate.toIso8601String(),
  };

  factory ColorProfile.fromJson(Map<String, dynamic> j) => ColorProfile(
    warmAffinity: (j['warmAffinity'] as num).toDouble(),
    coolAffinity: (j['coolAffinity'] as num).toDouble(),
    neutralAffinity: (j['neutralAffinity'] as num).toDouble(),
    primaryColor: j['primaryColor'] as String,
    secondaryColors: List<String>.from(j['secondaryColors'] ?? []),
    expressionStyle: j['expressionStyle'] as String,
    diagnosticDate: DateTime.parse(j['diagnosticDate'] as String),
  );

  String toJsonString() => jsonEncode(toJson());
  factory ColorProfile.fromJsonString(String s) => ColorProfile.fromJson(jsonDecode(s));
}
