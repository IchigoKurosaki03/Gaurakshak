import 'package:flutter/material.dart';

import '../../models/domain.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Visual style for the non-clinical health triad. Status is ALWAYS shown as
/// icon + text (never colour alone) per the design system.
class RiskStyle {
  const RiskStyle(this.label, this.color, this.surface, this.icon);

  final String label;
  final Color color;
  final Color surface;
  final IconData icon;

  static RiskStyle of(RiskLevel level) => switch (level) {
    RiskLevel.healthy => const RiskStyle(
      'Healthy',
      AppColors.healthy,
      AppColors.healthySurface,
      Icons.check_circle_rounded,
    ),
    RiskLevel.monitor => const RiskStyle(
      'Monitor',
      AppColors.monitor,
      AppColors.monitorSurface,
      Icons.warning_amber_rounded,
    ),
    RiskLevel.attention => const RiskStyle(
      'At Risk',
      AppColors.atRisk,
      AppColors.atRiskSurface,
      Icons.report_rounded,
    ),
    RiskLevel.insufficientHistory => const RiskStyle(
      'New',
      AppColors.muted,
      AppColors.mint,
      Icons.hourglass_empty_rounded,
    ),
  };
}

/// Icon + text status pill (e.g. "⚠ Monitor").
class StatusPill extends StatelessWidget {
  const StatusPill(this.level, {super.key, this.dense = false});

  final RiskLevel level;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final style = RiskStyle.of(level);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpace.xs : AppSpace.sm,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: style.surface,
        borderRadius: AppRadii.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: dense ? 13 : 15, color: style.color),
          const SizedBox(width: 5),
          Text(
            style.label.toUpperCase(),
            style: AppText.labelSm.copyWith(color: style.color),
          ),
        ],
      ),
    );
  }
}

/// Maps a free-text trend word ("Increasing" / "Decreasing" / "Stable") to a
/// direction icon. Colour is intentionally left to the caller — a rising
/// *milk* trend is good while a rising *risk* trend is not, so meaning depends
/// on context.
IconData trendIcon(String trend) {
  final t = trend.toLowerCase();
  if (t.contains('incre') || t.contains('ris') || t.contains('up')) {
    return Icons.trending_up_rounded;
  }
  if (t.contains('decre') || t.contains('fall') || t.contains('down') ||
      t.contains('drop')) {
    return Icons.trending_down_rounded;
  }
  return Icons.trending_flat_rounded;
}

/// Connectivity states surfaced calmly in headers — never technical.
enum ConnectivityState { online, syncing, offline }

extension ConnectivityStyle on ConnectivityState {
  Color get color => switch (this) {
    ConnectivityState.online => AppColors.online,
    ConnectivityState.syncing => AppColors.syncing,
    ConnectivityState.offline => AppColors.offline,
  };

  IconData get icon => switch (this) {
    ConnectivityState.online => Icons.cloud_done_rounded,
    ConnectivityState.syncing => Icons.sync_rounded,
    ConnectivityState.offline => Icons.cloud_off_rounded,
  };

  String get label => switch (this) {
    ConnectivityState.online => 'Online • Synced',
    ConnectivityState.syncing => 'Syncing…',
    ConnectivityState.offline => 'Offline • Saved on device',
  };
}

/// Compact connectivity pill for app headers.
class ConnectivityPill extends StatelessWidget {
  const ConnectivityPill(this.state, {super.key, this.label});

  final ConnectivityState state;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(state.icon, size: 13, color: state.color),
        const SizedBox(width: 5),
        Text(
          (label ?? state.label).toUpperCase(),
          style: AppText.labelSm.copyWith(color: state.color),
        ),
      ],
    );
  }
}
