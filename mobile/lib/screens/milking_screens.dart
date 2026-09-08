import 'dart:async';

import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/farm_state.dart';
import '../theme/gau_theme.dart';
import '../widgets/app_widgets.dart';
import 'home_screens.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.state, this.cow});

  final FarmState state;
  final Cow? cow;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late Cow? _selected = widget.cow;
  final _tag = TextEditingController();
  bool _starting = false;

  @override
  void dispose() {
    _tag.dispose();
    super.dispose();
  }

  void _locate() {
    final match = widget.state.cowByTag(_tag.text.trim());
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cow with that tag on your farm.')),
      );
      return;
    }
    setState(() => _selected = match);
  }

  Future<void> _beginSession() async {
    final selectedCow = _selected;
    if (selectedCow == null || _starting) return;
    var cow = selectedCow;
    setState(() => _starting = true);
    if (widget.state.authToken != null && widget.state.authToken!.isNotEmpty) {
      cow = await widget.state.startBackendSession(cow.tag) ?? cow;
    }
    if (!mounted) return;
    if (widget.state.currentSession == null ||
        widget.state.currentSession!.cowTag != cow.tag) {
      widget.state.startDemoSession(cow);
    }
    setState(() => _selected = cow);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MilkingSessionScreen(state: widget.state, cow: cow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start milking')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const ProgressStrip(step: 3),
          const SizedBox(height: 18),
          const Text(
            'Identify the cow',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scan a QR or RFID tag. In this demo, enter a tag or select a cow.',
          ),
          const SizedBox(height: 22),
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: GauColors.ink,
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, color: GauColors.white, size: 62),
                  SizedBox(height: 8),
                  Text(
                    'Simulated QR / RFID reader',
                    style: TextStyle(
                      color: GauColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tag,
                  decoration: const InputDecoration(
                    hintText: 'Enter tag, e.g. COW-024',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _locate,
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            children: widget.state.cows
                .map(
                  (cow) => ChoiceChip(
                    label: Text('${cow.name} • ${cow.tag}'),
                    selected: _selected == cow,
                    onSelected: (_) => setState(() => _selected = cow),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          if (_selected == null)
            const AppHint(
              icon: Icons.info_outline,
              message: 'Verify a cow before simulated sensor data is attached.',
            )
          else
            _ConfirmedCow(cow: _selected!),
          const SizedBox(height: 15),
          PrimaryButton(
            label: _selected == null
                ? 'Verify a cow first'
                : 'Associate sensor and begin',
            icon: Icons.sensors,
            onPressed: _selected == null || _starting ? null : _beginSession,
          ),
        ],
      ),
    );
  }
}

class _ConfirmedCow extends StatelessWidget {
  const _ConfirmedCow({required this.cow});

  final Cow cow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: GauColors.mint,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          CowAvatar(cow: cow),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cow.name} verified',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('${cow.tag} • ${cow.breed}'),
              ],
            ),
          ),
          const Icon(Icons.verified, color: GauColors.forest),
        ],
      ),
    );
  }
}

class MilkingSessionScreen extends StatefulWidget {
  const MilkingSessionScreen({
    super.key,
    required this.state,
    required this.cow,
  });

  final FarmState state;
  final Cow cow;

  @override
  State<MilkingSessionScreen> createState() => _MilkingSessionScreenState();
}

class _MilkingSessionScreenState extends State<MilkingSessionScreen> {
  bool _running = false;
  double _progress = 0;
  Timer? _timer;

