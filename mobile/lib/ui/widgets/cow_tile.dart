import 'package:flutter/material.dart';

import '../../models/domain.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'cards.dart';
import 'status.dart';

/// Prominent card for a cow that needs attention (dashboard "Cows Needing
/// Attention" list). Left severity strip + status pill make the state legible
/// at a glance; the milk yield and trend give quick context.
class CowAttentionCard extends StatelessWidget {
  const CowAttentionCard({super.key, required this.cow, this.onTap});

  final Cow cow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return StripCard(
      onTap: onTap,
      elevation: 1,
      stripColor: RiskStyle.of(cow.risk).color,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.md,
      ),
      child: Row(
        children: [
          _CowAvatar(name: cow.name),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cow.name,
                        style: AppText.headlineSm,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpace.xs),
                    StatusPill(cow.risk, dense: true),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${cow.tag} • ${cow.breed}', style: AppText.bodySm),
                const SizedBox(height: AppSpace.xs),
                Row(
                  children: [
                    Icon(
                      Icons.water_drop_rounded,
                      size: 14,
                      color: AppColors.forest,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_fmtMilk(cow.todayMilkLitres)} L today',
                      style: AppText.labelMd.copyWith(color: AppColors.ink),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Icon(trendIcon(cow.trend), size: 14, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Text(cow.trend, style: AppText.labelMd),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

/// Compact row for the full herd list (Cows tab).
class CowListTile extends StatelessWidget {
  const CowListTile({super.key, required this.cow, this.onTap});

  final Cow cow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GauCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpace.sm),
      child: Row(
        children: [
          _CowAvatar(name: cow.name),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cow.name,
                  style: AppText.headlineSm.copyWith(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('${cow.tag} • ${cow.breed}', style: AppText.bodySm),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusPill(cow.risk, dense: true),
              const SizedBox(height: 6),
              Text(
                '${_fmtMilk(cow.todayMilkLitres)} L',
                style: AppText.labelMd.copyWith(color: AppColors.ink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CowAvatar extends StatelessWidget {
  const _CowAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.mint,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: AppText.headlineSm.copyWith(color: AppColors.forest),
      ),
    );
  }
}

String _fmtMilk(double v) =>
    v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
