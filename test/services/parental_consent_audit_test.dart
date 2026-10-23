import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/services/parental_consent_service.dart';

void main() {
  late FakeFirebaseFirestore db;
  late ParentalConsentService service;

  setUp(() {
    db = FakeFirebaseFirestore();
    service = ParentalConsentService(firestore: db);
  });

  Future<List<Map<String, dynamic>>> audit() async =>
      (await db.collection('parental_consent_audit').get())
          .docs
          .map((d) => d.data())
          .toList();

  test('同意を保存すると given が監査ログに残り、IPは記録されない', () async {
    await service.saveParentalConsent(
      parentUserId: 'p1',
      childName: 'c',
      parentEmail: 'a@example.com',
      consentedToTerms: true,
      consentedToPrivacy: true,
      consentedToAnalytics: false,
    );
    final logs = await audit();
    expect(logs, hasLength(1));
    expect(logs.single['action'], 'given');
    expect(logs.single['parentUserId'], 'p1');
    expect(logs.single['details']['consentedToAnalytics'], false);
    expect(logs.single.containsKey('ipAddress'), isFalse);
  });

  test('撤回すると revoked が監査ログに残る', () async {
    await service.saveParentalConsent(
      parentUserId: 'p1',
      childName: 'c',
      parentEmail: 'a@example.com',
      consentedToTerms: true,
      consentedToPrivacy: true,
      consentedToAnalytics: true,
    );
    await service.revokeConsent('p1');
    final actions = (await audit()).map((l) => l['action']).toList();
    expect(actions, containsAll(['given', 'revoked']));
  });

  test('撤回すると本人と子どもの全データが削除され、他ユーザーは残る', () async {
    await service.saveParentalConsent(
      parentUserId: 'p1',
      childName: 'c',
      parentEmail: 'a@example.com',
      consentedToTerms: true,
      consentedToPrivacy: true,
      consentedToAnalytics: true,
    );
    final user = db.collection('users').doc('p1');
    await user.set({'role': 'parent'});
    await user.collection('children').doc('c1').set({'name': 'c'});
    await user
        .collection('children')
        .doc('c1')
        .collection('stats')
        .doc('learning')
        .set({'x': 1});
    await user.collection('compositions').doc('k1').set({'x': 1});
    await db.collection('child_profiles').doc('c1').set({'parentId': 'p1'});
    await db.collection('quiz_sessions').doc('q1').set({'childId': 'c1'});
    await db
        .collection('rankings/global/total_points')
        .doc('c1')
        .set({'childId': 'c1'});
    // 他ユーザーのデータ
    await db.collection('users').doc('p2').set({'role': 'parent'});
    await db.collection('child_profiles').doc('c2').set({'parentId': 'p2'});
    await db
        .collection('rankings/global/total_points')
        .doc('c2')
        .set({'childId': 'c2'});

    await service.revokeConsent('p1');

    expect((await user.get()).exists, isFalse);
    expect((await user.collection('children').get()).docs, isEmpty);
    expect((await user.collection('compositions').get()).docs, isEmpty);
    expect(
        (await user
                .collection('children')
                .doc('c1')
                .collection('stats')
                .get())
            .docs,
        isEmpty);
    expect((await db.collection('child_profiles').doc('c1').get()).exists,
        isFalse);
    expect((await db.collection('quiz_sessions').get()).docs, isEmpty);
    expect(
        (await db.collection('rankings/global/total_points').get())
            .docs
            .map((d) => d.id),
        ['c2']);
    expect((await db.collection('users').doc('p2').get()).exists, isTrue);
    expect((await db.collection('child_profiles').doc('c2').get()).exists,
        isTrue);

    // 同意記録は撤回済みとして残り、個人情報は消える
    final consent = (await db.collection('parental_consent').doc('p1').get())
        .data()!;
    expect(consent['consentedToPrivacy'], isFalse);
    expect(consent.containsKey('parentEmail'), isFalse);
    expect(consent.containsKey('childName'), isFalse);
  });
}
