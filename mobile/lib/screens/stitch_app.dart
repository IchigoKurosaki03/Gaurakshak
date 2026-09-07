import 'dart:async';

import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/farm_state.dart';
import '../theme/gau_theme.dart';

enum StitchRoute {
  splash,
  login,
  setup,
  dashboard,
  profile,
  scan,
  milking,
  result,
}

class StitchApp extends StatefulWidget {
  const StitchApp({super.key, required this.state});
  final FarmState state;
  @override
  State<StitchApp> createState() => _StitchAppState();
}

class _StitchAppState extends State<StitchApp> {
  StitchRoute route = StitchRoute.splash;
  Cow? cow;
  void go(StitchRoute value, {Cow? selected}) => setState(() {
    route = value;
    cow = selected ?? cow;
  });
  @override
  Widget build(BuildContext context) {
    final activeCow = cow ?? widget.state.cows.first;
    final child = switch (route) {
      StitchRoute.splash => _Splash(next: () => go(StitchRoute.login)),
      StitchRoute.login => _Login(
        state: widget.state,
        next: () => go(
          widget.state.hasBackendFarm
              ? StitchRoute.dashboard
              : StitchRoute.setup,
        ),
      ),
      StitchRoute.setup => _Setup(
        state: widget.state,
        next: () => go(StitchRoute.dashboard),
      ),
      StitchRoute.dashboard => _Dashboard(
        state: widget.state,
        scan: () => go(StitchRoute.scan),
        select: (c) => go(StitchRoute.profile, selected: c),
      ),
      StitchRoute.profile => _Profile(
        cow: activeCow,
        back: () => go(StitchRoute.dashboard),
        start: () => go(StitchRoute.scan),
      ),
      StitchRoute.scan => _Scan(
        state: widget.state,
        back: () => go(StitchRoute.dashboard),
        verified: (c) => go(StitchRoute.milking, selected: c),
      ),
      StitchRoute.milking => _Milking(
        cow: activeCow,
        back: () => go(StitchRoute.dashboard),
        finish: () async {
          await widget.state.recordSessionReading(activeCow);
          await widget.state.completeSessionPrediction(activeCow);
          go(StitchRoute.result);
        },
      ),
      StitchRoute.result => _Result(
        cow: activeCow,
        state: widget.state,
        done: () => go(StitchRoute.dashboard),
      ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(route), child: child),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash({required this.next});
  final VoidCallback next;
  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> with SingleTickerProviderStateMixin {
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) widget.next();
    });
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF143823),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DarkPill('●  Sync Ready'),
                Text(
                  'FLUTTER APP CORE',
                  style: TextStyle(
                    color: Color(0x9998D4A8),
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: pulse,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0x5598D4A8),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 126,
                    height: 126,
                    decoration: BoxDecoration(
                      color: GauColors.forest,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF98D4A8),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 62,
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    child: Icon(
                      Icons.water_drop,
                      color: Color(0xFFE9F4E7),
                      size: 38,
                    ),
                  ),
                ],
              ),
              builder: (context, child) =>
                  Transform.scale(scale: .96 + pulse.value * .06, child: child),
            ),
            const SizedBox(height: 18),
            const _Pill(
              'DAIRY HEALTH ASSISTANT',
              Color(0xFF98D4A8),
              Color(0x331A4D2E),
            ),
            const SizedBox(height: 10),
            const Text(
              'GauRakshak',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Early mastitis warning & milk monitoring for healthy herds',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xDDE9F4E7), height: 1.4),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(
                  child: _Flow(
                    Icons.qr_code_scanner,
                    '1. Scan Cow',
                    'RFID / Ear-tag',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _Flow(Icons.sensors, '2. Auto-Log', 'Sensor session'),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _Flow(
                    Icons.health_and_safety,
                    '3. Early Alert',
                    'Risk estimate',
                  ),
                ),
              ],
            ),
            const Spacer(),
            _Action(
              'Enter Farm Assistant',
              Icons.arrow_forward,
              widget.next,
              light: true,
            ),
            const SizedBox(height: 12),
            const Text(
              'Opening animation · 2.5s',
              style: TextStyle(color: Color(0x9998D4A8), fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Login extends StatefulWidget {
  const _Login({required this.state, required this.next});
  final FarmState state;
  final VoidCallback next;
  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final phone = TextEditingController(text: '9999999999');
  final otp = TextEditingController(text: '123456');
  bool isSubmitting = false;
  @override
  void dispose() {
    phone.dispose();
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const Spacer(),
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your registered mobile number to manage your herd and milk logs.',
              style: TextStyle(color: Color(0xFF5C6B61)),
            ),
            const SizedBox(height: 22),
            _Card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('MOBILE NUMBER'),
                  const SizedBox(height: 7),
                  _Input(
                    phone,
                    prefix: '🇮🇳  +91',
                    suffix: Icons.check_circle,
                    type: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enter 6-Digit OTP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: GauColors.forest,
                        ),
                      ),
                      Text(
                        'Demo OTP: 123456',
                        style: TextStyle(fontSize: 11, color: GauColors.forest),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Input(otp, center: true, type: TextInputType.number),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _Notice(
              'Works offline inside barn sheds. Herd records sync once network restores.',
            ),
            if (widget.state.errorMessage != null) ...[
              const SizedBox(height: 8),
              _Notice(widget.state.errorMessage!),
            ],
            const Spacer(),
            _Action(
              isSubmitting ? 'Verifying…' : 'Verify & Continue',
              Icons.arrow_forward,
              isSubmitting
                  ? null
                  : () async {
                      setState(() {
                        isSubmitting = true;
                        widget.state.errorMessage = null;
                      });
                      await widget.state.loginAndSync(
                        phone.text.replaceAll(RegExp(r'\s+'), ''),
                        otp.text,
                      );
                      if (!mounted) return;
                      setState(() => isSubmitting = false);
                      if (widget.state.authToken != null) widget.next();
                    },
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'By continuing, you agree to GauRakshak Dairy Management Terms',
                style: TextStyle(fontSize: 10, color: Color(0xFF5C6B61)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Setup extends StatefulWidget {
  const _Setup({required this.state, required this.next});
  final FarmState state;
  final VoidCallback next;
  @override
  State<_Setup> createState() => _SetupState();
}

class _SetupState extends State<_Setup> {
  late final name = TextEditingController(text: widget.state.farm.name);
  late final herd = TextEditingController(
    text: widget.state.farm.herdSize > 0 ? '${widget.state.farm.herdSize}' : '',
  );
  late final location = TextEditingController(text: widget.state.farm.location);
  final cowName = TextEditingController(text: 'Gauri');
  final cowTag = TextEditingController(text: 'COW-024');
  @override
  void dispose() {
    name.dispose();
    herd.dispose();
    location.dispose();
    cowName.dispose();
    cowTag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.arrow_back),
                Spacer(),
                _Pill(
                  'Step 1 of 2: Farm Profile',
                  GauColors.forest,
                  GauColors.mint,
                ),
                Spacer(),
                Text('Skip for now', style: TextStyle(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Create Your Dairy Farm',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Keep it simple. Complete medical history later.',
              style: TextStyle(color: Color(0xFF5C6B61)),
            ),
            const SizedBox(height: 24),
            _Field('FARM NAME *', 'Required', Icons.agriculture, name),
            const SizedBox(height: 12),
            _Field(
              'NUMBER OF COWS *',
              'Estimated herd size',
              Icons.pets,
              herd,
              TextInputType.number,
            ),
            const SizedBox(height: 12),
            _Field(
              'LOCATION / DISTRICT',
              'Optional',
              Icons.pin_drop_outlined,
              location,
            ),
            const SizedBox(height: 12),
            _Field(
              'FIRST COW NAME *',
              'For example: Gauri',
              Icons.pets,
              cowName,
            ),
            const SizedBox(height: 12),
            _Field(
              'FIRST COW TAG *',
              'RFID / ear-tag ID',
              Icons.qr_code_rounded,
              cowTag,
            ),
            const SizedBox(height: 14),
            const _Notice(
              'Your farm and first cow are stored securely before milking starts.',
            ),
            const Spacer(),
            _Action('Save & Add First Cow', Icons.arrow_forward, () async {
              final created = await widget.state.createFarm(
                name.text,
                location.text,
                int.tryParse(herd.text) ?? 28,
                cowName.text,
                cowTag.text,
              );
              if (created && mounted) widget.next();
            }),
          ],
        ),
      ),
    ),
  );
}

class _Dashboard extends StatefulWidget {
  const _Dashboard({
    required this.state,
    required this.scan,
    required this.select,
  });
  final FarmState state;
  final VoidCallback scan;
  final ValueChanged<Cow> select;
  @override
  State<_Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<_Dashboard> {
  int tab = 0;

  void _selectTab(int value) => setState(() => tab = value);

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final alerts = state.cows.where((c) => c.risk != RiskLevel.healthy).take(2);
    final selectedCow = state.selectedCow ?? state.cows.first;
    final content = switch (tab) {
      1 => _CowList(cows: state.cows, select: widget.select),
      2 => _CowHealth(cow: selectedCow, start: widget.scan),
      3 => _AlertList(cows: alerts.toList(), select: widget.select),
      4 => _MilkOverview(state: state),
      _ => _DashboardHome(
        state: state,
        alerts: alerts,
        scan: widget.scan,
        select: widget.select,
      ),
    };
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.pets), label: 'Cows'),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'Cow health',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_active_outlined),
            label: 'Alerts',
          ),
          NavigationDestination(icon: Icon(Icons.water_drop_outlined), label: 'Milk'),
        ],
      ),
      body: SafeArea(child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: content,
        ),
      )),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({required this.state, required this.alerts, required this.scan, required this.select});
  final FarmState state;
  final Iterable<Cow> alerts;
  final VoidCallback scan;
  final ValueChanged<Cow> select;
  @override
  Widget build(BuildContext context) {
    final sampleData = state.sampleData.take(3).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _FarmTop(state.farm),
            const SizedBox(height: 15),
            const _FarmStatus(),
            const SizedBox(height: 15),
            InkWell(onTap: scan, child: const _StartCard()),
            const SizedBox(height: 20),
            _Section('Herd Overview', 'TOTAL: ${state.cows.length}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    '${state.cows.length}',
                    'TOTAL',
                    Icons.pets,
                    Colors.white,
                    GauColors.ink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Metric(
                    '${state.count(RiskLevel.healthy)}',
                    'HEALTHY',
                    Icons.check_circle_outline,
                    GauColors.healthySurface,
                    const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Metric(
                    '${state.count(RiskLevel.monitor)}',
                    'MONITOR',
                    Icons.warning_amber_rounded,
                    GauColors.amberSurface,
                    GauColors.amber,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Metric(
                    '${state.count(RiskLevel.attention)}',
                    'AT RISK',
                    Icons.crisis_alert_outlined,
                    GauColors.redSurface,
                    GauColors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _MilkTotal(state.totalMilk),
            const SizedBox(height: 20),
            const _Section('Cows Needing Attention', '2 flagged'),
            ...alerts.map((c) => _Attention(c, () => select(c))),
            const SizedBox(height: 16),
            if (sampleData.isNotEmpty) ...[
              const _Section('Cow Sample Data', 'Last 50 records'),
              const SizedBox(height: 8),
              _SampleDataPanel(sampleData),
            ],
            const SizedBox(height: 16),
            const _Section('7-Day Consistency', ''),
            _Bars(state.milkTrend.map((e) => e.litres).toList()),
            const SizedBox(height: 18),
            const _Section('Recent Milking Activity', 'View History'),
            _Activity(state.cows.take(3).toList()),
          ],
    );
  }
}

class _CowList extends StatelessWidget {
  const _CowList({required this.cows, required this.select});
  final List<Cow> cows;
  final ValueChanged<Cow> select;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
    children: [
      const _PageHeading('Cows', 'Open a cow profile or review its live health node.'),
      const SizedBox(height: 16),
      ...cows.map((cow) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: () => select(cow),
          borderRadius: BorderRadius.circular(16),
          child: _Card(Row(children: [
            _CowIcon(cow),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(cow.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              Text('${cow.tag} · ${cow.breed}', style: const TextStyle(color: Color(0xFF5C6B61))),
            ])),
            _RiskPill(cow.risk),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right),
          ])),
        ),
      )),
    ],
  );
}

