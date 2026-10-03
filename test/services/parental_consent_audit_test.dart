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
}
