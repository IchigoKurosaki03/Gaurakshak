import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// Assembles the app-wide [ThemeData] from GauRakshak tokens.
///
/// Components generally style themselves directly from [AppColors] / [AppText]
/// for pixel-fidelity with the Stitch reference, but this base theme sets the
/// canvas, default text family/colour, and Material widget defaults so nothing
/// falls back to Material's stock blue/Roboto look.
ThemeData appTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.forest,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.forest,
    onPrimary: AppColors.onForest,
    primaryContainer: AppColors.mint,
    onPrimaryContainer: AppColors.forestDeep,
    surface: AppColors.canvas,
    onSurface: AppColors.ink,
    surfaceContainerHighest: AppColors.mintDim,
    outline: AppColors.outline,
    outlineVariant: AppColors.line,
    error: AppColors.error,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.canvas,
    fontFamily: 'Hanken Grotesk',
    splashFactory: InkRipple.splashFactory,
    textTheme: const TextTheme(
      displaySmall: AppText.display,
      headlineLarge: AppText.headlineLg,
      headlineMedium: AppText.headlineMd,
      headlineSmall: AppText.headlineSm,
      titleLarge: AppText.headlineSm,
      titleMedium: AppText.labelLg,
      bodyLarge: AppText.bodyLg,
      bodyMedium: AppText.bodyMd,
      bodySmall: AppText.bodySm,
      labelLarge: AppText.labelLg,
      labelMedium: AppText.labelMd,
      labelSmall: AppText.labelSm,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.headlineSm,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: AppColors.ink),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: AppColors.mint,
      labelTextStyle: WidgetStateProperty.resolveWith((states) => AppText.labelSm.copyWith(
        color: states.contains(WidgetState.selected) ? AppColors.ink : AppColors.muted,
        fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
      )),
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
        color: states.contains(WidgetState.selected) ? AppColors.ink : AppColors.muted,
      )),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.mint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: AppRadii.input, borderSide: const BorderSide(color: AppColors.line)),
      enabledBorder: OutlineInputBorder(borderRadius: AppRadii.input, borderSide: const BorderSide(color: AppColors.line)),
      focusedBorder: OutlineInputBorder(borderRadius: AppRadii.input, borderSide: const BorderSide(color: AppColors.forest, width: 2)),
    ),
  );
}
