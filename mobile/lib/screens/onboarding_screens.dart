import 'dart:async';

import 'package:flutter/material.dart';

import '../models/domain.dart';
import '../state/farm_state.dart';
import '../theme/gau_theme.dart';
import '../widgets/app_widgets.dart';
import 'home_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.state});
  final FarmState state;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(vsync: this, duration: const Duration(seconds: 2))..forward();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2300), () {
      if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen(state: widget.state)));
    });
  }
  @override
  void dispose() { _timer?.cancel(); _animation.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: GauColors.forest,
    body: AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.agriculture_rounded, size: 88, color: GauColors.white),
        const SizedBox(height: 16),
        const Text('GauRakshak', style: TextStyle(color: GauColors.white, fontSize: 36, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8), Text('Health care, one cow at a time', style: TextStyle(color: GauColors.white.withValues(alpha: .75))),
        const SizedBox(height: 44), Transform.scale(scale: .6 + _animation.value * .4, child: const Icon(Icons.water_drop, color: GauColors.white, size: 56)),
      ])),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.state});
  final FarmState state;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController(text: '9876543210');
  @override
  void dispose() { _phone.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(
    padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Spacer(), const Brand(), const SizedBox(height: 38),
      const Text('Welcome back', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
      const Text('Use your phone number to see your herd.'), const SizedBox(height: 30),
      AppField(label: 'Mobile number', controller: _phone, hint: '+91  10-digit number', keyboardType: TextInputType.phone),
      PrimaryButton(label: 'Send one-time password', icon: Icons.arrow_forward, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OtpScreen(state: widget.state, phone: _phone.text)))),
      const SizedBox(height: 14), const Center(child: Text('Demo mode works without network access.')), const Spacer(),
    ]),
  )));
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.state, required this.phone});
  final FarmState state;
  final String phone;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otp = TextEditingController();
  @override
  void dispose() { _otp.dispose(); super.dispose(); }
  void _verify() {
    if (_otp.text == '123456') {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => FarmSetupScreen(state: widget.state)), (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use 123456 for the demo.')));
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(), body: Padding(
    padding: const EdgeInsets.all(28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 35), const Text('Confirm your number', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10), Text('Enter the code sent to +91 ${widget.phone}.'), const SizedBox(height: 30),
      AppField(label: 'One-time password', controller: _otp, hint: '123456', keyboardType: TextInputType.number),
      PrimaryButton(label: 'Continue', onPressed: _verify), const SizedBox(height: 17),
      const Center(child: Text('Demo OTP: 123456', style: TextStyle(color: GauColors.forest, fontWeight: FontWeight.w800))),
    ]),
  ));
}

class FarmSetupScreen extends StatefulWidget {
  const FarmSetupScreen({super.key, required this.state});
  final FarmState state;
  @override
  State<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends State<FarmSetupScreen> {
  late final _name = TextEditingController(text: widget.state.farm.name);
  late final _location = TextEditingController(text: widget.state.farm.location);
  late final _count = TextEditingController(text: '${widget.state.farm.herdSize}');
  @override
  void dispose() { _name.dispose(); _location.dispose(); _count.dispose(); super.dispose(); }
  void _continue() {
    final count = int.tryParse(_count.text);
    if (_name.text.trim().isEmpty || _location.text.trim().isEmpty || count == null || count < 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add your farm name, location and number of cows.')));
      return;
    }
    widget.state.setupFarm(_name.text.trim(), _location.text.trim(), count);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AddCowScreen(state: widget.state, firstCow: true)));
  }
  @override
  Widget build(BuildContext context) => _SetupScaffold(step: 1, title: 'Set up your farm', subtitle: 'Only the basics for now. Add detailed records later.', child: Column(children: [
    AppField(label: 'Farm name', controller: _name, hint: 'e.g. Shree Krishna Dairy'),
    AppField(label: 'Farm location', controller: _location, hint: 'e.g. Pune, Maharashtra'),
    AppField(label: 'Number of cows', controller: _count, hint: 'e.g. 24', keyboardType: TextInputType.number),
    const AppHint(icon: Icons.edit_note, message: 'You can complete medical history, calving, vaccination and feed details later.'),
    PrimaryButton(label: 'Continue to add a cow', onPressed: _continue),
  ]));
}

class AddCowScreen extends StatefulWidget {
  const AddCowScreen({super.key, required this.state, this.firstCow = false});
  final FarmState state;
  final bool firstCow;
  @override
  State<AddCowScreen> createState() => _AddCowScreenState();
}

class _AddCowScreenState extends State<AddCowScreen> {
  final _name = TextEditingController(); final _tag = TextEditingController(); final _breed = TextEditingController(); final _age = TextEditingController();
  bool _more = false;
  @override
  void dispose() { for (final controller in [_name, _tag, _breed, _age]) { controller.dispose(); } super.dispose(); }
  void _save() {
    if ([_name, _tag, _breed, _age].any((controller) => controller.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add name, tag, breed and age.'))); return;
    }
    widget.state.addCow(Cow(name: _name.text.trim(), tag: _tag.text.trim().toUpperCase(), breed: _breed.text.trim(), age: '${_age.text.trim()} years', todayMilkLitres: 0, risk: RiskLevel.insufficientHistory, trend: 'No history yet', factors: [], timeline: ['Today: Profile created']));
    if (widget.firstCow) { Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen(state: widget.state)), (_) => false); } else { Navigator.pop(context); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Add a cow')), body: ListView(padding: const EdgeInsets.all(22), children: [
    const ProgressStrip(step: 2), const SizedBox(height: 20), const Text('Create the digital profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text('Start with the details needed for a safe milking session.'), const SizedBox(height: 24),
    AppField(label: 'Cow name', controller: _name, hint: 'e.g. Lakshmi'), AppField(label: 'QR / RFID / ear-tag ID', controller: _tag, hint: 'e.g. COW-025'), AppField(label: 'Breed', controller: _breed, hint: 'e.g. Gir'), AppField(label: 'Age', controller: _age, hint: 'e.g. 4', keyboardType: TextInputType.number),
    SwitchListTile(contentPadding: EdgeInsets.zero, value: _more, onChanged: (value) => setState(() => _more = value), title: const Text('Add medical details now'), subtitle: const Text('Optional: vaccination, calving, feed and treatment')),
    if (_more) const AppHint(icon: Icons.health_and_safety_outlined, message: 'Detailed health records can be edited from the cow profile after saving.'),
    PrimaryButton(label: widget.firstCow ? 'Open my dashboard' : 'Save cow', onPressed: _save),
  ]));
}

class _SetupScaffold extends StatelessWidget {
  const _SetupScaffold({required this.step, required this.title, required this.subtitle, required this.child});
  final int step; final String title; final String subtitle; final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(), body: ListView(padding: const EdgeInsets.all(24), children: [
    ProgressStrip(step: step), const SizedBox(height: 25), Text(title, style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Text(subtitle), const SizedBox(height: 28), child,
  ]));
}
