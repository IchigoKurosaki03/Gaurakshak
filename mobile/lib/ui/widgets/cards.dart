import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'pressable.dart';

/// The base raised surface for the whole app.
///
/// Depth is carried by a hairline border + an ultra-soft ground shadow
/// (tonal elevation), never a heavy blur — blurred shadows wash out under
/// direct sunlight. Pass [onTap] to make the whole card a tappable target
/// with press-scale feedback.
class GauCard extends StatelessWidget {
  const GauCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.md),
    this.color = AppColors.card,
    this.elevation = 1,
    this.border = true,
    this.borderColor,
    this.radius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;

  /// 0 = flat, 1 = default card, 2 = interactive, 3 = sheet/sticky.
  final int elevation;
  final bool border;
  final Color? borderColor;
  final BorderRadius? radius;

  List<BoxShadow>? get _shadow => switch (elevation) {
    0 => null,
    1 => AppElevation.level1,
    2 => AppElevation.level2,
    _ => AppElevation.level3,
  };

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppRadii.card;
    return Pressable(
      onTap: onTap,
      borderRadius: r,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: r,
          border: border
              ? Border.all(color: borderColor ?? AppColors.hairline)
              : null,
          boxShadow: _shadow,
        ),
        child: child,
      ),
    );
  }
}

/// A card carrying a coloured left severity strip — used for cows needing
/// attention and for alerts, where the status must read at a glance.
class StripCard extends StatelessWidget {
  const StripCard({
    super.key,
    required this.child,
    required this.stripColor,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpace.md),
    this.elevation = 1,
  });

  final Widget child;
  final Color stripColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final int elevation;

  @override
  Widget build(BuildContext context) {
    return GauCard(
      onTap: onTap,
      elevation: elevation,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: stripColor,
                borderRadius: const BorderRadius.only(
                  topLeft: AppRadii.rLg,
                  bottomLeft: AppRadii.rLg,
                ),
              ),
            ),
            Expanded(
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
