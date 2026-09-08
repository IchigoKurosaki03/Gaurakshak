import 'package:flutter/widgets.dart';

/// GauRakshak design tokens.
///
/// Values are ported verbatim from the approved design system
/// (`gaurakshak_design_system/DESIGN.md`) and the Stitch prototype
/// (`flow.css`). Do not hand-tune colours here; adjust the design system and
/// re-port so the app and the reference prototype stay in lockstep.
///
/// Aesthetic: "Elevated Tactile Agri-Tech" — warm, trustworthy, agricultural.
/// Deep forest greens grounded by soft mint/cream surfaces, sunlight-legible
/// contrast, tonal elevation with crisp hairline borders (no heavy blur).
class AppColors {
  const AppColors._();

  // --- Brand / primary ---
  /// Primary CTAs, app bars, active states. flow.css `--forest`.
  static const Color forest = Color(0xFF034525);

  /// Pressed / deep brand tone. `--deep`, brand-forest-dark.
  static const Color forestDeep = Color(0xFF1A4D2E);

  /// Slightly lighter primary container.
  static const Color primaryContainer = Color(0xFF235D3A);

  // --- Surfaces ---
  /// Android feed canvas. White keeps dense field data easy to scan and gives
  /// GauRakshak its own clean, social-style rhythm without copying a brand.
  static const Color canvas = Color(0xFFFFFFFF);

  /// Warm dairy-cream alternative surface (avoids stark white).
  static const Color cream = Color(0xFFF9F8F3);

  /// Default raised card fill.
  static const Color card = Color(0xFFFFFFFF);

  /// Muted mint container fill for passive chips / secondary buttons.
  static const Color mint = Color(0xFFF1F6F1);

  /// Secondary container (data chips, sub-headers).
  static const Color mintDim = Color(0xFFE3EEE5);

  // --- Lines / text ---
  /// Hairline borders and dividers. `--line`.
  static const Color line = Color(0xFFDBE5D9);

  /// Slightly stronger outline for inputs.
  static const Color outline = Color(0xFFC0C9BF);

  /// Primary text on light surfaces. `--ink`.
  static const Color ink = Color(0xFF151E16);

  /// Secondary / muted text. `--muted`.
  static const Color muted = Color(0xFF5C6761);

  /// Text/icons on forest surfaces.
  static const Color onForest = Color(0xFFFFFFFF);

  // --- Status triad (always pair with an icon + text, never colour alone) ---
  static const Color healthy = Color(0xFF2E7D32);
  static const Color healthySurface = Color(0xFFEAF5EA);
  static const Color monitor = Color(0xFFE67E22);
  static const Color monitorSurface = Color(0xFFFEF5E7);
  static const Color atRisk = Color(0xFFD9534F);
  static const Color atRiskSurface = Color(0xFFFDF2F2);

  // --- Connectivity signals ---
  static const Color online = Color(0xFF2E7D32);
  static const Color syncing = Color(0xFF2980B9);
  static const Color offline = Color(0xFF7F8C8D);

  // --- System ---
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorSurface = Color(0xFFFFDAD6);

  // --- Hairline / shadow inks (tonal elevation) ---
  static const Color hairline = Color(0x12151E16); // rgba(21,30,22,0.07)
  static const Color shadowSoft = Color(0x0A1C251D); // rgba(28,37,29,0.04)
  static const Color shadowMid = Color(0x141C251D); // rgba(28,37,29,0.08)
  static const Color shadowStrong = Color(0x1F1C251D); // rgba(28,37,29,0.12)
}

/// 4px / 8px spatial grid. Values in logical pixels.
class AppSpace {
  const AppSpace._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Absolute minimum tappable height (wet/gloved hands).
  static const double touchMin = 48;

  /// Comfortable height for primary operational buttons ("Start Milking").
  static const double touchComfortable = 54;

  /// Fixed page gutter on mobile.
  static const double pageMargin = 16;

  /// Default interior padding for cards.
  static const double cardPadding = 16;

  /// Gutter between grid cells.
  static const double gridGutter = 12;

  /// Content max width — the design caps at a phone-sheet width on tablets.
  static const double contentMaxWidth = 680;
}

/// Corner radii. The interface communicates approachability via a 16px base.
class AppRadii {
  const AppRadii._();

  static const double sm = 4;
  static const double md = 12;

  /// Cards, inputs, primary CTAs.
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 9999;

  static const Radius rLg = Radius.circular(lg);
  static const BorderRadius card = BorderRadius.all(rLg);
  static const BorderRadius input = BorderRadius.all(Radius.circular(12));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

/// Tonal elevation. Blurred shadows wash out in sunlight, so depth is carried
/// mostly by hairline outlines plus an ultra-soft ground shadow.
class AppElevation {
  const AppElevation._();

  /// Level 1 — default card.
  static const List<BoxShadow> level1 = [
    BoxShadow(color: AppColors.shadowSoft, blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Level 2 — interactive / active-session cards.
  static const List<BoxShadow> level2 = [
    BoxShadow(color: AppColors.shadowMid, blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Level 3 — modals, action sheets, sticky scan bars.
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: AppColors.shadowStrong,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

/// Motion tokens. Intentional, not decorative.
class AppMotion {
  const AppMotion._();

  /// Splash opening sequence (cow → milking → milk drop → app).
  static const Duration splash = Duration(milliseconds: 2400);

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve standard = Curves.easeInOut;

  /// Press feedback scale for tactile buttons/cards.
  static const double pressScale = 0.98;
}
