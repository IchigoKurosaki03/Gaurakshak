import 'dart:convert';

enum RiskLevel { healthy, monitor, attention, insufficientHistory }

extension RiskLevelUi on RiskLevel {
  String get label => switch (this) {
    RiskLevel.healthy => 'Healthy',
    RiskLevel.monitor => 'Monitor',
    RiskLevel.attention => 'Attention',
    RiskLevel.insufficientHistory => 'Needs history',
  };

  String get apiValue => switch (this) {
    RiskLevel.healthy => 'Low',
    RiskLevel.monitor => 'Medium',
    RiskLevel.attention => 'High',
    RiskLevel.insufficientHistory => 'Insufficient history',
  };
}

class FarmProfile {
  const FarmProfile({
    required this.name,
    required this.location,
    required this.herdSize,
  });

  final String name;
  final String location;
  final int herdSize;

  FarmProfile copyWith({String? name, String? location, int? herdSize}) =>
      FarmProfile(
        name: name ?? this.name,
        location: location ?? this.location,
        herdSize: herdSize ?? this.herdSize,
      );
}

class Cow {
  Cow({
    required this.name,
    required this.tag,
    required this.breed,
    required this.age,
    required this.todayMilkLitres,
    required this.risk,
    required this.trend,
    required this.factors,
    required this.timeline,
    this.backendId,
    this.riskScore,
    this.previousMastitis = false,
    this.currentlyTreated = false,
  });

  final int? backendId;
  int? riskScore;
  bool previousMastitis;
  bool currentlyTreated;
  final String name;
  final String tag;
  final String breed;
  final String age;
  double todayMilkLitres;
  RiskLevel risk;
  String trend;
  List<String> factors;
  final List<String> timeline;
}

class MilkRecord {
  const MilkRecord({required this.date, required this.litres});
  final DateTime date;
  final double litres;
}

class HealthRecord {
  const HealthRecord({
    required this.type,
    required this.note,
    required this.date,
  });
  final String type;
  final String note;
  final DateTime date;
}

class FarmAlert {
  const FarmAlert({required this.cowTag, required this.message});
  final String cowTag;
  final String message;
}

class Prediction {
  const Prediction({
    required this.riskScore,
    required this.risk,
    required this.trend,
    required this.factors,
    required this.isPrototype,
  });
  final int riskScore;
  final RiskLevel risk;
  final String trend;
  final List<String> factors;
  final bool isPrototype;
}

class SensorReading {
  const SensorReading({
    required this.milkYield,
    required this.conductivity,
    required this.milkTemperature,
    required this.bodyTemperature,
    required this.activity,
    required this.capturedAt,
  });
  final double milkYield;
  final double conductivity;
  final double milkTemperature;
  final double bodyTemperature;
  final double activity;
  final DateTime capturedAt;
}

class MilkingSession {
  const MilkingSession({
    required this.cowTag,
    required this.sensorId,
    required this.startedAt,
    this.reading,
    this.backendId,
  });
  final int? backendId;
  final String cowTag;
  final String sensorId;
  final DateTime startedAt;
  final SensorReading? reading;
}

class SensorNodeStatus {
  const SensorNodeStatus({
    required this.sensorId,
    required this.cowTag,
    required this.lastSeenAt,
    required this.readingCount,
    required this.isOnline,
  });

  final String sensorId;
  final String cowTag;
  final DateTime lastSeenAt;
  final int readingCount;
  final bool isOnline;
}

String encodeJson(Map<String, Object?> value) => jsonEncode(value);
