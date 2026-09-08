import 'package:flutter/material.dart';

import '../ui/theme/tokens.dart';

abstract final class GauColors {
  static const forest = AppColors.forest;
  static const forestDark = AppColors.forestDeep;
  static const cream = AppColors.canvas;
  static const ink = AppColors.ink;
  static const mint = AppColors.mint;
  static const card = AppColors.card;
  static const amber = AppColors.monitor;
  static const amberSurface = AppColors.monitorSurface;
  static const red = AppColors.atRisk;
  static const redSurface = AppColors.atRiskSurface;
  static const healthySurface = AppColors.healthySurface;
  static const white = AppColors.onForest;
}

abstract final class GauSpace {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 28.0;
}

ThemeData gauTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: GauColors.cream,
  colorScheme: ColorScheme.fromSeed(
    seedColor: GauColors.forest,
    surface: GauColors.cream,
    error: GauColors.red,
  ),
  appBarTheme: const AppBarTheme(backgroundColor: GauColors.cream, foregroundColor: GauColors.ink),
  cardTheme: CardThemeData(
    color: GauColors.card,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0x141C251D)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF4EFE6),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFC0C9BF))),
  ),
);
