import 'package:flutter/material.dart';

import 'screens/stitch_app.dart';
import 'state/farm_state.dart';
import 'theme/gau_theme.dart';

void main() => runApp(const GauRakshakApp());

class GauRakshakApp extends StatefulWidget {
  const GauRakshakApp({super.key});

  @override
  State<GauRakshakApp> createState() => _GauRakshakAppState();
}

class _GauRakshakAppState extends State<GauRakshakApp> {
  final FarmState _farmState = FarmState();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'GauRakshak',
    theme: gauTheme(),
    home: StitchApp(state: _farmState),
  );
}
