import '../models/domain.dart';

class DemoFarmRepository {
  FarmProfile initialFarm() => const FarmProfile(
    name: 'Shree Krishna Dairy',
    location: 'Pune, Maharashtra',
    // Do not invent a herd size before the farmer enters one. The dashboard
    // derives its total from loaded cows instead.
    herdSize: 0,
  );

  List<Cow> initialCows() => [
    Cow(
      name: 'Gauri', tag: 'COW-024', breed: 'Gir', age: '5 years',
      riskScore: 72,
      todayMilkLitres: 8.7, risk: RiskLevel.attention, trend: 'Increasing',
      factors: ['Milk yield is lower', 'Conductivity is rising', 'Activity is lower'],
      timeline: ['Today: High early-warning risk estimate', '28 Aug: Vaccination recorded', '15 Aug: Calving record added'],
    ),
    Cow(
      name: 'Nandini', tag: 'COW-019', breed: 'Sahiwal', age: '4 years',
      riskScore: 12,
      todayMilkLitres: 10.2, risk: RiskLevel.healthy, trend: 'Normal', factors: [],
      timeline: ['Today: Milking recorded', '18 Aug: Healthy check recorded'],
    ),
    Cow(
      name: 'Radha', tag: 'COW-011', breed: 'Jersey cross', age: '6 years',
      riskScore: 44,
      todayMilkLitres: 7.9, risk: RiskLevel.monitor, trend: 'Decreasing',
      factors: ['Milk yield changed from her usual level'],
      timeline: ['Today: Monitor at next milking', '12 Aug: Treatment note added'],
    ),
    Cow(
      name: 'Kamadhenu', tag: 'COW-030', breed: 'Gir', age: '3 years',
      riskScore: null,
      todayMilkLitres: 0, risk: RiskLevel.insufficientHistory, trend: 'No history yet', factors: [],
      timeline: ['Today: Profile created - collect the first session'],
    ),
    Cow(
      name: 'Sita', tag: 'COW-008', breed: 'Sahiwal', age: '5 years',
      riskScore: 18,
      todayMilkLitres: 9.8, risk: RiskLevel.healthy, trend: 'Improving',
      factors: ['Milk yield is returning to her usual level'],
      timeline: ['Today: Improving after a monitored period', '01 Sep: Monitor record added'],
    ),
  ];

  List<FarmAlert> initialAlerts() => const [
    FarmAlert(cowTag: 'COW-024', message: 'Risk increased over the last 2 days. Check the udder and contact a veterinarian if symptoms are present.'),
    FarmAlert(cowTag: 'COW-011', message: 'Milk yield is lower than usual. Check again at the next milking.'),
  ];

  List<MilkRecord> herdMilkTrend() {
    final today = DateTime.now();
    return [48, 58, 52, 70, 66, 76, 72]
        .asMap()
        .entries
        .map((entry) => MilkRecord(date: today.subtract(Duration(days: 6 - entry.key)), litres: entry.value.toDouble()))
        .toList();
  }
}
