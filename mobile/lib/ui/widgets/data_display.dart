import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// Section title with an optional small eyebrow above it and an optional
/// trailing action ("See all"). Keeps vertical rhythm consistent between
/// stacked sections.
class SectionHeader extends StatelessWidget {
  const SectionHeader(
    this.title, {
    super.key,
    this.eyebrow,
    this.trailing,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null) ...[
                  Text(eyebrow!.toUpperCase(), style: AppText.labelSm),
                  const SizedBox(height: AppSpace.xxs),
                ],
                Text(title, style: AppText.headlineSm),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A single headline metric — big numeral + caption — for the herd overview
/// grid (Total / Healthy / Monitor / At Risk) and similar summaries.
class MetricCell extends StatelessWidget {
  const MetricCell({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.ink,
    this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppText.metric.copyWith(color: color)),
        const SizedBox(height: 2),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: AppText.labelSm,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A small stacked label→value pair ("Today's Milk" / "8.7 L") used inside
/// profile and result cards.
class LabeledValue extends StatelessWidget {
  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    this.valueStyle,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppText.labelSm),
        const SizedBox(height: AppSpace.xxs),
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor ?? AppColors.forest),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                style: valueStyle ?? AppText.headlineSm,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Lightweight bar chart for milk-yield history (7-day herd, 5-day cow).
/// Deliberately dependency-free: proportional bars with rounded tops, an
/// optional highlighted bar, and day labels beneath.
class GauBarChart extends StatelessWidget {
  const GauBarChart({
    super.key,
    required this.values,
    required this.labels,
    this.highlightIndex,
    this.height = 132,
    this.barColor = AppColors.forest,
    this.highlightColor = AppColors.monitor,
    this.trackColor = AppColors.mint,
    this.showValues = false,
    this.unit = '',
  });

  final List<double> values;
  final List<String> labels;
  final int? highlightIndex;
  final double height;
  final Color barColor;
  final Color highlightColor;
  final Color trackColor;
  final bool showValues;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _Bar(
                  factor: (values[i] / safeMax).clamp(0.04, 1.0),
                  label: i < labels.length ? labels[i] : '',
                  valueLabel: showValues
                      ? '${_fmt(values[i])}$unit'
                      : null,
                  color: i == highlightIndex ? highlightColor : barColor,
                  trackColor: trackColor,
                  emphasized: i == highlightIndex,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _fmt(double v) =>
      v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.factor,
    required this.label,
    required this.color,
    required this.trackColor,
    this.valueLabel,
    this.emphasized = false,
  });

  final double factor;
  final String label;
  final Color color;
  final Color trackColor;
  final String? valueLabel;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (valueLabel != null) ...[
          Text(
            valueLabel!,
            style: AppText.labelSm.copyWith(
              color: emphasized ? color : AppColors.muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: factor,
              child: AnimatedContainer(
                duration: AppMotion.slow,
                curve: AppMotion.emphasized,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: AppText.labelSm.copyWith(
            color: emphasized ? AppColors.ink : AppColors.muted,
          ),
        ),
      ],
    );
  }
}
