import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobile/models/domain.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/state/farm_state.dart';
import 'package:mobile/ui/app.dart';

void main() {
  testWidgets('opens directly into the sign-in screen', (tester) async {
    await tester.pumpWidget(const GauRakshakApp());
    await tester.pump();
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

  test('CSV lookup uses the latest reading and updates the herd state', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/cows/sample-data');
      return http.Response('[{"cow_id":"COW_0002","breed":"Jersey Cross","age_years":9,"milk_yield_liters":11.2,"risk_category":"No Risk","risk_probability":0.12,"recorded_date":"28-06-2026","recorded_time":"06:00","reading_session":"Morning","milk_conductivity_ms_cm":4.11},{"cow_id":"COW_0002","breed":"Jersey Cross","age_years":9,"milk_yield_liters":15.85,"risk_category":"No Risk","risk_probability":0.18,"recorded_date":"29-06-2026","recorded_time":"18:00","reading_session":"Evening","milk_conductivity_ms_cm":4.18}]', 200);
    });
    final state = FarmState(apiService: ApiService(client: client));

    final cow = await state.findCowFromCsv('cow-0002');

    expect(cow, isNotNull);
    expect(cow!.todayMilkLitres, 15.85);
    expect(cow.riskScore, 18);
    expect(cow.timeline.first, contains('29-06-2026'));
    expect(state.cowByTag('COW_0002'), same(cow));
    expect(state.sampleData, hasLength(2));
  });

  test('simulated session derives a high risk result and alert from readings', () async {
    final state = FarmState();
    final cow = state.cowByTag('COW-024')!;

    state.startDemoSession(cow);
    expect(await state.recordSessionReading(cow), isTrue);
    await state.completeSessionPrediction(cow);

    expect(state.latestPrediction?.risk, RiskLevel.attention);
    expect(state.latestPrediction?.riskScore, greaterThan(65));
    expect(cow.factors, isNotEmpty);
    expect(state.alerts.any((alert) => alert.cowTag == cow.tag), isTrue);
  });
}