class _CowHealth extends StatelessWidget {
  const _CowHealth({required this.cow, required this.start});
  final Cow cow;
  final VoidCallback start;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
    children: [
      const _PageHeading('Cow health', 'Wearable sensor node status and latest readings.'),
      const SizedBox(height: 16),
      _Card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const CircleAvatar(backgroundColor: GauColors.healthySurface, child: Icon(Icons.monitor_heart, color: GauColors.forest)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cow.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text('${cow.tag} · ${cow.breed}', style: const TextStyle(color: Color(0xFF5C6B61))),
          ])),
          _RiskPill(cow.risk),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFEAF4EC), borderRadius: BorderRadius.circular(14)),
          child: const Row(children: [
            Icon(Icons.bluetooth_connected, color: GauColors.forest),
            SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Wearable sensor node', style: TextStyle(fontWeight: FontWeight.w800)),
              Text('NODE-03 · Connected · Last sync just now', style: TextStyle(fontSize: 12, color: Color(0xFF5C6B61))),
            ])),
            Icon(Icons.check_circle, color: GauColors.forest),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _Info('Body temp', '38.6 °C', Icons.thermostat, GauColors.forest)),
          const SizedBox(width: 8),
          Expanded(child: _Info('Activity', 'Normal', Icons.directions_walk, GauColors.forest)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _Info('Heart rate', '64 bpm', Icons.favorite_outline, GauColors.red)),
          const SizedBox(width: 8),
          Expanded(child: _Info('Signal', 'Strong', Icons.network_check, GauColors.amber)),
        ]),
        const SizedBox(height: 14),
        _Action('Start sensor-assisted milking', Icons.sensors, start),
      ])),
    ],
  );
}

