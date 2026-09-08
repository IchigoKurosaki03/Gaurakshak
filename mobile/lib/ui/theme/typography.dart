import 'package:flutter/material.dart';

import 'tokens.dart';

/// Typography scale, ported from `DESIGN.md`.
///
/// Font pairing:
/// - **Manrope** (headlines + metrics): geometric, sturdy, clear numerals for
///   reading vitals like `8.7 L` / `COW-024` at arm's length in the field.
/// - **Hanken Grotesk** (body + controls): tall x-height, open apertures that
///   stay legible on low-cost Android screens under sunlight glare.
///
/// Both are bundled variable fonts (see pubspec `fonts:`), so `fontWeight`
/// drives the `wght` axis directly — no runtime download, works offline.
class AppText {
  const AppText._();

  static const String _headline = 'Manrope';
  static const String _body = 'Hanken Grotesk';

  // --- Headlines & metrics (Manrope) ---
  static const TextStyle display = TextStyle(
    fontFamily: _headline,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 44 / 36,
    letterSpacing: -0.72,
    color: AppColors.ink,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: _headline,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.28,
    color: AppColors.ink,
  );

  /// Headline size tuned for narrow mobile widths.
  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: _headline,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.24,
    color: AppColors.ink,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: _headline,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 28 / 20,
    color: AppColors.ink,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: _headline,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.ink,
  );

  /// Large numerals (milk yield, counts). Tabular figures prevent card jitter
  /// during live updates.
  static const TextStyle metric = TextStyle(
    fontFamily: _headline,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 38 / 32,
    color: AppColors.ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // --- Body & controls (Hanken Grotesk) ---
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: AppColors.ink,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: _body,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 22 / 15,
    color: AppColors.ink,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AppColors.muted,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.14,
    color: AppColors.ink,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: _body,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.24,
    color: AppColors.muted,
  );

  /// Small uppercase eyebrow labels (e.g. "TODAY'S MILK YIELD").
  static const TextStyle labelSm = TextStyle(
    fontFamily: _body,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 14 / 11,
    letterSpacing: 0.44,
    color: AppColors.muted,
  );
}
