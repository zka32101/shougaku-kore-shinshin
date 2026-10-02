import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/models/ranking.dart';
import 'package:shougaku_kore_doutoku/providers/ranking_provider.dart';

void main() {
  group('Ranking Providers', () {
    test('RankingTypeParams equality based on type and limit', () {
      final params1 = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 10,
      );

      final params2 = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 10,
      );

      final params3 = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 20, // Different limit
      );

      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('RankingTypeParams with different ranking types are not equal', () {
      final params1 = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 10,
      );

      final params2 = RankingTypeParams(
        type: RankingType.monthlyPoints,
        limit: 10,
      );

      expect(params1, isNot(equals(params2)));
    });

    test('UpdateRankingSettingsParams equality', () {
      final params1 = UpdateRankingSettingsParams(
        isNamePublic: true,
        participateInRanking: true,
      );

      final params2 = UpdateRankingSettingsParams(
        isNamePublic: true,
        participateInRanking: true,
      );

      expect(params1, equals(params2));
    });

    test('UpdateRankingSettingsParams with different settings are not equal', () {
      final params1 = UpdateRankingSettingsParams(
        isNamePublic: true,
        participateInRanking: true,
      );

      final params2 = UpdateRankingSettingsParams(
        isNamePublic: false, // Different
        participateInRanking: true,
      );

      expect(params1, isNot(equals(params2)));
    });

    test('RankingTypeParams hashCode is consistent', () {
      final params1 = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 10,
      );

      final params2 = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 10,
      );

      expect(params1.hashCode, equals(params2.hashCode));
    });

    test('RankingTypeParams toString for debugging', () {
      final params = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 10,
      );

      final str = params.toString();
      expect(str, contains('RankingTypeParams'));
      expect(str, contains('RankingType'));
    });
  });

  group('Ranking Provider Combinations', () {
    test('Multiple ranking types can be queried simultaneously', () {
      final types = [
        RankingTypeParams(type: RankingType.totalPoints, limit: 10),
        RankingTypeParams(type: RankingType.monthlyPoints, limit: 10),
        RankingTypeParams(type: RankingType.virtueCompassion, limit: 10),
      ];

      expect(types.length, equals(3));
      expect(types[0].type, equals(RankingType.totalPoints));
      expect(types[1].type, equals(RankingType.monthlyPoints));
      expect(types[2].type, equals(RankingType.virtueCompassion));
    });

    test('Ranking settings can be updated independently', () {
      final initial = UpdateRankingSettingsParams(
        isNamePublic: false,
        participateInRanking: true,
      );

      // Simulate toggling name disclosure
      final updated = UpdateRankingSettingsParams(
        isNamePublic: !initial.isNamePublic,
        participateInRanking: initial.participateInRanking,
      );

      expect(initial.isNamePublic, isFalse);
      expect(updated.isNamePublic, isTrue);
      expect(updated.participateInRanking, equals(initial.participateInRanking));
    });

    test('Different settings combinations are not equal', () {
      final publicParticipating = UpdateRankingSettingsParams(
        isNamePublic: true,
        participateInRanking: true,
      );

      final privateOptedOut = UpdateRankingSettingsParams(
        isNamePublic: false,
        participateInRanking: false,
      );

      expect(publicParticipating, isNot(equals(privateOptedOut)));
      expect(
        publicParticipating.isNamePublic,
        isNot(equals(privateOptedOut.isNamePublic)),
      );
      expect(
        publicParticipating.participateInRanking,
        isNot(equals(privateOptedOut.participateInRanking)),
      );
    });
  });

  group('Ranking Provider Parameter Validation', () {
    test('RankingTypeParams requires valid ranking type', () {
      expect(
        () => RankingTypeParams(
          type: RankingType.totalPoints,
          limit: 10,
        ),
        returnsNormally,
      );
    });

    test('RankingTypeParams with zero limit is valid', () {
      final params = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 0,
      );

      expect(params.limit, equals(0));
    });

    test('RankingTypeParams with large limit is valid', () {
      final params = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 10000,
      );

      expect(params.limit, equals(10000));
    });

    test('UpdateRankingSettingsParams allows opting out while name is public', () {
      final params = UpdateRankingSettingsParams(
        isNamePublic: true,
        participateInRanking: false,
      );

      expect(params.isNamePublic, isTrue);
      expect(params.participateInRanking, isFalse);
    });
  });

  group('Ranking Types Provider Usage', () {
    test('All 8 ranking types can be used in params', () {
      final types = [
        RankingType.totalPoints,
        RankingType.monthlyPoints,
        RankingType.virtueCompassion,
        RankingType.virtueHonesty,
        RankingType.virtueResponsibility,
        RankingType.virtueCourage,
        RankingType.virtueRespect,
        RankingType.virtueCooperation,
      ];

      for (final type in types) {
        final params = RankingTypeParams(type: type, limit: 10);
        expect(params.type, equals(type));
      }
    });

    test('Querying rankings for different types with same limit', () {
      final scoreRanking = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 100,
      );

      final virtueRanking = RankingTypeParams(
        type: RankingType.virtueCompassion,
        limit: 100,
      );

      expect(scoreRanking.limit, equals(virtueRanking.limit));
      expect(scoreRanking.type, isNot(equals(virtueRanking.type)));
    });

    test('Different limits for different ranking queries', () {
      final top10 = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 10,
      );

      final top100 = RankingTypeParams(
        type: RankingType.totalPoints,
        limit: 100,
      );

      expect(top10.limit, isNot(equals(top100.limit)));
      expect(top10.type, equals(top100.type));
    });
  });
}