class _AlertList extends StatelessWidget {
  const _AlertList({required this.cows, required this.select});
  final List<Cow> cows;
  final ValueChanged<Cow> select;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
    children: [
      _PageHeading('Alerts', '${cows.length} cows need a closer look.'),
      const SizedBox(height: 16),
      if (cows.isEmpty) const _Notice('No active cow health alerts.'),
      ...cows.map((cow) => _Attention(cow, () => select(cow))),
    ],
  );
}

class _MilkOverview extends StatelessWidget {
  const _MilkOverview({required this.state});
  final FarmState state;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
    children: [
      const _PageHeading('Milk', 'Milking totals linked to each cow and sensor session.'),
      const SizedBox(height: 16),
      _MilkTotal(state.totalMilk),
      const SizedBox(height: 16),
      _Activity(state.cows),
    ],
  );
}

class _PageHeading extends StatelessWidget {
  const _PageHeading(this.title, this.subtitle);
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
    const SizedBox(height: 4),
    Text(subtitle, style: const TextStyle(color: Color(0xFF5C6B61))),
  ]);
}

class _Profile extends StatelessWidget {
  const _Profile({required this.cow, required this.back, required this.start});
  final Cow cow;
  final VoidCallback back, start;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(onPressed: back, icon: const Icon(Icons.arrow_back)),
              const _Mark(),
              const SizedBox(width: 10),
              const Text(
                'Cow Detail',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const CircleAvatar(
                backgroundColor: GauColors.forest,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
            ],
          ),
          const _Sync(),
          const SizedBox(height: 12),
          _CowHero(cow),
          const SizedBox(height: 14),
          const _Risk(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Info(
                  'TODAY’S MILK',
                  '${cow.todayMilkLitres.toStringAsFixed(1)} L',
                  Icons.water_drop_outlined,
                  GauColors.ink,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Info(
                  'YIELD TREND',
                  cow.trend,
                  Icons.trending_down,
                  GauColors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Action('Start Milking Session', Icons.play_circle_outline, start),
          const SizedBox(height: 9),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Physical check record is ready to be connected to the health API.',
                  ),
                ),
              ),
              icon: const Icon(Icons.health_and_safety_outlined),
              label: const Text('Log Udder Physical Check'),
            ),
          ),
          const SizedBox(height: 18),
          _Timeline(cow.timeline),
          const SizedBox(height: 10),
          const _Record(
            Icons.medical_services_outlined,
            'Medical & Treatment Records',
            'Deworming, immunizations, past vet checks',
          ),
          const _Record(
            Icons.eco_outlined,
            'Lactation & Breeding Cycle',
            'Lactation #2 · 20 days in milk',
          ),
        ],
      ),
    ),
  );
}

