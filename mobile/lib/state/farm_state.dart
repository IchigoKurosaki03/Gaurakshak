import 'package:flutter/foundation.dart';

import '../models/domain.dart';
import '../repositories/demo_farm_repository.dart';
import '../services/api_service.dart';

class FarmState extends ChangeNotifier {
  FarmState({DemoFarmRepository? repository, ApiService? apiService})
    : _repository = repository ?? DemoFarmRepository(),
      _apiService = apiService ?? ApiService() {
    _seedDemo();
  }

  final DemoFarmRepository _repository;
  final ApiService _apiService;
  late FarmProfile farm;
  final List<Cow> cows = [];
  final List<FarmAlert> alerts = [];
  final List<Map<String, dynamic>> sampleData = [];
  bool isOnline = true;
  bool useMarathi = false;
  bool isLoading = false;
  String? errorMessage;
  Cow? selectedCow;
  MilkingSession? currentSession;
  Prediction? latestPrediction;
  String? authToken;
  bool hasBackendFarm = false;

  void _seedDemo() {
    farm = _repository.initialFarm();
    cows
      ..clear()
      ..addAll(_repository.initialCows());
    alerts
      ..clear()
      ..addAll(_repository.initialAlerts());
  }

  static String normalizeTag(String value) {
    final compact = value.trim().toLowerCase();
    return compact.replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static int _toRisk(String? value) {
    final normalized = (value ?? '').trim().toLowerCase();
    if (normalized.contains('no risk') ||
        normalized.contains('healthy') ||
        normalized.contains('low')) {
      return RiskLevel.healthy.index;
    }
    if (normalized.contains('attention') ||
        normalized.contains('high') ||
        normalized.contains('risk')) {
      return RiskLevel.attention.index;
    }
    if (normalized.contains('monitor') || normalized.contains('medium')) {
      return RiskLevel.monitor.index;
    }
    if (normalized.contains('healthy') || normalized.contains('low')) {
      return RiskLevel.healthy.index;
    }
    return RiskLevel.healthy.index;
  }

  static String _extractAge(Object? value) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) return 'Unknown';
    return text;
  }

  static double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int count(RiskLevel level) => cows.where((cow) => cow.risk == level).length;
  double get totalMilk =>
      cows.fold(0, (total, cow) => total + cow.todayMilkLitres);
  List<MilkRecord> get milkTrend => _repository.herdMilkTrend();

  Cow? cowByTag(String tag) {
    final normalizedTag = normalizeTag(tag);
    if (normalizedTag.isEmpty) return null;

    for (final cow in cows) {
      final normalizedCowTag = normalizeTag(cow.tag);
      if (normalizedCowTag == normalizedTag) return cow;
    }
    return null;
  }

  Future<void> loginAndSync(String phone, String otp) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _apiService.post('/auth/login', body: {'phone': phone});
      final result = await _apiService.post(
        '/auth/verify-otp',
        body: {'phone': phone, 'otp': otp},
      );
      if (result is Map<String, dynamic>) {
        authToken = (result['access_token'] ?? '').toString();
        if (authToken != null && authToken!.isNotEmpty) {
          hasBackendFarm = result['farm_id'] != null;
          await loadBackendData(token: authToken!);
          return;
        }
      }
      errorMessage = 'Login succeeded but no token was returned.';
    } on ApiException catch (error) {
      errorMessage = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBackendData({String? token}) async {
    final resolvedToken = token ?? authToken;
    try {
      if (resolvedToken == null || resolvedToken.isEmpty) return;
      final response = await _apiService.get('/cows', token: resolvedToken);
      if (response is! List || response.isEmpty) return;

      final nextCows = <Cow>[];
      for (final raw in response) {
        if (raw is! Map<String, dynamic>) continue;
        final tag = (raw['tag_id'] ?? raw['tag'] ?? raw['cow_id'] ?? '')
            .toString();
        if (tag.isEmpty) continue;
        nextCows.add(
          Cow(
            backendId: (raw['id'] as num?)?.toInt(),
            name: (raw['name'] ?? 'Cow').toString(),
            tag: tag,
            breed: (raw['breed'] ?? 'Unknown').toString(),
            age: raw['age_years'] == null
                ? _extractAge(raw['date_of_birth'])
                : '${raw['age_years']} years',
            todayMilkLitres: _toDouble(raw['today_milk_litres']) ?? 0,
            risk: RiskLevel.values[_toRisk(raw['basic_health_status'])],
            trend: 'Synced from backend',
            factors: const [],
            timeline: [
              'Today: Synced from backend',
              if ((raw['date_of_birth'] ?? '').toString().isNotEmpty)
                'DOB: ${raw['date_of_birth']}',
            ],
          ),
        );
      }

      if (nextCows.isNotEmpty) {
        cows
          ..clear()
          ..addAll(nextCows);
        alerts.clear();
        farm = farm.copyWith(
          name: farm.name,
          location: farm.location,
          herdSize: nextCows.length,
        );
        selectedCow ??= nextCows.first;
      }

      final alertsResponse = await _apiService.get(
        '/alerts',
        token: resolvedToken,
      );
      if (alertsResponse is List) {
        final nextAlerts = <FarmAlert>[];
        for (final row in alertsResponse) {
          if (row is! Map<String, dynamic>) continue;
          final cowId = (row['cow_id'] as num?)?.toInt();
          final matchingCow = cowId == null
              ? null
              : cows.cast<Cow?>().firstWhere(
                  (cow) => cow?.backendId == cowId,
                  orElse: () => null,
                );
          if (matchingCow == null) continue;
          nextAlerts.add(
            FarmAlert(
              cowTag: matchingCow.tag,
              message: (row['message'] ?? 'Backend alert').toString(),
            ),
          );
        }
        if (nextAlerts.isNotEmpty) {
          alerts
            ..clear()
            ..addAll(nextAlerts);
        }
      }
    } on ApiException {
      // Silent fallback: the demo herd remains available while the backend is not yet configured.
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCowSampleData(String cowId, {int limit = 50}) async {
    final queryValue = cowId.trim();
    if (queryValue.isEmpty) return;

    try {
      final response = await _apiService.get(
        '/cows/sample-data?cow_id=${Uri.encodeComponent(queryValue)}&limit=${limit.clamp(1, 50)}',
        token: authToken,
      );
      if (response is! List) {
        sampleData.clear();
        notifyListeners();
        return;
      }

      sampleData
        ..clear()
        ..addAll(response.whereType<Map<String, dynamic>>().toList());
    } on ApiException {
      sampleData.clear();
    }
    notifyListeners();
  }

  Future<Cow?> findCowFromCsv(String cowId) async {
    final queryValue = cowId.trim();
    if (queryValue.isEmpty) return null;

    try {
      final response = await _apiService.get(
        '/cows/sample-data?cow_id=${Uri.encodeComponent(queryValue)}&limit=50',
        token: authToken,
      );
      if (response is! List ||
          response.isEmpty ||
          response.first is! Map<String, dynamic>) {
        sampleData.clear();
        notifyListeners();
        return null;
      }

      final first = response.first as Map<String, dynamic>;
      sampleData
        ..clear()
        ..addAll(response.whereType<Map<String, dynamic>>());
      final tag = (first['cow_id'] ?? queryValue).toString();
      final cow = Cow(
        name: tag,
        tag: tag,
        breed: (first['breed'] ?? 'Unknown').toString(),
        age: '${(first['age_years'] as num? ?? 0).toStringAsFixed(0)} years',
        todayMilkLitres: _toDouble(first['milk_yield_liters']) ?? 0,
        risk: _riskFromApi(first['risk_category']),
        trend: 'From CSV dataset',
        factors: const [],
        timeline: [
          'CSV sample loaded: ${first['recorded_date']} ${first['recorded_time']}',
          'Dataset contains ${sampleData.length} readings for this cow',
        ],
      );
      selectedCow = cow;
      notifyListeners();
      return cow;
    } on ApiException {
      sampleData.clear();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createFarm(
    String name,
    String location,
    int herdSize,
    String cowName,
    String cowTag,
  ) async {
    setupFarm(name, location, herdSize);
    if (authToken == null || authToken!.isEmpty) {
      errorMessage = 'Sign in before creating a farm.';
      notifyListeners();
      return false;
    }
    try {
      await _apiService.post(
        '/farms',
        body: {'name': name, 'location': location.isEmpty ? null : location},
        token: authToken,
      );
      await _apiService.post(
        '/cows',
        body: {'name': cowName, 'tag_id': cowTag},
        token: authToken,
      );
      hasBackendFarm = true;
      await loadBackendData();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  Cow _cowFromBackend(Map<String, dynamic> raw) => Cow(
    backendId: (raw['id'] as num?)?.toInt(),
    name: (raw['name'] ?? 'Cow').toString(),
    tag: (raw['tag_id'] ?? '').toString(),
    breed: (raw['breed'] ?? 'Unknown').toString(),
    age: _extractAge(raw['date_of_birth']),
    todayMilkLitres: 0,
    risk: RiskLevel.insufficientHistory,
    trend: 'No history yet',
    factors: const [],
    timeline: const ['Registered in GauRakshak'],
  );

  Future<Cow?> startBackendSession(String tagId) async {
    if (authToken == null || authToken!.isEmpty) return null;
    try {
      final encodedTag = Uri.encodeComponent(tagId.trim());
      final cowResponse = await _apiService.get(
        '/cows/by-tag/$encodedTag',
        token: authToken,
      );
      if (cowResponse is! Map<String, dynamic>) return null;
      final cow = _cowFromBackend(cowResponse);
      final sessionResponse = await _apiService.post(
        '/milking-sessions',
        body: {'tag_id': cow.tag, 'sensor_id': 'NODE-03'},
        token: authToken,
      );
      if (sessionResponse is! Map<String, dynamic>) return null;
      currentSession = MilkingSession(
        backendId: (sessionResponse['id'] as num?)?.toInt(),
        cowTag: cow.tag,
        sensorId: (sessionResponse['sensor_id'] ?? 'NODE-03').toString(),
        startedAt:
            DateTime.tryParse(
              (sessionResponse['started_at'] ?? '').toString(),
            ) ??
            DateTime.now(),
      );
      selectedCow = cow;
      notifyListeners();
      return cow;
    } on ApiException catch (error) {
      // A CSV cow may not have been imported into the relational catalog yet.
      // Still show its real metadata/history; session APIs become available
      // automatically after the CSV is imported with /cows/import-csv.
      final csvCow = await findCowFromCsv(tagId);
      if (csvCow != null) {
        errorMessage = null;
        return csvCow;
      }
      errorMessage = error.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> recordSessionReading(Cow cow) async {
    final session = currentSession;
    if (cow.backendId == null ||
        session?.backendId == null ||
        authToken == null) {
      return false;
    }
    try {
      await _apiService.post(
        '/sensor-readings',
        body: {
          'cow_id': cow.backendId,
          'session_id': session!.backendId,
          'milk_yield': 6.5,
          'milk_conductivity': 5.8,
          'milk_temperature': 39.1,
          'body_surface_temperature': 39.6,
          'activity': 38,
        },
        token: authToken,
      );
      await _apiService.post(
        '/milking-sessions/${session.backendId}/complete',
        token: authToken,
      );
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  void setupFarm(String name, String location, int herdSize) {
    farm = farm.copyWith(name: name, location: location, herdSize: herdSize);
    notifyListeners();
  }

  void addCow(Cow cow) {
    cows.add(cow);
    notifyListeners();
  }

  void selectCow(Cow? cow) {
    selectedCow = cow;
    notifyListeners();
  }

  void removeAlert(FarmAlert alert) {
    alerts.remove(alert);
    notifyListeners();
  }

  void addHealthRecord(Cow cow, String record) {
    cow.timeline.insert(0, 'Today: $record');
    notifyListeners();
  }

  void toggleLanguage() {
    useMarathi = !useMarathi;
    notifyListeners();
  }

  void toggleConnection() {
    isOnline = !isOnline;
    notifyListeners();
  }

  void startDemoSession(Cow cow) {
    selectedCow = cow;
    currentSession = MilkingSession(
      cowTag: cow.tag,
      sensorId: 'NODE-03',
      startedAt: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> completeSessionPrediction(Cow cow) async {
    if (cow.backendId == null) {
      savePrototypeResult(cow);
      return;
    }

    try {
      final response = await _apiService.post(
        '/predictions',
        body: {
          'cow_id': cow.backendId,
          if (currentSession?.backendId != null)
            'session_id': currentSession!.backendId,
        },
        token: authToken,
      );
      if (response is Map<String, dynamic>) {
        final risk = _riskFromApi(response['risk_level']);
        final factors =
            (response['contributing_factors'] as List?)
                ?.map((factor) => factor.toString())
                .toList() ??
            const <String>[];
        cow.risk = risk;
        cow.trend = (response['trend'] ?? 'Stable').toString();
        cow.factors = factors;
        latestPrediction = Prediction(
          riskScore: (_toDouble(response['risk_score']) ?? 0).round(),
          risk: risk,
          trend: cow.trend,
          factors: factors,
          isPrototype: false,
        );
        notifyListeners();
        return;
      }
    } on ApiException {
      // Keep the local result available when the API is unavailable.
    }
    savePrototypeResult(cow);
  }

  static RiskLevel _riskFromApi(Object? value) {
    switch (value?.toString().toLowerCase()) {
      case 'high':
        return RiskLevel.attention;
      case 'medium':
        return RiskLevel.monitor;
      case 'low':
        return RiskLevel.healthy;
      default:
        return RiskLevel.insufficientHistory;
    }
  }

  void savePrototypeResult(Cow cow) {
    cow.risk = RiskLevel.attention;
    cow.trend = 'Increasing';
    cow.factors = [
      'Milk yield is lower',
      'Conductivity is rising',
      'Activity is lower',
    ];
    cow.timeline.insert(0, 'Today: High prototype risk score recorded');
    latestPrediction = const Prediction(
      riskScore: 78,
      risk: RiskLevel.attention,
      trend: 'Increasing',
      factors: [
        'Milk yield is lower',
        'Conductivity is rising',
        'Activity is lower',
      ],
      isPrototype: true,
    );
    alerts.insert(
      0,
      FarmAlert(
        cowTag: cow.tag,
        message: 'Mastitis risk is high and increasing. Check the cow for udder inflammation and contact a veterinarian if needed.',
      ),
    );
    notifyListeners();
  }
}
