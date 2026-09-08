import 'package:flutter/material.dart';

import '../../models/domain.dart';
import '../ui.dart';

/// A scrollable specimen of every component in the GauRakshak UI kit.
///
/// Not a shipping screen — a Phase 0 harness to eyeball the widgets against the
/// Stitch reference PNGs before the real screens are built on top of them.
class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  int _navIndex = 0;
  String _otp = '';
  bool _loadingDemo = false;

  static final _cows = <Cow>[
    Cow(
      name: 'Gauri',
      tag: 'COW-024',
      breed: 'Gir',
      age: '4 yr',
      todayMilkLitres: 8.7,
      risk: RiskLevel.attention,
      trend: 'Decreasing',
      factors: const [],
      timeline: const [],
    ),
    Cow(
      name: 'Radha',
      tag: 'COW-011',
      breed: 'Jersey cross',
      age: '6 yr',
      todayMilkLitres: 11.2,
      risk: RiskLevel.monitor,
      trend: 'Stable',
      factors: const [],
      timeline: const [],
    ),
    Cow(
      name: 'Nandini',
      tag: 'COW-019',
      breed: 'Sahiwal',
      age: '5 yr',
      todayMilkLitres: 12.4,
      risk: RiskLevel.healthy,
      trend: 'Increasing',
      factors: const [],
      timeline: const [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Gallery'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      bottomNavigationBar: GauBottomNav(
        currentIndex: _navIndex,
        alertCount: 3,
        onTap: (i) => setState(() => _navIndex = i),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.pageMargin,
          AppSpace.md,
          AppSpace.pageMargin,
          AppSpace.xxxl,
        ),
        children: [
          _section('Typography', _typography()),
          _section('Colour', _colours()),
          _section('Status pills', _statusPills()),
          _section('Connectivity', _connectivity()),
          _section('Buttons', _buttons()),
          _section('Cards & elevation', _cards()),
          _section('Herd overview grid', _metricGrid()),
          _section('Milk-yield chart', _chart()),
          _section('Cow tiles', _cowTiles()),
          _section('Alert card', _alerts()),
          _section('Inputs', _inputs()),
          _section('Timeline', _timeline()),
          _section('States', _states()),
        ],
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpace.xl, bottom: AppSpace.sm),
          child: Text(title.toUpperCase(), style: AppText.labelSm),
        ),
        child,
        const SizedBox(height: AppSpace.xs),
        const Divider(),
      ],
    );
  }

  Widget _typography() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display 36', style: AppText.display),
        const SizedBox(height: AppSpace.xs),
        Text('Headline Lg 28', style: AppText.headlineLg),
        const SizedBox(height: AppSpace.xs),
        Text('Headline Md 20', style: AppText.headlineMd),
        const SizedBox(height: AppSpace.xs),
        Text('Headline Sm 18', style: AppText.headlineSm),
        const SizedBox(height: AppSpace.xs),
        Text('8.7 L metric numeral', style: AppText.metric),
        const SizedBox(height: AppSpace.xs),
        Text(
          'Body Lg 16 — the quick brown cow. Legible under sunlight glare on '
          'low-cost Android screens.',
          style: AppText.bodyLg,
        ),
        const SizedBox(height: AppSpace.xxs),
        Text('Body Md 15 — supporting detail text.', style: AppText.bodyMd),
        const SizedBox(height: AppSpace.xxs),
        Text("LABEL SM 11 — TODAY'S MILK YIELD", style: AppText.labelSm),
      ],
    );
  }

  Widget _colours() {
    Widget sw(String name, Color c, {Color? on}) => Container(
      width: 96,
      height: 56,
      padding: const EdgeInsets.all(AppSpace.xs),
      decoration: BoxDecoration(
        color: c,
        borderRadius: AppRadii.input,
        border: Border.all(color: AppColors.hairline),
      ),
      alignment: Alignment.bottomLeft,
      child: Text(
        name,
        style: AppText.labelSm.copyWith(color: on ?? AppColors.ink),
      ),
    );
    return Wrap(
      spacing: AppSpace.xs,
      runSpacing: AppSpace.xs,
      children: [
        sw('Forest', AppColors.forest, on: Colors.white),
        sw('Deep', AppColors.forestDeep, on: Colors.white),
        sw('Canvas', AppColors.canvas),
        sw('Mint', AppColors.mint),
        sw('Cream', AppColors.cream),
        sw('Healthy', AppColors.healthy, on: Colors.white),
        sw('Monitor', AppColors.monitor, on: Colors.white),
        sw('At Risk', AppColors.atRisk, on: Colors.white),
      ],
    );
  }

  Widget _statusPills() {
    return Wrap(
      spacing: AppSpace.xs,
      runSpacing: AppSpace.xs,
      children: const [
        StatusPill(RiskLevel.healthy),
        StatusPill(RiskLevel.monitor),
        StatusPill(RiskLevel.attention),
        StatusPill(RiskLevel.insufficientHistory),
        StatusPill(RiskLevel.attention, dense: true),
      ],
    );
  }

  Widget _connectivity() {
    return Wrap(
      spacing: AppSpace.md,
      runSpacing: AppSpace.xs,
      children: const [
        ConnectivityPill(ConnectivityState.online),
        ConnectivityPill(ConnectivityState.syncing),
        ConnectivityPill(ConnectivityState.offline),
      ],
    );
  }

  Widget _buttons() {
    return Column(
      children: [
        PrimaryButton(
          label: 'Start Milking',
          icon: Icons.play_arrow_rounded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpace.sm),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: _loadingDemo ? 'Working' : 'Loading demo',
                loading: _loadingDemo,
                onPressed: () async {
                  setState(() => _loadingDemo = true);
                  await Future<void>.delayed(const Duration(seconds: 1));
                  if (mounted) setState(() => _loadingDemo = false);
                },
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            const Expanded(child: PrimaryButton(label: 'Disabled')),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        SecondaryButton(
          label: 'Log a Check',
          icon: Icons.edit_note_rounded,
          onPressed: () {},
        ),
        const SizedBox(height: AppSpace.xs),
        GhostButton(label: 'Skip for now', onPressed: () {}),
      ],
    );
  }

  Widget _cards() {
    return Column(
      children: [
        GauCard(
          child: Text('Level 1 — default card', style: AppText.bodyLg),
        ),
        const SizedBox(height: AppSpace.sm),
        GauCard(
          elevation: 2,
          onTap: () {},
          child: Text('Level 2 — interactive (tap me)', style: AppText.bodyLg),
        ),
        const SizedBox(height: AppSpace.sm),
        GauCard(
          elevation: 3,
          color: AppColors.forest,
          border: false,
          child: Text(
            'Level 3 — forest sheet',
            style: AppText.bodyLg.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        StripCard(
          stripColor: AppColors.monitor,
          child: Text('Strip card — left severity rail', style: AppText.bodyLg),
        ),
      ],
    );
  }

  Widget _metricGrid() {
    return GauCard(
      child: Row(
        children: const [
          Expanded(child: MetricCell(value: '28', label: 'Total')),
          Expanded(
            child: MetricCell(
              value: '22',
              label: 'Healthy',
              color: AppColors.healthy,
            ),
          ),
          Expanded(
            child: MetricCell(
              value: '4',
              label: 'Monitor',
              color: AppColors.monitor,
            ),
          ),
          Expanded(
            child: MetricCell(
              value: '2',
              label: 'At Risk',
              color: AppColors.atRisk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chart() {
    return GauCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Herd milk — last 7 days', eyebrow: 'Litres'),
          const SizedBox(height: AppSpace.md),
          const GauBarChart(
            values: [48, 58, 52, 70, 66, 76, 72],
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
            highlightIndex: 6,
            showValues: true,
          ),
        ],
      ),
    );
  }

  Widget _cowTiles() {
    return Column(
      children: [
        CowAttentionCard(cow: _cows[0], onTap: () {}),
        const SizedBox(height: AppSpace.sm),
        CowListTile(cow: _cows[2], onTap: () {}),
        const SizedBox(height: AppSpace.xs),
        CowListTile(cow: _cows[1], onTap: () {}),
      ],
    );
  }

  Widget _alerts() {
    return Column(
      children: [
        AlertCard(
          alert: const FarmAlert(
            cowTag: 'COW-024 • Gauri',
            message:
                'Milk yield is trending down and conductivity is rising. A '
                'closer check is suggested.',
          ),
          severity: RiskLevel.attention,
          time: '2h ago',
          onTap: () {},
          onDismiss: () {},
        ),
        const SizedBox(height: AppSpace.sm),
        AlertCard(
          alert: const FarmAlert(
            cowTag: 'COW-011 • Radha',
            message: 'Slight change since yesterday — keep an eye on her.',
          ),
          severity: RiskLevel.monitor,
          time: 'Today',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _inputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GauTextField(
          label: 'Farm name',
          hint: 'e.g. Shree Krishna Dairy',
          prefixIcon: Icons.home_work_outlined,
        ),
        const SizedBox(height: AppSpace.md),
        Text('Enter OTP', style: AppText.labelLg),
        const SizedBox(height: AppSpace.xs),
        OtpInput(length: 6, onChanged: (v) => setState(() => _otp = v)),
        const SizedBox(height: AppSpace.xs),
        Text('Entered: $_otp', style: AppText.bodySm),
      ],
    );
  }

  Widget _timeline() {
    return GauCard(
      child: GauTimeline(
        entries: const [
          TimelineEntry(
            title: 'Milking session logged',
            detail: '8.7 L • morning',
            time: '7:10 AM',
            icon: Icons.water_drop_rounded,
          ),
          TimelineEntry(
            title: 'Early-warning flag raised',
            detail: 'Conductivity rising',
            time: 'Yesterday',
            color: AppColors.monitor,
            icon: Icons.warning_amber_rounded,
          ),
          TimelineEntry(
            title: 'Health check — normal',
            time: '3 days ago',
            color: AppColors.healthy,
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );
  }

  Widget _states() {
    return Column(
      children: [
        const OfflineBanner(),
        const SizedBox(height: AppSpace.md),
        SizedBox(
          height: 220,
          child: EmptyState(
            icon: Icons.pets_rounded,
            title: 'No cows yet',
            message: 'Add your first cow to start tracking milk and health.',
            actionLabel: 'Add a cow',
            onAction: () {},
          ),
        ),
        const SizedBox(height: AppSpace.md),
        const SizedBox(height: 120, child: LoadingState(label: 'Syncing herd…')),
        const SizedBox(height: AppSpace.md),
        SizedBox(
          height: 240,
          child: ErrorState(
            message: "We couldn't reach the server. Your data is safe on the "
                'device.',
            onRetry: () {},
          ),
        ),
      ],
    );
  }
}