class _Scan extends StatefulWidget {
  const _Scan({
    required this.state,
    required this.back,
    required this.verified,
  });
  final FarmState state;
  final VoidCallback back;
  final ValueChanged<Cow> verified;
  @override
  State<_Scan> createState() => _ScanState();
}

class _ScanState extends State<_Scan> {
  final tag = TextEditingController(text: 'COW-024');
  Cow? cow;
  String? error;
  @override
  void dispose() {
    tag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: widget.back,
                  icon: const Icon(Icons.arrow_back),
                ),
                const _Mark(),
                const SizedBox(width: 10),
                const Text(
                  'Verify Cow & Sensor',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 13),
            const _Sync(),
            const SizedBox(height: 20),
            const Text(
              'Scan the ear-tag',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text('Use RFID / QR as the primary identification method.'),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: GauColors.ink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 76),
                  SizedBox(height: 10),
                  Text(
                    'SIMULATED RFID SCANNER',
                    style: TextStyle(
                      color: Color(0xFF98D4A8),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _Input(tag)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        cow = null;
                        error = null;
                      });
                      final match = await widget.state.startBackendSession(
                        tag.text,
                      );
                      if (!mounted) return;
                      setState(() {
                        cow = match;
                        error = match == null
                            ? (widget.state.errorMessage ??
                                  'Cow not found. Add it to this farm before starting a session.')
                            : null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GauColors.forest,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.search),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (cow != null)
              _Verified(cow!)
            else if (error != null)
              _Notice(error!)
            else
              const _Notice(
                'Enter a cow ID exactly as it appears in your cow catalog.',
              ),
            if (widget.state.sampleData.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SampleDataPanel(widget.state.sampleData.take(3).toList()),
            ],
            const Spacer(),
            _Action(
              'Assign Sensor & Continue',
              Icons.sensors,
              cow == null ? null : () => widget.verified(cow!),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Milking extends StatefulWidget {
  const _Milking({required this.cow, required this.back, required this.finish});
  final Cow cow;
  final VoidCallback back;
  final Future<void> Function() finish;
  @override
  State<_Milking> createState() => _MilkingState();
}

class _MilkingState extends State<_Milking> {
  int seconds = 405;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: widget.back,
                  icon: const Icon(Icons.arrow_back),
                ),
                const _Mark(),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Active Milking Session',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ),
                const CircleAvatar(
                  backgroundColor: GauColors.forest,
                  child: Icon(Icons.person_outline, color: Colors.white),
                ),
              ],
            ),
            const _Connection(),
            const _Steps(),
            const SizedBox(height: 20),
            _Verified(widget.cow),
            const SizedBox(height: 16),
            const _Sensor(),
            const SizedBox(height: 18),
            _Card(
              Column(
                children: [
                  _Pill(
                    '●  MILKING IN PROGRESS',
                    const Color(0xFF2E7D32),
                    GauColors.healthySurface,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _Big(
                          'ELAPSED TIME',
                          time,
                          'Standard pace',
                          Icons.schedule,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _Big(
                          'YIELD HARVESTED',
                          '6.5 L',
                          'Flow active (1.1 L/min)',
                          Icons.water_drop_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const LinearProgressIndicator(
                    value: .74,
                    minHeight: 12,
                    color: GauColors.forest,
                    backgroundColor: Color(0xFFE1EBDE),
                    borderRadius: BorderRadius.all(Radius.circular(99)),
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Morning Baseline: 8.5 L'),
                      Text(
                        '74% of Target',
                        style: TextStyle(
                          color: GauColors.forest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _Notice(
                    'Continuous logging active. You can safely set your phone aside while milking.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _Action(
              'Finish Milking & Analyze',
              Icons.check_circle_outline,
              () async => widget.finish(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.cow, required this.state, required this.done});
  final Cow cow;
  final FarmState state;
  final VoidCallback done;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              const _Mark(),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Milking Analysis',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              const CircleAvatar(
                backgroundColor: GauColors.forest,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _Session(),
          _ResultCow(cow),
          const SizedBox(height: 14),
          const _Warning(),
          const SizedBox(height: 14),
          const _Yield(),
          const SizedBox(height: 14),
          const _Recommendation(),
          if (state.latestPrediction?.isPrototype ?? true)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: _Notice(
                'Offline prototype result — reconnect to save a backend prediction.',
              ),
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call Vet'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _Action('View Dashboard', Icons.check, done)),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      _Mark(),
      SizedBox(width: 10),
      Text(
        'GauRakshak',
        style: TextStyle(
          color: GauColors.forest,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      Spacer(),
      _Pill('OFFLINE READY', GauColors.forest, GauColors.mint),
    ],
  );
}

class _Mark extends StatelessWidget {
  const _Mark();
  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: GauColors.forest,
      borderRadius: BorderRadius.circular(9),
    ),
    child: const Icon(Icons.pets, color: Colors.white, size: 21),
  );
}

class _DarkPill extends StatelessWidget {
  const _DarkPill(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0x2220B967),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF98D4A8),
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, this.color, this.background);
  final String text;
  final Color color, background;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
    ),
  );
}

class _Flow extends StatelessWidget {
  const _Flow(this.icon, this.title, this.note);
  final IconData icon;
  final String title, note;
  @override
  Widget build(BuildContext context) => Container(
    height: 103,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0x1FFFFFFF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x2298D4A8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF98D4A8), size: 19),
        const Spacer(),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          note,
          style: const TextStyle(color: Color(0xBBE9F4E7), fontSize: 9),
        ),
      ],
    ),
  );
}

