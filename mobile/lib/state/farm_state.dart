import 'package:flutter/foundation.dart';

import '../models/domain.dart';
import '../localization/app_strings.dart';
import '../repositories/demo_farm_repository.dart';
import '../services/api_service.dart';

/// Outcome of an OTP sign-in attempt, so the UI can tell a real credential
/// rejection apart from a barn that simply has no network right now.
enum LoginResult { success, authFailed, offline }

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
  final List<SensorNodeStatus> sensorNodes = [];
  bool isOnline = true;
  AppLanguage language = AppLanguage.english;
  bool get useMarathi => language == AppLanguage.marathi;
  bool isLoading = false;
  String? errorMessage;
  Cow? selectedCow;
  MilkingSession? currentSession;
  Prediction? latestPrediction;
  String? authToken;
  bool hasBackendFarm = false;

  /// Human-readable source indicator used by the dashboard. This keeps demo,
  /// offline, and authenticated backend data visually distinct during demos.
  String get dataModeLabel {
    if (authToken != null && authToken!.isNotEmpty && isOnline) return 'Live sync';
    if (!isOnline) return 'Offline data';
    return 'Demo data';
  }

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
    if (normalized.contains('no risk') || normalized.contains('healthy')) {
      return RiskLevel.healthy.index;
    }
    if (normalized.contains('high') || normalized.contains('attention')) {
      return RiskLevel.attention.index;
    }
    if (normalized.contains('monitor') || normalized.contains('medium')) {
      return RiskLevel.monitor.index;
    }
    if (normalized.contains('low')) return RiskLevel.healthy.index;
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

  Future<LoginResult> loginAndSync(String phone, String otp) async {
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
          isOnline = true;
          await loadBackendData(token: authToken!);
          return LoginResult.success;
        }
      }
      errorMessage = 'Login succeeded but no token was returned.';
      return LoginResult.authFailed;
    } on ApiException catch (error) {
      if (error.statusCode == null) {
        // Could not reach the barn network at all. This is NOT a rejected
        // credential — let the farmer keep working on the on-device demo herd,
        // exactly as the offline notice promises.
        isOnline = false;
        errorMessage = null;
        return LoginResult.offline;
      }
      // The server was reachable and refused the request (e.g. wrong OTP).
      isOnline = true;
      errorMessage = error.message;
      return LoginResult.authFailed;
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
            riskScore: null,
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
      await loadSensorNodes(token: resolvedToken);
    } on ApiException {
      isOnline = false;
      // Keep the demo herd available while the backend is unavailable.
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSensorNodes({String? token}) async {
    final resolvedToken = token ?? authToken;
    if (resolvedToken == null || resolvedToken.isEmpty) return;
    try {
      final response = await _apiService.get('/sensors/status', token: resolvedToken);
      if (response is! List) return;
      sensorNodes
        ..clear()
        ..addAll(response.whereType<Map<String, dynamic>>().map((row) => SensorNodeStatus(
          sensorId: (row['sensor_id'] ?? 'Unknown node').toString(),
          cowTag: (row['cow_tag'] ?? 'Unassigned').toString(),
          lastSeenAt: DateTime.tryParse((row['last_seen_at'] ?? '').toString()) ?? DateTime.now(),
          readingCount: (row['reading_count'] as num?)?.toInt() ?? 0,
          isOnline: (row['status'] ?? '').toString().toLowerCase() == 'online',
        )));
    } on ApiException {
      // Device status is an enhancement; leave existing farm data usable when
      // the node service is temporarily unavailable.
      return;
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

      final latest = response.last as Map<String, dynamic>;
      sampleData
        ..clear()
        ..addAll(response.whereType<Map<String, dynamic>>());
      final tag = (latest['cow_id'] ?? queryValue).toString();
      final loadedCow = Cow(
        name: tag,
        tag: tag,
        breed: (latest['breed'] ?? 'Unknown').toString(),
        age: '${(latest['age_years'] as num? ?? 0).toStringAsFixed(0)} years',
        todayMilkLitres: _toDouble(latest['milk_yield_liters']) ?? 0,
        risk: _riskFromApi(latest['risk_category']),
        trend: 'From CSV dataset',
        factors: const [],
        timeline: [
          'Latest CSV sample: ${latest['recorded_date']} ${latest['recorded_time']}',
          'Dataset contains ${sampleData.length} readings for this cow',
        ],
        riskScore: ((_toDouble(latest['risk_probability']) ?? 0) * 100).round(),
      );
      final existingCow = cowByTag(tag);
      final cow = existingCow ?? loadedCow;
      if (existingCow == null) {
        cows.add(loadedCow);
        farm = farm.copyWith(herdSize: cows.length);
      } else {
        // A CSV lookup is a fresh monitoring record, so let the same data
        // power the profile and dashboard instead of leaving stale demo data.
        existingCow.todayMilkLitres = loadedCow.todayMilkLitres;
        existingCow.risk = loadedCow.risk;
        existingCow.riskScore = ((_toDouble(latest['risk_probability']) ?? 0) * 100).round();
        existingCow.trend = 'Latest CSV reading';
        existingCow.factors = [
          'Latest reading: ${latest['reading_session']} ${latest['recorded_date']} ${latest['recorded_time']}',
          'Milk conductivity: ${latest['milk_conductivity_ms_cm']} mS/cm',
        ];
        existingCow.timeline
          ..removeWhere((item) => item.startsWith('Latest CSV sample:') || item.startsWith('Dataset contains'))
          ..insertAll(0, loadedCow.timeline);
      }
      selectedCow = cow;
      notifyListeners();
      return cow;
    } on ApiException catch (error) {
      sampleData.clear();
      errorMessage = error.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> createFarm(
    String name,
    String location,
    int herdSize,
    {
      String cowName = '',
      String cowTag = '',
      String cowBreed = '',
      String cowAge = '',
      String cowHealth = 'Healthy',
    }
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
      if (cowName.trim().isNotEmpty && cowTag.trim().isNotEmpty) {
        await _apiService.post(
          '/cows',
          body: {
            'name': cowName.trim(),
            'tag_id': cowTag.trim(),
            if (cowBreed.trim().isNotEmpty) 'breed': cowBreed.trim(),
            'basic_health_status': cowHealth,
          },
          token: authToken,
        );
      }
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
    riskScore: null,
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
    if (session == null) {
      return false;
    }
    final reading = SensorReading(
      milkYield: 6.5,
      conductivity: 5.8,
      milkTemperature: 39.1,
      bodyTemperature: 39.6,
      activity: 38,
      capturedAt: DateTime.now(),
    );
    currentSession = MilkingSession(
      cowTag: session.cowTag,
      sensorId: session.sensorId,
      startedAt: session.startedAt,
      backendId: session.backendId,
      reading: reading,
    );

    if (cow.backendId == null || session.backendId == null || authToken == null) {
      return true;
    }
    try {
      await _apiService.post(
        '/sensor-readings',
        body: {
          'cow_id': cow.backendId,
          'session_id': session.backendId,
          'milk_yield': reading.milkYield,
          'milk_conductivity': reading.conductivity,
          'milk_temperature': reading.milkTemperature,
          'body_surface_temperature': reading.bodyTemperature,
          'activity': reading.activity,
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

  void setLanguage(AppLanguage nextLanguage) {
    language = nextLanguage;
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
        cow.riskScore = _scoreOutOf100(response['risk_score']);
        cow.trend = (response['trend'] ?? 'Stable').toString();
        cow.factors = factors;
        latestPrediction = Prediction(
          riskScore: _scoreOutOf100(response['risk_score']),
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

  static int _scoreOutOf100(Object? value) {
    final score = _toDouble(value) ?? 0;
    return (score <= 1 ? score * 100 : score).round().clamp(0, 100);
  }

  /// Offline / no-backend fallback for a completed session.
  ///
  /// It deliberately does NOT fabricate a risk. With no connected sensor
  /// pipeline there is nothing to compute, so we surface an explicit
  /// "insufficient data" estimate, clearly flagged as a prototype. It never
  /// overwrites the cow's known state or raises an alarm. (Phase 2 feeds this
  /// from clearly-simulated, cow-tied readings.)
  void savePrototypeResult(Cow cow) {
    final reading = currentSession?.reading;
    if (reading == null) {
      latestPrediction = const Prediction(
        riskScore: 0,
        risk: RiskLevel.insufficientHistory,
        trend: 'Unknown',
        factors: ['Not enough connected sensor data to estimate risk'],
        isPrototype: true,
      );
      notifyListeners();
      return;
    }

    var score = 0;
    final factors = <String>[];
    if (reading.conductivity >= 5.5) {
      score += 30;
      factors.add('Milk conductivity is elevated');
    }
    if (reading.milkYield <= 7) {
      score += 20;
      factors.add('Milk yield is lower than the recent pattern');
    }
    if (reading.milkTemperature >= 39) {
      score += 15;
      factors.add('Milk temperature is elevated');
    }
    if (reading.bodyTemperature >= 39.5) {
      score += 15;
      factors.add('Surface temperature is elevated');
    }
    if (reading.activity <= 40) {
      score += 20;
      factors.add('Activity is lower than the recent pattern');
    }
    final risk = score >= 66
        ? RiskLevel.attention
        : score >= 33
        ? RiskLevel.monitor
        : RiskLevel.healthy;
    final trend = score >= 33 ? 'Increasing' : 'Normal';
    cow.risk = risk;
    cow.riskScore = score.clamp(0, 99);
    cow.trend = trend;
    cow.factors = factors.isEmpty ? ['No significant changes detected'] : factors;
    cow.timeline.insert(0, 'Today: ${risk.label} early-warning risk estimate');
    latestPrediction = Prediction(
      riskScore: score.clamp(0, 99),
      risk: risk,
      trend: trend,
      factors: cow.factors,
      isPrototype: true,
    );
    if (risk == RiskLevel.attention &&
        !alerts.any((alert) => alert.cowTag == cow.tag)) {
      alerts.insert(
        0,
        FarmAlert(
          cowTag: cow.tag,
          message:
              '${cow.name} needs attention. Check the cow for visible symptoms and contact a veterinarian if needed.',
        ),
      );
    }
    notifyListeners();
  }

  /// Prefer the securely authenticated backend assistant. Returning null lets
  /// the UI fall back to its useful offline helper when a barn is disconnected.
  Future<String?> askGauSaathi(String message) async {
    final token = authToken;
    if (token == null || token.isEmpty) return null;
    try {
      final response = await _apiService.post(
        '/assistant/chat',
        token: token,
        body: {
          'message': message.trim(),
          if (selectedCow?.backendId != null) 'cow_id': selectedCow!.backendId,
        },
      );
      if (response is Map<String, dynamic>) {
        final reply = response['reply']?.toString().trim() ?? '';
        return reply.isEmpty ? null : reply;
      }
    } on ApiException {
      // The local assistant is intentionally retained for offline-first use.
    }
    return null;
  }
}
