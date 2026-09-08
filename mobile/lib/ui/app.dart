import 'package:flutter/material.dart';

import '../state/farm_state.dart';
import '../screens/home_screens.dart';
import 'screens/onboarding/farm_setup_screen.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/splash_screen.dart';
import 'ui.dart';

/// Root of the rebuilt GauRakshak UI. Owns the single [FarmState] instance
/// (the working data layer we kept) and applies [appTheme].
class GauRakshakApp extends StatefulWidget {
  const GauRakshakApp({super.key});

  @override
  State<GauRakshakApp> createState() => _GauRakshakAppState();
}

class _GauRakshakAppState extends State<GauRakshakApp> {
  final FarmState _state = FarmState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _state,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GauRakshak',
        locale: Locale(_state.language.code),
        theme: appTheme(),
        home: RootGate(state: _state),
      ),
    );
  }
}

/// Sequences the app's entry: splash → sign-in → (farm setup) → shell.
/// A returning farmer whose farm already exists on the backend skips setup.
class RootGate extends StatefulWidget {
  const RootGate({super.key, required this.state});

  final FarmState state;

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  // Show the short farmer/milking intro before sign-in. The splash itself is
  // skippable and falls back to the bundled GIF when video playback is not
  // available (notably Flutter web autoplay restrictions).
  bool _splashDone = false;
  bool _authed = false;
  bool _setupDone = false;

  @override
  Widget build(BuildContext context) {
    final Widget screen;
    if (!_splashDone) {
      screen = SplashScreen(
        key: const ValueKey('splash'),
        onComplete: () => setState(() => _splashDone = true),
      );
    } else if (!_authed) {
      screen = LoginScreen(
        key: const ValueKey('login'),
        state: widget.state,
        onAuthenticated: () => setState(() {
          _authed = true;
          // Keep the farm profile step visible so today's farm details can be
          // confirmed or updated after signing in.
          _setupDone = false;
        }),
      );
    } else if (!_setupDone) {
      screen = FarmSetupScreen(
        key: const ValueKey('setup'),
        state: widget.state,
        onDone: () => setState(() => _setupDone = true),
        onBack: () => setState(() => _authed = false),
      );
    } else {
      screen = HomeScreen(key: const ValueKey('shell'), state: widget.state);
    }

    return AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.emphasized,
      switchOutCurve: AppMotion.standard,
      child: screen,
    );
  }
}