class _Action extends StatelessWidget {
  const _Action(this.text, this.icon, this.onTap, {this.light = false});
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final bool light;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: light ? const Color(0xFF98D4A8) : GauColors.forest,
        foregroundColor: light ? const Color(0xFF0A2315) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    ),
  );
}

class _Card extends StatelessWidget {
  const _Card(this.child);
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0x161C251D)),
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: GauColors.forest,
      letterSpacing: .8,
    ),
  );
}

class _Input extends StatelessWidget {
  const _Input(
    this.controller, {
    this.prefix,
    this.suffix,
    this.center = false,
    this.type,
  });
  final TextEditingController controller;
  final String? prefix;
  final IconData? suffix;
  final bool center;
  final TextInputType? type;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0xFFECF7EA),
      border: Border.all(color: const Color(0x55235D3A), width: 1.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: controller,
      textAlign: center ? TextAlign.center : TextAlign.start,
      keyboardType: type,
      style: TextStyle(
        fontSize: center ? 22 : 15,
        letterSpacing: center ? 8 : 0,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        prefixText: prefix == null ? null : '$prefix   ',
        suffixIcon: suffix == null
            ? null
            : Icon(suffix, color: GauColors.forest),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field(this.title, this.hint, this.icon, this.controller, [this.type]);
  final String title, hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? type;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Label(title),
      const SizedBox(height: 7),
      _Card(
        Row(
          children: [
            Icon(icon, color: GauColors.forest),
            const SizedBox(width: 11),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: type,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Notice extends StatelessWidget {
  const _Notice(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xFFECF7EA),
      border: Border.all(color: const Color(0x33235D3A)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: GauColors.forest, size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF1A4D2E),
            ),
          ),
        ),
      ],
    ),
  );
}

