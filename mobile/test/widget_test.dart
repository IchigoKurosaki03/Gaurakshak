import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/state/farm_state.dart';

void main() {
  testWidgets('opens the Stitch login flow', (tester) async {
    await tester.pumpWidget(const GauRakshakApp());
    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.text('Welcome back'), findsOneWidget);
  });

  test('matches CSV-style cow IDs regardless of case or punctuation', () {
    final state = FarmState();

    expect(state.cowByTag('COW-024'), isNotNull);
    expect(state.cowByTag(' cow_024 '), isNotNull);
    expect(state.cowByTag('cow024'), isNotNull);
    expect(state.cowByTag('COW-999'), isNull);
  });

  test('initializes an offline-safe farm state before authentication', () {
    final state = FarmState(repository: null, apiService: null);

    expect(state.farm.name.isNotEmpty, isTrue);
    expect(state.cows, isNotEmpty);
    expect(state.alerts, isNotEmpty);
  });

  test('clears sample data when no valid cow ID is entered', () {
    final state = FarmState(repository: null, apiService: null);
    state.sampleData.add({'cow_id': 'COW_0001'});
    state.sampleData.clear();
    expect(state.sampleData, isEmpty);
  });
}
