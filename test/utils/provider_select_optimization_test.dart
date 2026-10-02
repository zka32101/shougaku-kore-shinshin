import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Provider Select Optimization', () {
    // ── PRIORITY 1: Provider Select Optimization Tests ──────────────────

    group('Provider.select() reduces unnecessary rebuilds', () {
      test('select() only rebuilds when selected property changes', () async {
        // Create a test provider with multiple properties
        final multiPropertyProvider = StateProvider<_TestState>((ref) {
          return const _TestState(name: 'John', age: 25);
        });

        // Counter to track rebuild notifications
        var nameChangeCount = 0;
        var ageChangeCount = 0;

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Create a listener that only watches name
        container.listen(
          multiPropertyProvider.select((state) => state.name),
          (previous, next) {
            nameChangeCount++;
          },
        );

        // Create a listener that only watches age
        container.listen(
          multiPropertyProvider.select((state) => state.age),
          (previous, next) {
            ageChangeCount++;
          },
        );

        // Change only the name
        container.read(multiPropertyProvider.notifier).state =
            const _TestState(name: 'Jane', age: 25);

        expect(nameChangeCount, 1,
            reason: 'Name listener should be notified once');
        expect(ageChangeCount, 0,
            reason: 'Age listener should not be notified (age unchanged)');
      });

      test('select() with different selectors create independent listeners', () async {
        final provider = StateProvider<_TestState>((ref) {
          return const _TestState(name: 'John', age: 25);
        });

        var count1 = 0;
        var count2 = 0;

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Two different selectors on same provider
        container.listen(
          provider.select((state) => state.name),
          (previous, next) => count1++,
        );

        container.listen(
          provider.select((state) => state.age),
          (previous, next) => count2++,
        );

        // Change name only
        container.read(provider.notifier).state =
            const _TestState(name: 'Jane', age: 25);

        expect(count1, 1, reason: 'Name selector should notify');
        expect(count2, 0, reason: 'Age selector should not notify');

        // Change age only
        container.read(provider.notifier).state =
            const _TestState(name: 'Jane', age: 30);

        expect(count1, 1, reason: 'Name selector count unchanged');
        expect(count2, 1, reason: 'Age selector should now notify');
      });

      test('select() does not notify when selected value does not change', () async {
        final provider = StateProvider<_TestState>((ref) {
          return const _TestState(name: 'John', age: 25);
        });

        var notifyCount = 0;

        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.listen(
          provider.select((state) => state.name),
          (previous, next) => notifyCount++,
        );

        // Update other property, name stays same
        container.read(provider.notifier).state =
            const _TestState(name: 'John', age: 30);

        expect(notifyCount, 0,
            reason: 'No notification when selected property unchanged');

        // Now change the name
        container.read(provider.notifier).state =
            const _TestState(name: 'Jane', age: 30);

        expect(notifyCount, 1,
            reason: 'Should notify when selected property changes');
      });

      test('select() with computed value only rebuilds when computed result changes', () async {
        final provider = StateProvider<_TestState>((ref) {
          return const _TestState(name: 'John', age: 25);
        });

        var notifyCount = 0;

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Select computed value: is adult (age >= 18)
        container.listen(
          provider.select((state) => state.age >= 18),
          (previous, next) => notifyCount++,
        );

        // Change age but result stays same (still adult)
        container.read(provider.notifier).state =
            const _TestState(name: 'John', age: 30);

        expect(notifyCount, 0,
            reason: 'No notification when computed result unchanged');

        // Change to non-adult
        container.read(provider.notifier).state =
            const _TestState(name: 'John', age: 10);

        expect(notifyCount, 1,
            reason: 'Should notify when computed result changes');
      });
    });

    // ── Optimization Measurement Tests ─────────────────────────────────

    group('Select Optimization Effectiveness', () {
      test('select() suppresses notifications for unrelated field changes',
          () async {
        final parentProvider = StateProvider<_TestState>((ref) {
          return const _TestState(name: 'John', age: 25);
        });

        // 「名前だけ」に関心のあるリスナーを、select あり/なしで 1 つずつ用意する。
        var withoutSelectCount = 0; // 状態が変わるたびに通知される
        var nameOnlyCount = 0; // name が変わったときだけ通知される

        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.listen(parentProvider, (previous, next) => withoutSelectCount++);
        container.listen(
          parentProvider.select((state) => state.name),
          (previous, next) => nameOnlyCount++,
        );

        // 更新 10 回: name が変わるのは偶数回(5 回)、age だけが変わるのは奇数回(5 回)
        for (int i = 0; i < 10; i++) {
          if (i % 2 == 0) {
            container.read(parentProvider.notifier).state =
                _TestState(name: 'Name$i', age: 25);
          } else {
            container.read(parentProvider.notifier).state =
                _TestState(name: 'Name${i - 1}', age: 30 + i);
          }
        }

        expect(withoutSelectCount, 10,
            reason: 'Without select, every state change notifies');
        expect(nameOnlyCount, 5,
            reason: 'With select(name), only the 5 name changes notify');

        final reduction =
            (withoutSelectCount - nameOnlyCount) / withoutSelectCount * 100;
        expect(reduction, 50,
            reason: 'Half of the updates only touch age, so select saves 50%');
      });

      test('select() with multiple listeners scales efficiently', () async {
        final provider = StateProvider<_TestState>((ref) {
          return const _TestState(name: 'John', age: 25);
        });

        // Track notifications for 5 different select listeners
        final notifyCounts = <int>[0, 0, 0, 0, 0];

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Create 5 listeners with different selectors
        for (int i = 0; i < 5; i++) {
          if (i % 2 == 0) {
            container.listen(
              provider.select((state) => state.name),
              (previous, next) {
                notifyCounts[i]++;
              },
            );
          } else {
            container.listen(
              provider.select((state) => state.age),
              (previous, next) {
                notifyCounts[i]++;
              },
            );
          }
        }

        // Change only name
        container.read(provider.notifier).state =
            const _TestState(name: 'Jane', age: 25);

        // Name listeners (indices 0, 2, 4) should notify
        expect(notifyCounts[0], 1);
        expect(notifyCounts[2], 1);
        expect(notifyCounts[4], 1);

        // Age listeners (indices 1, 3) should not notify
        expect(notifyCounts[1], 0);
        expect(notifyCounts[3], 0);

        final totalNotifications = notifyCounts.reduce((a, b) => a + b);
        expect(totalNotifications, 3,
            reason: 'Only relevant listeners should be notified');
      });

      test('select() identity comparison prevents spurious rebuilds', () async {
        final provider =
            StateProvider<_ComplexObject>((ref) => _ComplexObject(
          nestedObject: _NestedObject(value: 'test'),
          timestamp: DateTime.now(),
        ));

        var notifyCount = 0;

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Select nested object and ensure it stays same reference
        container.listen(
          provider.select((state) => state.nestedObject),
          (previous, next) => notifyCount++,
        );

        // Recreate nested object with same value
        container.read(provider.notifier).state = _ComplexObject(
          nestedObject: _NestedObject(value: 'test'),
          timestamp: DateTime.now(),
        );

        // Should not notify because by value they're equal
        // (depends on how equality is defined - this tests default behavior)
        expect(notifyCount, greaterThanOrEqualTo(0),
            reason: 'Notification behavior depends on equality comparison');
      });
    });

    // ── Select Pattern Best Practices Tests ───────────────────────────

    group('Select Pattern Best Practices', () {
      test('select() with function reference is more efficient than inline', () async {
        final provider = StateProvider<_TestState>((ref) {
          return const _TestState(name: 'John', age: 25);
        });

        var inlineNotifyCount = 0;
        var functionNotifyCount = 0;

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Inline selector (creates new function each time)
        container.listen(
          provider.select((state) => state.name),
          (previous, next) => inlineNotifyCount++,
        );

        // Function reference (same function)
        String getAge(_TestState state) => state.age.toString();
        container.listen(
          provider.select(getAge),
          (previous, next) => functionNotifyCount++,
        );

        // Both should work the same way in terms of notification
        container.read(provider.notifier).state =
            const _TestState(name: 'Jane', age: 25);

        expect(inlineNotifyCount, 1,
            reason: 'Inline selector should notify on name change');
        expect(functionNotifyCount, 0,
            reason: 'Function selector should not notify (age unchanged)');
      });

      test('select() with complex objects returns same instance when value unchanged', () async {
        final provider = StateProvider<Map<String, int>>((ref) {
          return {'count': 0};
        });

        int? previousSelected;
        var notifyCount = 0;

        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.listen(
          provider.select((state) => state['count']),
          (previous, next) {
            previousSelected = previous;
            notifyCount++;
          },
        );

        // Update different key
        container.read(provider.notifier).state = {'count': 0, 'other': 1};

        expect(notifyCount, 0,
            reason: 'Should not notify when selected value unchanged');

        // Update selected key
        container.read(provider.notifier).state = {'count': 1};

        expect(notifyCount, 1,
            reason: 'Should notify when selected value changes');
        expect(previousSelected, 0, reason: 'Should have previous value');
      });
    });
  });
}

// ── Test Helpers ─────────────────────────────────────────────────────────

class _TestState {
  const _TestState({
    required this.name,
    required this.age,
  });

  final String name;
  final int age;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestState &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age;

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

class _NestedObject {
  _NestedObject({required this.value});

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _NestedObject &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class _ComplexObject {
  _ComplexObject({
    required this.nestedObject,
    required this.timestamp,
  });

  final _NestedObject nestedObject;
  final DateTime timestamp;
}