class _FarmTop extends StatelessWidget {
  const _FarmTop(this.farm);
  final FarmProfile farm;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const _Mark(),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              farm.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const Text(
              'ONLINE · SYNCED',
              style: TextStyle(
                fontSize: 10,
                color: GauColors.forest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      const CircleAvatar(
        backgroundColor: GauColors.forest,
        child: Icon(Icons.person_outline, color: Colors.white),
      ),
    ],
  );
}

class _FarmStatus extends StatelessWidget {
  const _FarmStatus();
  @override
  Widget build(BuildContext context) => _Card(
    const Row(
      children: [
        CircleAvatar(
          backgroundColor: GauColors.healthySurface,
          child: Icon(Icons.cloud_done_outlined, color: GauColors.forest),
        ),
        SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Farm systems healthy',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'Barn nodes reporting · last sync just now',
                style: TextStyle(fontSize: 11, color: Color(0xFF5C6B61)),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right),
      ],
    ),
  );
}

class _StartCard extends StatelessWidget {
  const _StartCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: GauColors.forest,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFFB3F1C3),
          child: Icon(Icons.qr_code_scanner, color: GauColors.forest),
        ),
        SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start a Milking Session',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Scan RFID ear-tag to identify cow',
                style: TextStyle(color: Color(0xDDE9F4E7), fontSize: 11),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward, color: Color(0xFF98D4A8)),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.text, this.trailing);
  final String text, trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      if (trailing.isNotEmpty)
        Text(
          trailing,
          style: const TextStyle(
            fontSize: 10,
            color: GauColors.forest,
            fontWeight: FontWeight.w800,
          ),
        ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label, this.icon, this.background, this.color);
  final String value, label;
  final IconData icon;
  final Color background, color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 19,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _MilkTotal extends StatelessWidget {
  const _MilkTotal(this.total);
  final double total;
  @override
  Widget build(BuildContext context) => _Card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'TODAY’S TOTAL MILK',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
            _Pill(
              '↑ +6.2 L vs yesterday',
              GauColors.forest,
              GauColors.healthySurface,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${total.toStringAsFixed(1)} Litres',
          style: const TextStyle(
            fontSize: 31,
            color: GauColors.forest,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: Text('☀  Morning     142 L')),
            Expanded(child: Text('◐  Evening     106.5 L')),
          ],
        ),
      ],
    ),
  );
}

