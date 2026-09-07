import 'package:flutter/material.dart';

abstract final class GauColors {
  static const forest = Color(0xFF034525);
  static const forestDark = Color(0xFF1A4D2E);
  static const cream = Color(0xFFF2FCEF);
  static const ink = Color(0xFF151E16);
  static const mint = Color(0xFFE8F3EB);
  static const card = Color(0xFFFFFFFF);
  static const amber = Color(0xFFE67E22);
  static const amberSurface = Color(0xFFFEF5E7);
  static const red = Color(0xFFD9534F);
  static const redSurface = Color(0xFFFDF2F2);
  static const healthySurface = Color(0xFFEAF5EA);
  static const white = Colors.white;
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
