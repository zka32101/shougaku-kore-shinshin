import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/distribution_response.dart';
import 'story_provider.dart' show apiServiceProvider;

final distributionProvider = FutureProvider.autoDispose
    .family<DistributionResponse, String>((ref, storyId) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getDistribution(storyId);
});