class _Attention extends StatelessWidget {
  const _Attention(this.cow, this.tap);
  final Cow cow;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) {
    final red = cow.risk == RiskLevel.attention;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: red ? GauColors.red : GauColors.amber,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CowIcon(cow),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cow.name,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Tag: ${cow.tag} · ${cow.breed}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              _RiskPill(cow.risk),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            red
                ? 'MASTITIS RISK: HIGH — Conduct physical udder inspection before next cycle.'
                : 'Milk yield is lower than usual. Check again at the next milking.',
            style: const TextStyle(fontSize: 11, height: 1.4),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: tap,
              icon: const Icon(Icons.health_and_safety_outlined, size: 16),
              label: const Text('Check Cow'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bars extends StatelessWidget {
  const _Bars(this.values);
  final List<double> values;
  @override
  Widget build(BuildContext context) {
    final max = values.reduce((a, b) => a > b ? a : b);
    return _Card(
      SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: values
              .map(
                (v) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          v.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 9),
                        ),
                        Container(
                          height: 76 * v / max,
                          decoration: BoxDecoration(
                            color: v == values.last
                                ? GauColors.forest
                                : const Color(0xFFD3DDD0),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text('•', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _Activity extends StatelessWidget {
  const _Activity(this.cows);
  final List<Cow> cows;
  @override
  Widget build(BuildContext context) => _Card(
    Column(
      children: cows
          .map(
            (c) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: GauColors.healthySurface,
                child: Icon(Icons.check, color: GauColors.forest),
              ),
              title: Text('${c.name} (${c.tag})'),
              subtitle: const Text('Milked recently · Simulated sensor node'),
              trailing: Text(
                '${c.todayMilkLitres.toStringAsFixed(1)} L',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _SampleDataPanel extends StatelessWidget {
  const _SampleDataPanel(this.samples);
  final List<Map<String, dynamic>> samples;
  @override
  Widget build(BuildContext context) {
    final latest = samples.first;
    final risk = latest['risk_category'] ?? 'No Risk';
    return _Card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${latest['cow_id']} · ${latest['reading_session']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Pill(
                risk.toString(),
                GauColors.forest,
                GauColors.healthySurface,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Info(
                  'Yield',
                  '${(latest['milk_yield_liters'] as num? ?? 0).toStringAsFixed(2)} L',
                  Icons.water_drop_outlined,
                  GauColors.forest,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Info(
                  'Conductivity',
                  '${(latest['milk_conductivity_ms_cm'] as num? ?? 0).toStringAsFixed(2)} mS/cm',
                  Icons.speed,
                  GauColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Info(
                  'Temp',
                  '${(latest['milk_temperature_c'] as num? ?? 0).toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  GauColors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Info(
                  'Risk',
                  (latest['risk_probability'] as num? ?? 0).toStringAsFixed(3),
                  Icons.monitor_heart,
                  GauColors.forest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Latest reading: ${latest['recorded_date']} ${latest['recorded_time']} · ${latest['mastitis_next_7_days']} risk in next 7 days',
            style: const TextStyle(fontSize: 11, color: Color(0xFF5C6B61)),
          ),
        ],
      ),
    );
  }
}

class _CowIcon extends StatelessWidget {
  const _CowIcon(this.cow);
  final Cow cow;
  @override
  Widget build(BuildContext context) => Container(
    width: 58,
    height: 58,
    decoration: BoxDecoration(
      color: GauColors.mint,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      Icons.pets,
      color: cow.risk == RiskLevel.attention ? GauColors.red : GauColors.forest,
      size: 32,
    ),
  );
}

class _RiskPill extends StatelessWidget {
  const _RiskPill(this.risk);
  final RiskLevel risk;
  @override
  Widget build(BuildContext context) {
    final red = risk == RiskLevel.attention;
    final amber = risk == RiskLevel.monitor;
    return _Pill(
      red ? '⚠ HIGH RISK' : risk.label.toUpperCase(),
      red
          ? GauColors.red
          : amber
          ? GauColors.amber
          : GauColors.forest,
      red
          ? GauColors.redSurface
          : amber
          ? GauColors.amberSurface
          : GauColors.healthySurface,
    );
  }
}

class _Sync extends StatelessWidget {
  const _Sync();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    color: const Color(0xFFE6F1E4),
    child: const Row(
      children: [
        Icon(Icons.circle, size: 9, color: Color(0xFF2E7D32)),
        SizedBox(width: 6),
        Text('Synced with Shed Sensor Hub', style: TextStyle(fontSize: 10)),
        Spacer(),
        Text('Just now', style: TextStyle(fontSize: 10)),
      ],
    ),
  );
}

class _CowHero extends StatelessWidget {
  const _CowHero(this.cow);
  final Cow cow;
  @override
  Widget build(BuildContext context) => _Card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 195,
          decoration: BoxDecoration(
            color: GauColors.mint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.pets, color: GauColors.forest, size: 95),
              ),
              const Positioned(
                top: 10,
                left: 10,
                child: _Pill('RFID VERIFIED', GauColors.forest, Colors.white),
              ),
              const Positioned(
                bottom: 10,
                right: 10,
                child: _Pill('Tag: COW-024', Colors.white, GauColors.ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                cow.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _RiskPill(cow.risk),
          ],
        ),
        Text('Tag: ${cow.tag} · ${cow.breed} · ${cow.age}'),
      ],
    ),
  );
}

class _Risk extends StatelessWidget {
  const _Risk();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: GauColors.redSurface,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MASTITIS RISK ASSESSMENT',
          style: TextStyle(
            fontSize: 10,
            color: GauColors.red,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'High Risk Indicator',
          style: TextStyle(
            fontSize: 19,
            color: GauColors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Early warning estimate based on yield shift and milk conductivity. Not a final medical diagnosis.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value, this.icon, this.color);
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => _Card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 7),
        Icon(icon, color: color),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _Timeline extends StatelessWidget {
  const _Timeline(this.items);
  final List<String> items;
  @override
  Widget build(BuildContext context) => _Card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Section('Timeline & Observations', 'Past 30 Days'),
        const SizedBox(height: 15),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: GauColors.forest,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    e,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Record extends StatelessWidget {
  const _Record(this.icon, this.title, this.note);
  final IconData icon;
  final String title, note;
  @override
  Widget build(BuildContext context) => _Card(
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: GauColors.forest),
      title: Text(title),
      subtitle: Text(note),
      trailing: const Icon(Icons.keyboard_arrow_down),
    ),
  );
}

class _Verified extends StatelessWidget {
  const _Verified(this.cow);
  final Cow cow;
  @override
  Widget build(BuildContext context) => _Card(
    Row(
      children: [
        _CowIcon(cow),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cow.name,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('Tag: ${cow.tag} · Breed: ${cow.breed}'),
            ],
          ),
        ),
        const _Pill('Verified', Color(0xFF2E7D32), GauColors.healthySurface),
      ],
    ),
  );
}

class _Connection extends StatelessWidget {
  const _Connection();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 14),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFE6F1E4),
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          '●  Farm Mesh Connected',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          '↻  Auto-logging enabled',
          style: TextStyle(
            color: GauColors.forest,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _Steps extends StatelessWidget {
  const _Steps();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(
        child: Column(
          children: [
            LinearProgressIndicator(value: 1, color: GauColors.forest),
            SizedBox(height: 5),
            Text('✓ 1. Cow', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Column(
          children: [
            LinearProgressIndicator(value: 1, color: GauColors.forest),
            SizedBox(height: 5),
            Text('✓ 2. Sensor', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: Column(
          children: [
            LinearProgressIndicator(value: 1, color: GauColors.forest),
            SizedBox(height: 5),
            Text('◉ 3. Milking', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ],
  );
}

class _Sensor extends StatelessWidget {
  const _Sensor();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: const Color(0xFFE1EBDE),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFFB3F1C3),
          child: Icon(Icons.sensors, color: GauColors.forest),
        ),
        SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensor Node #04',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            Text('Ready for session · Auto-releases on finish'),
          ],
        ),
      ],
    ),
  );
}

class _Big extends StatelessWidget {
  const _Big(this.label, this.value, this.note, this.icon);
  final String label, value, note;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      const SizedBox(height: 9),
      Text(
        value,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      ),
      Text(note, style: const TextStyle(fontSize: 10, color: GauColors.forest)),
    ],
  );
}

class _Session extends StatelessWidget {
  const _Session();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFFE6F1E4),
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Row(
      children: [
        Icon(Icons.circle, size: 9, color: Color(0xFF2E7D32)),
        SizedBox(width: 6),
        Text(
          'Session #0418 · Freshly Analyzed',
          style: TextStyle(fontSize: 11),
        ),
        Spacer(),
        Text(
          'Just Now',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _ResultCow extends StatelessWidget {
  const _ResultCow(this.cow);
  final Cow cow;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: _Card(
      Column(
        children: [
          Row(
            children: [
              _CowIcon(cow),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cow.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text('Tag: COW-024 · Shree Krishna Dairy'),
                  ],
                ),
              ),
              const _RiskPill(RiskLevel.monitor),
            ],
          ),
          const SizedBox(height: 13),
          const Row(
            children: [
              Icon(Icons.timer_outlined, size: 17),
              SizedBox(width: 7),
              Text(
                '8 min 15 sec · Session completed',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Warning extends StatelessWidget {
  const _Warning();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: GauColors.amberSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HEALTH INDICATOR',
          style: TextStyle(
            fontSize: 10,
            color: GauColors.amber,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Mastitis Early Warning',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 10),
        Text(
          'Sensors noted a noticeable flow-rate slow-down and milk volume variation compared to Gauri’s usual pattern.',
          style: TextStyle(height: 1.4),
        ),
      ],
    ),
  );
}

class _Yield extends StatelessWidget {
  const _Yield();
  @override
  Widget build(BuildContext context) => _Card(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TODAY’S MILK YIELD',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Row(
          children: [
            Text(
              '8.7',
              style: TextStyle(
                fontSize: 33,
                color: GauColors.forest,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Litres',
              style: TextStyle(fontSize: 18, color: GauColors.forest),
            ),
            Spacer(),
            _Pill('↘ -1.8 L', GauColors.red, GauColors.redSurface),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          '5-Day Yield Trajectory',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(
              5,
              (i) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    height: [71, 67, 61, 49, 38][i].toDouble(),
                    decoration: BoxDecoration(
                      color: i == 4
                          ? GauColors.red
                          : i == 3
                          ? GauColors.amber
                          : const Color(0xFF8CAF9A),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Recommendation extends StatelessWidget {
  const _Recommendation();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFE1EBDE),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment_turned_in, color: GauColors.forest),
            SizedBox(width: 8),
            Text(
              'Recommended Next Steps',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          'Check cow for signs of udder tenderness or inflammation and contact a veterinarian if symptoms persist.',
          style: TextStyle(height: 1.45),
        ),
        SizedBox(height: 13),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFB3F1C3),
              child: Icon(Icons.smart_toy, color: GauColors.forest),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ask GauSaathi Assistant',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: GauColors.forest,
                ),
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ],
    ),
  );
}
