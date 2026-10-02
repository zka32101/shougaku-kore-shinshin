import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/models/ranking.dart';

/// ランキングのモデル（RankingEntry / RankingSettings / RankingType /
/// RankingStats）の単体テスト。RankingService 本体は FirebaseFirestore /
/// FirebaseAuth の実インスタンスを直接使うため、ここでは扱わない。

RankingEntry _entry({
  String childId = 'child1',
  String childName = '太郎',
  int score = 100,
  int rank = 1,
  bool isNamePublic = false,
  DateTime? updatedAt,
}) {
  return RankingEntry(
    childId: childId,
    childName: childName,
    avatarEmoji: '🦊',
    totalGrowthScore: score,
    totalAnswers: 10,
    rank: rank,
    updatedAt: updatedAt ?? DateTime(2024, 1, 1),
    isNamePublic: isNamePublic,
  );
}

RankingSettings _settings({
  String userId = 'user1',
  bool isNamePublic = false,
  bool participateInRanking = true,
}) {
  return RankingSettings(
    userId: userId,
    isNamePublic: isNamePublic,
    participateInRanking: participateInRanking,
    updatedAt: DateTime(2024, 1, 1),
  );
}

void main() {
  group('RankingEntry', () {
    test('getDisplayName returns generic name when isNamePublic is false', () {
      expect(_entry(isNamePublic: false).getDisplayName(), equals('ユーザー'));
    });

    test('getDisplayName returns actual name when isNamePublic is true', () {
      expect(_entry(isNamePublic: true).getDisplayName(), equals('太郎'));
    });

    test('score is an alias of totalGrowthScore', () {
      expect(_entry(score: 250).score, equals(250));
    });

    test('JSON serialization round-trip', () {
      final entry = _entry(isNamePublic: true);

      final restored = RankingEntry.fromJson(entry.toJson());

      expect(restored.childId, equals(entry.childId));
      expect(restored.childName, equals(entry.childName));
      expect(restored.avatarEmoji, equals(entry.avatarEmoji));
      expect(restored.totalGrowthScore, equals(entry.totalGrowthScore));
      expect(restored.totalAnswers, equals(entry.totalAnswers));
      expect(restored.rank, equals(entry.rank));
      expect(restored.isNamePublic, equals(entry.isNamePublic));
    });
  });

  group('RankingSettings', () {
    test('settings keep the given flags', () {
      final settings = _settings();

      expect(settings.isNamePublic, isFalse);
      expect(settings.participateInRanking, isTrue);
    });

    test('settings can be toggled', () {
      final settings = _settings();

      settings.isNamePublic = !settings.isNamePublic;

      expect(settings.isNamePublic, isTrue);
    });

    test('JSON serialization round-trip', () {
      final settings = _settings(isNamePublic: true, participateInRanking: false);

      final restored = RankingSettings.fromJson(settings.toJson());

      expect(restored.userId, equals(settings.userId));
      expect(restored.isNamePublic, equals(settings.isNamePublic));
      expect(
        restored.participateInRanking,
        equals(settings.participateInRanking),
      );
    });
  });

  group('RankingType', () {
    test('all 8 ranking types are defined', () {
      expect(RankingType.values.length, equals(8));
    });

    test('ranking types have correct names', () {
      expect(RankingType.totalPoints.name, equals('totalPoints'));
      expect(RankingType.monthlyPoints.name, equals('monthlyPoints'));
      expect(RankingType.virtueCompassion.name, equals('virtueCompassion'));
    });
  });

  group('RankingStats', () {
    RankingStats stats0({Map<String, int>? virtues}) => RankingStats(
          userId: 'user1',
          totalPointsRank: 10,
          monthlyPointsRank: 5,
          totalScore: 500,
          monthlyScore: 100,
          virtueScores: virtues ??
              const {
                'compassion': 80,
                'honesty': 75,
                'responsibility': 85,
                'courage': 70,
                'respect': 80,
                'cooperation': 75,
              },
          updatedAt: DateTime(2024, 1, 1),
        );

    test('initializes with all fields', () {
      final stats = stats0();

      expect(stats.totalPointsRank, equals(10));
      expect(stats.monthlyPointsRank, equals(5));
      expect(stats.totalScore, equals(500));
      expect(stats.monthlyScore, equals(100));
      expect(stats.virtueScores.length, equals(6));
    });

    test('JSON serialization round-trip', () {
      final stats = stats0(virtues: {'compassion': 80});

      final restored = RankingStats.fromJson(stats.toJson());

      expect(restored.userId, equals(stats.userId));
      expect(restored.totalPointsRank, equals(stats.totalPointsRank));
      expect(restored.monthlyPointsRank, equals(stats.monthlyPointsRank));
      expect(restored.totalScore, equals(stats.totalScore));
      expect(restored.monthlyScore, equals(stats.monthlyScore));
      expect(restored.virtueScores, equals(stats.virtueScores));
    });
  });

  group('Privacy features', () {
    test('privacy is default OFF in the default RankingSettings', () {
      final settings = RankingSettings(
        userId: 'user1',
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(settings.isNamePublic, isFalse);
      expect(settings.participateInRanking, isTrue);
    });

    test('multiple users can have different privacy settings', () {
      final user1 = _settings(userId: 'user1', isNamePublic: true);
      final user2 = _settings(userId: 'user2', isNamePublic: false);

      expect(user1.isNamePublic, isTrue);
      expect(user2.isNamePublic, isFalse);
    });

    test('privacy setting does not affect ranking participation', () {
      final settings = _settings(isNamePublic: false);

      expect(settings.participateInRanking, isTrue);
    });
  });

  group('Display logic', () {
    test('getDisplayName() respects privacy setting', () {
      final publicEntry = _entry(childName: '太郎', isNamePublic: true);
      final privateEntry = _entry(childName: '花子', isNamePublic: false);

      expect(publicEntry.getDisplayName(), equals('太郎'));
      expect(privateEntry.getDisplayName(), equals('ユーザー'));
    });

    test('privacy does not hide the rank', () {
      expect(_entry(rank: 5, isNamePublic: false).rank, equals(5));
    });
  });
}
