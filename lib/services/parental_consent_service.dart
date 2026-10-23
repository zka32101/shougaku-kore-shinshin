import 'package:flutter/foundation.dart' show debugPrint;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// パパイエントの同意情報を管理するサービス
/// Manages parental consent for COPPA compliance
class ParentalConsentService {
  final FirebaseFirestore _firestore;

  ParentalConsentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 親の同意情報を作成または更新
  /// Creates or updates parental consent record
  Future<void> saveParentalConsent({
    required String parentUserId,
    required String childName,
    required String parentEmail,
    required bool consentedToTerms,
    required bool consentedToPrivacy,
    required bool consentedToAnalytics,
  }) async {
    try {
      final now = FieldValue.serverTimestamp();

      final consentData = {
        'parentUserId': parentUserId,
        'childName': childName,
        'parentEmail': parentEmail,
        'consentedToTerms': consentedToTerms,
        'consentedToPrivacy': consentedToPrivacy,
        'consentedToAnalytics': consentedToAnalytics,
        'consentedAt': now,
        'updatedAt': now,
        'userAgent': 'flutter_app',
      };

      await _firestore
          .collection('parental_consent')
          .doc(parentUserId)
          .set(consentData, SetOptions(merge: true));

      await _logConsentAction(parentUserId, 'given', {
        'consentedToTerms': consentedToTerms,
        'consentedToPrivacy': consentedToPrivacy,
        'consentedToAnalytics': consentedToAnalytics,
      });
    } catch (e) {
      throw Exception('Failed to save parental consent: $e');
    }
  }

  /// 親の同意情報を取得
  /// Retrieves parental consent record
  Future<ParentalConsentRecord?> getParentalConsent(
      String parentUserId) async {
    try {
      final doc = await _firestore
          .collection('parental_consent')
          .doc(parentUserId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return ParentalConsentRecord.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get parental consent: $e');
    }
  }

  /// 同意情報が存在するか確認
  /// Checks if consent has been given
  Future<bool> hasConsentGiven(String parentUserId) async {
    try {
      final consent = await getParentalConsent(parentUserId);
      return consent != null &&
          consent.consentedToTerms &&
          consent.consentedToPrivacy;
    } catch (e) {
      return false;
    }
  }

  /// 同意を撤回
  /// Revokes parental consent (user data deletion)
  Future<void> revokeConsent(String parentUserId) async {
    try {
      // Mark consent as revoked
      await _firestore
          .collection('parental_consent')
          .doc(parentUserId)
          .update({
        'consentedToTerms': false,
        'consentedToPrivacy': false,
        'consentedToAnalytics': false,
        'revokedAt': FieldValue.serverTimestamp(),
        // 個人情報の最小化: 撤回後は氏名・メールを保持しない
        'childName': FieldValue.delete(),
        'parentEmail': FieldValue.delete(),
      });

      await _logConsentAction(parentUserId, 'revoked', {});

      await deleteUserData(parentUserId);
    } catch (e) {
      throw Exception('Failed to revoke consent: $e');
    }
  }

  /// users/{uid} 配下のサブコレクション（クライアントからは列挙できないため明示）
  static const _userSubcollections = [
    'children',
    'selections',
    'prefs',
    'settings',
    'subscription',
    'progress',
    'data',
    'compositions',
    'avatar_purchases',
  ];

  /// children/{childId} 配下のサブコレクション
  static const _childSubcollections = ['stats', 'questHistory'];

  /// ランキングのコレクションパス（RankingService と同一）
  static const _rankingCollections = [
    'rankings/global/total_points',
    'rankings/global/monthly_points',
    'rankings/virtues/compassion',
    'rankings/virtues/honesty',
    'rankings/virtues/responsibility',
    'rankings/virtues/courage',
    'rankings/virtues/respect',
    'rankings/virtues/cooperation',
  ];

  /// 親ユーザーと子どもに紐づく全データを削除（COPPA: 同意撤回時）
  /// 同意記録本体と監査ログは法的証跡として残す（個人情報は含まない）。
  /// 冪等なので、途中で失敗しても再実行できる。
  Future<void> deleteUserData(String parentUserId) async {
    final userRef = _firestore.collection('users').doc(parentUserId);

    // 子どもIDを収集
    final childIds = <String>{};
    final profiles = await _firestore
        .collection('child_profiles')
        .where('parentId', isEqualTo: parentUserId)
        .get();
    childIds.addAll(profiles.docs.map((d) => d.id));
    final children = await userRef.collection('children').get();
    childIds.addAll(children.docs.map((d) => d.id));

    for (final childId in childIds) {
      for (final path in _rankingCollections) {
        await _deleteWhere(
            _firestore.collection(path).where('childId', isEqualTo: childId));
      }
      await _deleteWhere(_firestore
          .collection('quiz_sessions')
          .where('childId', isEqualTo: childId));
      for (final sub in _childSubcollections) {
        await _deleteWhere(
            userRef.collection('children').doc(childId).collection(sub));
      }
    }

    await _deleteWhere(_firestore
        .collection('child_profiles')
        .where('parentId', isEqualTo: parentUserId));

    for (final sub in _userSubcollections) {
      await _deleteWhere(userRef.collection(sub));
    }
    await userRef.delete();
  }

  /// クエリに一致するドキュメントを分割バッチで削除
  Future<void> _deleteWhere(Query<Map<String, dynamic>> query) async {
    const batchSize = 400;
    while (true) {
      final snap = await query.limit(batchSize).get();
      if (snap.docs.isEmpty) return;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < batchSize) return;
    }
  }

