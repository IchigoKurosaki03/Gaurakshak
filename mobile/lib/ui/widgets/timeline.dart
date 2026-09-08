import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// One event on a vertical timeline (health checks, milking sessions,
/// sync events on a cow profile).
class TimelineEntry {
  const TimelineEntry({
    required this.title,
    this.detail,
    this.time,
    this.color = AppColors.forest,
    this.icon,
  });

  final String title;
  final String? detail;
  final String? time;
  final Color color;
  final IconData? icon;
}

/// Vertical, connector-linked timeline. Each node is a coloured dot (or icon)
/// on a hairline rail with the event content to its right.
class GauTimeline extends StatelessWidget {
  const GauTimeline({super.key, required this.entries});

  /// Convenience for the plain `List<String>` carried on [Cow.timeline].
  factory GauTimeline.fromStrings(List<String> lines, {Key? key}) => GauTimeline(
    key: key,
    entries: [for (final l in lines) TimelineEntry(title: l)],
  );

  final List<TimelineEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(entry: entries[i], isLast: i == entries.length - 1),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});

  final TimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: entry.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: entry.icon != null
                    ? Icon(entry.icon, size: 13, color: entry.color)
                    : Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: entry.color,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.line),
                ),
            ],
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: AppText.labelLg.copyWith(color: AppColors.ink),
                        ),
                      ),
                      if (entry.time != null)
                        Text(entry.time!, style: AppText.labelSm),
                    ],
                  ),
                  if (entry.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(entry.detail!, style: AppText.bodySm),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