  void _start() {
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(milliseconds: 450), (timer) async {
      if (!mounted) return;
      setState(() => _progress += .16);
      if (_progress >= 1) {
        timer.cancel();
        await widget.state.recordSessionReading(widget.cow);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(state: widget.state, cow: widget.cow),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Milking session')),
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProgressStrip(step: 4),
            const SizedBox(height: 22),
            Text(
              '${widget.cow.name} is verified',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Tag ${widget.cow.tag} • NODE-03 is assigned to this demo session.',
            ),
            const SizedBox(height: 26),
            const AppHint(
              icon: Icons.science_outlined,
              message:
                  'Simulated sensor data: milk yield, conductivity, temperature and activity are attached to this cow.',
            ),
            const SizedBox(height: 25),
            if (!_running) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(27),
                decoration: BoxDecoration(
                  color: GauColors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.sensors, color: GauColors.forest, size: 54),
                    SizedBox(height: 10),
                    Text(
                      'Demo sensor ready',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'You can put the phone aside after starting.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Start simulated milking',
                icon: Icons.play_arrow,
                onPressed: _start,
              ),
            ] else ...[
              const SizedBox(height: 38),
              Center(
                child: SizedBox(
                  height: 132,
                  width: 132,
                  child: CircularProgressIndicator(
                    value: _progress.clamp(0, 1),
                    strokeWidth: 10,
                    color: GauColors.forest,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Center(
                child: Text(
                  'Collecting simulated readings…',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key, required this.state, required this.cow});

  final FarmState state;
  final Cow cow;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  static const _stages = [
    'Collecting cow data',
    'Checking recent milk trends',
    'Comparing cow baseline',
    'Analyzing sensor readings',
    'Checking health history',
    'Generating early-warning risk estimate',
  ];

  int _stage = 0;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    for (var index = 0; index < _stages.length - 1; index++) {
      await Future<void>.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      setState(() => _stage = index + 1);
    }
    await widget.state.completeSessionPrediction(widget.cow);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RiskResultScreen(state: widget.state, cow: widget.cow),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.chat_bubble_outline, color: GauColors.forest, size: 54),
                const SizedBox(height: 18),
                const Text('GauRakshak is checking the pattern', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('For ${widget.cow.name} • ${widget.cow.tag}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 26),
                LinearProgressIndicator(value: (_stage + 1) / _stages.length, minHeight: 8, borderRadius: BorderRadius.circular(99), color: GauColors.forest),
                const SizedBox(height: 20),
                ..._stages.asMap().entries.map((entry) {
                  final complete = entry.key < _stage;
                  final active = entry.key == _stage;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(complete ? Icons.check_circle : active ? Icons.sync : Icons.radio_button_unchecked, size: 20, color: complete || active ? GauColors.forest : Colors.black26),
                        const SizedBox(width: 10),
                        Text(entry.value, style: TextStyle(fontWeight: active ? FontWeight.w800 : FontWeight.w500, color: active ? GauColors.ink : Colors.black54)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text('Prototype early-warning estimate • not a diagnosis', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RiskResultScreen extends StatelessWidget {
  const RiskResultScreen({
    super.key,
    required this.state,
    required this.cow,
  });

  final FarmState state;
  final Cow cow;

  @override
  Widget build(BuildContext context) {
    final prediction = state.latestPrediction;
    final risk = prediction?.risk ?? cow.risk;
    final score = prediction?.riskScore ?? 0;
    final factors = prediction?.factors ?? cow.factors;
    final insufficient = risk == RiskLevel.insufficientHistory;
    final headline = insufficient ? 'More history needed' : '${risk.label} risk';
    final action = insufficient
        ? 'The system needs more observations before providing a useful early-warning estimate.'
        : risk == RiskLevel.attention
        ? 'Continue close monitoring and check the cow for visible symptoms. Contact a veterinarian if symptoms are present.'
        : 'Continue regular milking checks and monitor changes in the cow’s pattern.';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const SizedBox(height: 15),
            const Text(
              'Early-warning result',
              style: TextStyle(color: GauColors.forest, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              '${cow.name} • ${cow.tag}',
              style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: riskColor(risk),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Icon(riskIcon(risk), color: GauColors.white, size: 57),
                  const SizedBox(height: 8),
                  const Text('MASTITIS RISK', style: TextStyle(color: Colors.white70, letterSpacing: 1.4, fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    headline,
                    style: const TextStyle(
                      color: GauColors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    insufficient ? 'Risk score unavailable' : 'Risk score: $score / 100',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prediction?.trend ?? cow.trend,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                    child: const Text('Prototype signal • not a diagnosis', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader('Why this risk'),
            if (factors.isEmpty)
              const Text('No significant changes detected.')
            else
              ...factors.map(
                (factor) => _Factor(icon: Icons.insights_outlined, text: factor),
              ),
            const SizedBox(height: 18),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fact_check_outlined, color: GauColors.forest),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('What to do next', style: TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(action, style: const TextStyle(color: Colors.black54, height: 1.35))])),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppHint(
              icon: Icons.medical_information_outlined,
              message: 'Use this estimate to decide what to check next. It does not replace a veterinarian’s assessment.',
              color: const Color(0xFFF8EBD4),
            ),
            PrimaryButton(
              label: 'Save result and view dashboard',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen(state: state)),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Factor extends StatelessWidget {
  const _Factor({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7E6E4),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: GauColors.red),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
