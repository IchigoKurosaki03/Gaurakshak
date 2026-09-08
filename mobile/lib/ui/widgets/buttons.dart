import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'pressable.dart';

/// Solid forest CTA — the single most important action on a screen
/// ("Start Milking", "Call Vet"). Comfortable 54px touch target for gloved,
/// wet hands. Full-width by default.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
    this.loading = false,
    this.color = AppColors.forest,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool loading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Pressable(
      onTap: enabled ? onPressed : null,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        child: AnimatedOpacity(
          duration: AppMotion.fast,
          opacity: enabled ? 1 : 0.5,
          child: Container(
            height: AppSpace.touchComfortable,
            width: expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadii.card,
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              loading: loading,
              foreground: AppColors.onForest,
            ),
          ),
        ),
      ),
    );
  }
}

/// Mint-filled, hairline-bordered secondary action ("Log Check", "Save").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Pressable(
      onTap: enabled ? onPressed : null,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        child: AnimatedOpacity(
          duration: AppMotion.fast,
          opacity: enabled ? 1 : 0.5,
          child: Container(
            height: AppSpace.touchComfortable,
            width: expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: AppRadii.card,
              border: Border.all(color: AppColors.line),
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              loading: loading,
              foreground: AppColors.forest,
            ),
          ),
        ),
      ),
    );
  }
}

/// Low-emphasis text action ("Skip", "Not now"). Use sparingly.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color = AppColors.forest,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onPressed,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        label: label,
        child: Container(
          height: AppSpace.touchMin,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: AppSpace.xs),
              ],
              Text(label, style: AppText.labelLg.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.foreground,
    this.icon,
    this.loading = false,
  });

  final String label;
  final Color foreground;
  final IconData? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation(foreground),
          ),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: AppSpace.xs),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppText.labelLg.copyWith(
              color: foreground,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
