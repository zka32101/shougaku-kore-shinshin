import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_features.dart';
import 'story_provider.dart' show apiServiceProvider;

final reasonAnalysisProvider = FutureProvider.autoDispose
    .family<ReasonAnalysis?, (String, String)>((ref, args) async {
  final apiService = ref.watch(apiServiceProvider);
  final (userId, month) = args;
  return apiService.getReasonAnalysis(userId, month);
});

final creationFeedbackProvider = FutureProvider.autoDispose
    .family<CreationFeedback?, (String, String)>((ref, args) async {
  final apiService = ref.watch(apiServiceProvider);
  final (userId, month) = args;
  return apiService.getCreationFeedback(userId, month);
});
