import 'package:flutter/material.dart';

import '../../models/domain.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'cards.dart';
import 'status.dart';

/// An alert row with a left severity strip. Severity is passed in (derived by
/// the screen from the referenced cow's risk) since [FarmAlert] itself is a
/// plain message.
class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    this.severity = RiskLevel.monitor,
    this.time,
    this.onTap,
    this.onDismiss,
  });

  final FarmAlert alert;
  final RiskLevel severity;
  final String? time;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final style = RiskStyle.of(severity);
    return StripCard(
      onTap: onTap,
      stripColor: style.color,
      padding: const EdgeInsets.all(AppSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: style.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, size: 18, color: style.color),
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      alert.cowTag,
                      style: AppText.labelLg.copyWith(color: AppColors.ink),
                    ),
                    if (time != null) ...[
                      const Spacer(),
                      Text(time!, style: AppText.labelSm),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(alert.message, style: AppText.bodyMd),
              ],
            ),
          ),
          if (onDismiss != null)
            Padding(
              padding: const EdgeInsets.only(left: AppSpace.xs),
              child: GestureDetector(
                onTap: onDismiss,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