  /// 同意の履歴を取得（監査用）
  /// Gets consent history for audit purposes
  Future<List<ConsentAuditLog>> getConsentAuditLog(
      String parentUserId) async {
    try {
      final snapshot = await _firestore
          .collection('parental_consent_audit')
          .where('parentUserId', isEqualTo: parentUserId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ConsentAuditLog.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get consent audit log: $e');
    }
  }

  /// 同意記録を監査ログに追加
  /// Adds entry to audit log
  ///
  /// 個人情報を増やさないため、IP等は記録しない（誰が・いつ・何に同意/撤回したかのみ）。
  Future<void> _logConsentAction(
    String parentUserId,
    String action,
    Map<String, dynamic> details,
  ) async {
    try {
      await _firestore.collection('parental_consent_audit').add({
        'parentUserId': parentUserId,
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log silently - audit logging should not break main flow
      debugPrint('Failed to log consent action: $e');
    }
  }
}

/// 親の同意情報モデル
/// Parental consent data model
class ParentalConsentRecord {
  final String parentUserId;
  final String childName;
  final String parentEmail;
  final bool consentedToTerms;
  final bool consentedToPrivacy;
  final bool consentedToAnalytics;
  final DateTime consentedAt;
  final DateTime updatedAt;
  final String? ipAddress;
  final bool? revoked;

  ParentalConsentRecord({
    required this.parentUserId,
    required this.childName,
    required this.parentEmail,
    required this.consentedToTerms,
    required this.consentedToPrivacy,
    required this.consentedToAnalytics,
    required this.consentedAt,
    required this.updatedAt,
    this.ipAddress,
    this.revoked = false,
  });

  /// JSONからモデルを作成
  factory ParentalConsentRecord.fromJson(Map<String, dynamic> json) {
    return ParentalConsentRecord(
      parentUserId: json['parentUserId'] as String,
      childName: json['childName'] as String? ?? '',
      parentEmail: json['parentEmail'] as String? ?? '',
      consentedToTerms: json['consentedToTerms'] as bool? ?? false,
      consentedToPrivacy: json['consentedToPrivacy'] as bool? ?? false,
      consentedToAnalytics: json['consentedToAnalytics'] as bool? ?? false,
      consentedAt: (json['consentedAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      ipAddress: json['ipAddress'] as String?,
      revoked: json['revoked'] as bool? ?? false,
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() => {
        'parentUserId': parentUserId,
        'childName': childName,
        'parentEmail': parentEmail,
        'consentedToTerms': consentedToTerms,
        'consentedToPrivacy': consentedToPrivacy,
        'consentedToAnalytics': consentedToAnalytics,
        'consentedAt': consentedAt,
        'updatedAt': updatedAt,
        'ipAddress': ipAddress,
        'revoked': revoked,
      };

  /// すべての同意が得られているか確認
  bool get allConsentsGiven =>
      consentedToTerms && consentedToPrivacy && consentedToAnalytics;
}

/// 同意監査ログエントリ
/// Audit log entry for consent actions
class ConsentAuditLog {
  final String parentUserId;
  final String action; // 'given', 'revoked'
  final Map<String, dynamic> details;
  final DateTime timestamp;

  ConsentAuditLog({
    required this.parentUserId,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  factory ConsentAuditLog.fromJson(Map<String, dynamic> json) {
    return ConsentAuditLog(
      parentUserId: json['parentUserId'] as String,
      action: json['action'] as String,
      details: json['details'] as Map<String, dynamic>? ?? {},
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}

/// Riverpod プロバイダー
/// Parental Consent Service Provider
final parentalConsentServiceProvider = Provider<ParentalConsentService>((ref) {
  return ParentalConsentService();
});

/// ユーザーの同意状態をリッスン
/// Listens to parental consent state
final userConsentProvider = StreamProvider.family<ParentalConsentRecord?, String>(
  (ref, parentUserId) {
    final service = ref.watch(parentalConsentServiceProvider);
    return Stream.periodic(
      const Duration(minutes: 5), // Poll every 5 minutes
      (_) => service.getParentalConsent(parentUserId),
    ).asyncExpand((future) => future.asStream());
  },
);

/// 同意チェック
/// Consent verification
final isConsentGivenProvider = FutureProvider.family<bool, String>(
  (ref, parentUserId) async {
    final service = ref.watch(parentalConsentServiceProvider);
    return service.hasConsentGiven(parentUserId);
  },
);
