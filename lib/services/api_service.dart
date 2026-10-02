import 'package:dio/dio.dart';
import '../models/distribution_response.dart';
import '../models/revisit_schedule.dart';
import '../models/parent_child_comparison.dart';
import '../models/kindness_mission.dart';
import '../models/ai_features.dart';
import '../models/ranking.dart';
import '../models/story.dart';
import '../models/child_profile.dart';
import '../models/progress.dart';
import '../models/report.dart';
import 'logger_service.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}

class ApiService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.shougaku-kore.jp/api/v1';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(milliseconds: 500);


  ApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  /// バックエンド JWT を認証ヘッダーに設定する（Firebase IDトークン交換後に呼ぶ）
  void setAuthToken(String jwt) {
    _dio.options.headers['Authorization'] = 'Bearer $jwt';
  }

  /// 認証ヘッダーをクリアする（ログアウト時・トークン交換失敗時）
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Validates that a string parameter is not empty
  String _validateParam(String value, String paramName) {
    if (value.isEmpty) {
      throw ApiException('Parameter $paramName cannot be empty');
    }
    return value;
  }

  /// Validates response data structure
  bool _isValidResponse(dynamic data) {
    return data != null && data is Map<String, dynamic>;
  }

  /// Retries a request with exponential backoff
  Future<Response<dynamic>> _retryRequest(
    Future<Response<dynamic>> Function() request,
  ) async {
    int attempt = 0;
    late DioException lastError;

    while (attempt < _maxRetries) {
      try {
        return await request();
      } on DioException catch (e) {
        lastError = e;
        // Only retry on transient errors (timeout, connection errors)
        if (!_isTransientError(e)) {
          rethrow;
        }

        attempt++;
        if (attempt < _maxRetries) {
          final delay = _retryDelay * (1 << (attempt - 1)); // exponential backoff
          LoggerService.info('Retrying request (attempt $attempt/$_maxRetries) after $delay');
          await Future.delayed(delay);
        }
      }
    }

    throw lastError;
  }

  /// Determines if an error is transient (should be retried)
  bool _isTransientError(DioException e) {
    // Timeout errors
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return true;
    }

    // Network errors
    if (e.type == DioExceptionType.unknown) {
      final error = e.error;
      // Check for connection reset, no route to host, etc.
      if (error is Exception) {
        return error.toString().contains('SocketException') ||
            error.toString().contains('Connection refused') ||
            error.toString().contains('Connection reset');
      }
      return true;
    }

    // Server errors (5xx) are transient
    if (e.response?.statusCode != null &&
        e.response!.statusCode! >= 500 &&
        e.response!.statusCode! < 600) {
      return true;
    }

    return false;
  }

  Future<DistributionResponse> getDistribution(String storyId) async {
    try {
      _validateParam(storyId, 'storyId');

      final response = await _retryRequest(
        () => _dio.get('/stories/$storyId/distribution'),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for distribution');
      }

      LoggerService.info('Distribution fetched for story: $storyId');
      return DistributionResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to fetch distribution for $storyId',
        error: e,
      );
      throw ApiException(
        'Failed to fetch distribution: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  Future<List<RevisitStory>> getRevisitStories(String userId) async {
    try {
      _validateParam(userId, 'userId');

      final response = await _retryRequest(
        () => _dio.get('/users/$userId/revisit-stories'),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for revisit stories');
      }

      final List<dynamic> data = response.data['revisits'] ?? [];

      LoggerService.info('Revisit stories fetched for user: $userId (count: ${data.length})');
      return data.map((item) => RevisitStory.fromJson(item)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to fetch revisit stories for $userId',
        error: e,
      );
      throw ApiException(
        'Failed to fetch revisit stories: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  Future<RevisitResult> answerRevisitStory(
    String revisitId,
    String answerChoice,
  ) async {
    try {
      _validateParam(revisitId, 'revisitId');
      _validateParam(answerChoice, 'answerChoice');

      final response = await _retryRequest(
        () => _dio.post(
          '/revisit-stories/$revisitId/answer',
          data: {'answer_choice': answerChoice},
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for revisit answer');
      }

      LoggerService.info('Revisit story answered: $revisitId with choice: $answerChoice');
      return RevisitResult.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to answer revisit story: $revisitId',
        error: e,
      );
      throw ApiException(
        'Failed to answer revisit story: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  Future<ParentAnswerResponse> answerParentChildStory(
    String parentId,
    String childId,
    String storyId,
    String answerChoice,
  ) async {
    try {
      _validateParam(parentId, 'parentId');
      _validateParam(childId, 'childId');
      _validateParam(storyId, 'storyId');
      _validateParam(answerChoice, 'answerChoice');

      final response = await _retryRequest(
        () => _dio.post(
          '/parent-child/$parentId/$childId/answer',
          data: {
            'story_id': storyId,
            'answer_choice': answerChoice,
          },
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for parent-child answer');
      }

      LoggerService.info('Parent-child story answered: $storyId');
      return ParentAnswerResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to answer parent-child story',
        error: e,
      );
      throw ApiException(
        'Failed to answer parent-child story: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  Future<List<ParentChildComparison>> getParentChildDialogueHistory(
    String parentId,
    String childId,
  ) async {
    try {
      _validateParam(parentId, 'parentId');
      _validateParam(childId, 'childId');

      final response = await _retryRequest(
        () => _dio.get(
          '/parent-child/$parentId/$childId/dialogue-history',
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for dialogue history');
      }

      final List<dynamic> data = response.data['histories'] ?? [];

      LoggerService.info('Dialogue history fetched: ${data.length} items');
      return data.map((item) => ParentChildComparison.fromJson(item)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to fetch dialogue history',
        error: e,
      );
      throw ApiException(
        'Failed to fetch dialogue history: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  Future<ParentChildComparison?> getLatestParentChildComparison(
    String parentId,
    String childId,
  ) async {
    try {
      final histories = await getParentChildDialogueHistory(parentId, childId);
      return histories.isNotEmpty ? histories.first : null;
    } on ApiException {
      rethrow;
    }
  }

  Future<KindnessMission> getCurrentMission(String userId) async {
    try {
      _validateParam(userId, 'userId');

      final response = await _retryRequest(
        () => _dio.get('/users/$userId/kindness/mission'),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for mission');
      }

      LoggerService.info('Kindness mission fetched for user: $userId');
      return KindnessMission.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to fetch mission for user: $userId',
        error: e,
      );
      throw ApiException(
        'Failed to fetch mission: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  Future<KindnessRecordResponse> recordKindness(
    String userId,
    String description,
    String? person,
    String? context,
  ) async {
    try {
      _validateParam(userId, 'userId');
      _validateParam(description, 'description');

      final response = await _retryRequest(
        () => _dio.post(
          '/users/$userId/kindness-records',
          data: {
            'kindness_description': description,
            'person_involved': person,
            'context': context,
          },
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for kindness record');
      }

      LoggerService.info('Kindness recorded for user: $userId');
      return KindnessRecordResponse.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to record kindness for user: $userId',
        error: e,
      );
      throw ApiException(
        'Failed to record kindness: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  Future<KindnessMap> getKindnessMap(String userId, String month) async {
    try {
      _validateParam(userId, 'userId');
      _validateParam(month, 'month');

      final response = await _retryRequest(
        () => _dio.get(
          '/users/$userId/kindness-map/$month',
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for kindness map');
      }

      LoggerService.info('Kindness map fetched for user: $userId, month: $month');
      return KindnessMap.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to fetch kindness map for user: $userId',
        error: e,
      );
      throw ApiException(
        'Failed to fetch kindness map: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  // ③ りゆう記録分析（月50人抽出版）
  Future<ReasonAnalysis?> getReasonAnalysis(String userId, String month) async {
    try {
      _validateParam(userId, 'userId');
      _validateParam(month, 'month');

      final response = await _retryRequest(
        () => _dio.get(
          '/users/$userId/reason-analysis/$month',
        ),
      );

      // No content status
      if (response.statusCode == 204) return null;

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for reason analysis');
      }

      LoggerService.info('Reason analysis fetched for user: $userId, month: $month');
      return ReasonAnalysis.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        LoggerService.info('Reason analysis not found for user: $userId, month: $month');
        return null;
      }
      LoggerService.error(
        'Failed to fetch reason analysis for user: $userId',
        error: e,
      );
      throw ApiException(
        'Failed to fetch reason analysis: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  // ⑤ 創作フィード — 記録
  Future<void> submitCreation(
    String userId,
    String storyId,
    String storyTitle,
    String userCreatedEnding,
  ) async {
    try {
      _validateParam(userId, 'userId');
      _validateParam(storyId, 'storyId');
      _validateParam(storyTitle, 'storyTitle');
      _validateParam(userCreatedEnding, 'userCreatedEnding');

      await _retryRequest(
        () => _dio.post(
          '/users/$userId/creations',
          data: {
            'story_id': storyId,
            'story_title': storyTitle,
            'user_created_ending': userCreatedEnding,
          },
        ),
      );

      LoggerService.info('Creation submitted for user: $userId, story: $storyId');
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to submit creation for user: $userId',
        error: e,
      );
      throw ApiException(
        'Failed to submit creation: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  // ⑤ 創作フィード — 月次フィードバック取得
  Future<CreationFeedback?> getCreationFeedback(
    String userId,
    String month,
  ) async {
    try {
      _validateParam(userId, 'userId');
      _validateParam(month, 'month');

      final response = await _retryRequest(
        () => _dio.get(
          '/users/$userId/creation-feedback/$month',
        ),
      );

      // No content status
      if (response.statusCode == 204) return null;

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for creation feedback');
      }

      LoggerService.info('Creation feedback fetched for user: $userId, month: $month');
      return CreationFeedback.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        LoggerService.info(
          'Creation feedback not found for user: $userId, month: $month',
        );
        return null;
      }
      LoggerService.error(
        'Failed to fetch creation feedback for user: $userId',
        error: e,
      );
      throw ApiException(
        'Failed to fetch creation feedback: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// 月間ランキングを取得
  Future<List<RankingEntry>> getMonthlyRanking(
    String month,
    String groupType, {
    String? groupValue,
  }) async {
    try {
      _validateParam(month, 'month');
      _validateParam(groupType, 'groupType');

      final params = {
        'group_type': groupType,
        'group_value': ?groupValue,
      };

      final response = await _retryRequest(
        () => _dio.get(
          '/rankings/month/$month',
          queryParameters: params,
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for monthly ranking');
      }

      final List<dynamic> rankings = response.data['rankings'] ?? [];

      LoggerService.info(
          'Monthly ranking fetched: ${rankings.length} entries for $month ($groupType)');
      return rankings.map((item) => RankingEntry.fromJson(item)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error(
        'Failed to fetch monthly ranking for $month',
        error: e,
      );
      throw ApiException(
        'Failed to fetch monthly ranking: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  // ========================================================
  // 認証
  // ========================================================

  /// Firebase IDトークンをバックエンドJWTに交換する
  /// POST /api/v1/auth/firebase
  Future<Map<String, dynamic>> loginWithFirebase(String firebaseIdToken) async {
    try {
      _validateParam(firebaseIdToken, 'firebaseIdToken');

      final response = await _retryRequest(
        () => _dio.post(
          '/auth/firebase',
          data: {'firebase_token': firebaseIdToken},
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for firebase login');
      }

      LoggerService.info('Firebase login exchanged for backend JWT');
      return response.data as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to exchange firebase token', error: e);
      throw ApiException(
        'Failed to login with firebase: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  // ========================================================
  // ストーリー
  // ========================================================

  /// GET /api/v1/stories
  Future<List<Story>> fetchStories({
    String? theme,
    int? gradeLevel,
    bool? isPremium,
  }) async {
    try {
      final params = {
        'theme': ?theme,
        'grade': ?gradeLevel,
        'is_premium': ?isPremium,
      };

      final response = await _retryRequest(
        () => _dio.get('/stories', queryParameters: params),
      );

      final data = response.data;
      if (data is! List) {
        throw ApiException('Expected stories to be a list');
      }

      LoggerService.info('Stories fetched: ${data.length}');
      return data.map((item) => Story.fromJson(item)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to fetch stories', error: e);
      throw ApiException(
        'Failed to fetch stories: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// GET /api/v1/stories/weekly/{week_number}
  Future<List<Story>> fetchWeeklyTheme(int weekNumber) async {
    try {
      final response = await _retryRequest(
        () => _dio.get('/stories/weekly/$weekNumber'),
      );

      final data = response.data;
      if (data is! List) {
        throw ApiException('Expected weekly theme stories to be a list');
      }

      LoggerService.info('Weekly theme stories fetched for week $weekNumber: ${data.length}');
      return data.map((item) => Story.fromJson(item)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to fetch weekly theme for week $weekNumber', error: e);
      throw ApiException(
        'Failed to fetch weekly theme: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// GET /api/v1/stories/{story_id}
  Future<Story> fetchStoryDetail(String storyId) async {
    try {
      _validateParam(storyId, 'storyId');

      final response = await _retryRequest(
        () => _dio.get('/stories/$storyId'),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for story detail');
      }

      LoggerService.info('Story detail fetched: $storyId');
      return Story.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to fetch story detail: $storyId', error: e);
      throw ApiException(
        'Failed to fetch story detail: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  // ========================================================
  // 子どもプロフィール
  // ========================================================

  /// GET /api/v1/children
  Future<List<ChildProfile>> fetchChildrenProfiles() async {
    try {
      final response = await _retryRequest(() => _dio.get('/children'));

      final data = response.data;
      if (data is! List) {
        throw ApiException('Expected children profiles to be a list');
      }

      LoggerService.info('Children profiles fetched: ${data.length}');
      return data.map((item) => ChildProfile.fromApiJson(item)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to fetch children profiles', error: e);
      throw ApiException(
        'Failed to fetch children profiles: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// GET /api/v1/children/{child_id}
  Future<ChildProfile> fetchChildProfile(String childId) async {
    try {
      _validateParam(childId, 'childId');

      final response = await _retryRequest(
        () => _dio.get('/children/$childId'),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for child profile');
      }

      LoggerService.info('Child profile fetched: $childId');
      return ChildProfile.fromApiJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to fetch child profile: $childId', error: e);
      throw ApiException(
        'Failed to fetch child profile: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// POST /api/v1/children
  Future<ChildProfile> createChild({
    required String name,
    required int grade,
    required String avatarEmoji,
  }) async {
    try {
      _validateParam(name, 'name');

      final response = await _retryRequest(
        () => _dio.post(
          '/children',
          data: {
            'name': name,
            'grade': grade,
            'avatarEmoji': avatarEmoji,
          },
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for created child');
      }

      LoggerService.info('Child created: $name');
      return ChildProfile.fromApiJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to create child: $name', error: e);
      throw ApiException(
        'Failed to create child: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// PUT /api/v1/children/{child_id}
  Future<void> updateChild(String childId, Map<String, dynamic> updates) async {
    try {
      _validateParam(childId, 'childId');

      await _retryRequest(
        () => _dio.put('/children/$childId', data: updates),
      );

      LoggerService.info('Child updated: $childId');
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to update child: $childId', error: e);
      throw ApiException(
        'Failed to update child: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// DELETE /api/v1/children/{child_id}
  Future<void> deleteChild(String childId) async {
    try {
      _validateParam(childId, 'childId');

      await _retryRequest(() => _dio.delete('/children/$childId'));

      LoggerService.info('Child deleted: $childId');
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to delete child: $childId', error: e);
      throw ApiException(
        'Failed to delete child: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  // ========================================================
  // 進捗・レポート
  // ========================================================

  /// GET /api/v1/progress/{child_id}
  Future<List<Progress>> fetchProgress(String childId) async {
    try {
      _validateParam(childId, 'childId');

      final response = await _retryRequest(
        () => _dio.get('/progress/$childId'),
      );

      final data = response.data;
      if (data is! List) {
        throw ApiException('Expected progress to be a list');
      }

      LoggerService.info('Progress fetched for child: $childId (${data.length})');
      return data.map((item) => Progress.fromJson(item)).toList();
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to fetch progress for child: $childId', error: e);
      throw ApiException(
        'Failed to fetch progress: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// GET /api/v1/reports/{child_id}/monthly
  Future<MonthlyReport?> fetchMonthlyReport({
    required String childId,
    required int year,
    required int month,
  }) async {
    try {
      _validateParam(childId, 'childId');

      final response = await _retryRequest(
        () => _dio.get(
          '/reports/$childId/monthly',
          queryParameters: {'year': year, 'month': month},
        ),
      );

      if (response.statusCode == 204 || response.data == null) return null;

      LoggerService.info('Monthly report fetched for child: $childId ($year-$month)');
      return MonthlyReport.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        LoggerService.info('Monthly report not found for child: $childId ($year-$month)');
        return null;
      }
      LoggerService.error('Failed to fetch monthly report for child: $childId', error: e);
      throw ApiException(
        'Failed to fetch monthly report: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// POST /api/v1/reports/{child_id}/monthly/generate
  Future<MonthlyReport> generateMonthlyReport({
    required String childId,
    required int year,
    required int month,
  }) async {
    try {
      _validateParam(childId, 'childId');

      final response = await _retryRequest(
        () => _dio.post(
          '/reports/$childId/monthly/generate',
          queryParameters: {'year': year, 'month': month},
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for generated monthly report');
      }

      LoggerService.info('Monthly report generated for child: $childId ($year-$month)');
      return MonthlyReport.fromJson(response.data);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to generate monthly report for child: $childId', error: e);
      throw ApiException(
        'Failed to generate monthly report: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  // ========================================================
  // クイズセッション
  // ========================================================

  /// POST /api/v1/quizzes
  Future<Map<String, dynamic>> startQuizSession({
    required String childId,
    required String storyId,
  }) async {
    try {
      _validateParam(childId, 'childId');
      _validateParam(storyId, 'storyId');

      final response = await _retryRequest(
        () => _dio.post(
          '/quizzes',
          data: {'childId': childId, 'storyId': storyId},
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for quiz session start');
      }

      LoggerService.info('Quiz session started for child: $childId, story: $storyId');
      return response.data as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to start quiz session', error: e);
      throw ApiException(
        'Failed to start quiz session: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  /// POST /api/v1/quizzes/{session_id}/complete
  Future<Map<String, dynamic>> completeQuizSession({
    required String sessionId,
    required String chosenChoiceId,
    required int timeSpentSeconds,
    String? reflectionText,
  }) async {
    try {
      _validateParam(sessionId, 'sessionId');
      _validateParam(chosenChoiceId, 'chosenChoiceId');

      final response = await _retryRequest(
        () => _dio.post(
          '/quizzes/$sessionId/complete',
          data: {
            'chosenChoiceId': chosenChoiceId,
            'timeSpentSeconds': timeSpentSeconds,
            'reflectionText': ?reflectionText,
          },
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for quiz completion');
      }

      LoggerService.info('Quiz session completed: $sessionId');
      return response.data as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to complete quiz session: $sessionId', error: e);
      throw ApiException(
        'Failed to complete quiz session: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }

  // ========================================================
  // ユーザー
  // ========================================================

  /// PUT /api/v1/users/me
  Future<Map<String, dynamic>> updateUser({String? name, String? fcmToken}) async {
    try {
      final response = await _retryRequest(
        () => _dio.put(
          '/users/me',
          data: {
            'name': ?name,
            'fcmToken': ?fcmToken,
          },
        ),
      );

      if (!_isValidResponse(response.data)) {
        throw ApiException('Invalid response structure for update user');
      }

      LoggerService.info('User updated');
      return response.data as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      LoggerService.error('Failed to update user', error: e);
      throw ApiException(
        'Failed to update user: ${e.message}',
        statusCode: e.response?.statusCode,
        originalError: e,
      );
    }
  }
}
