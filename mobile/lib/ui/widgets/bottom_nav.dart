import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

/// A bottom-navigation destination.
class GauNavDestination {
  const GauNavDestination(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// The app's five primary destinations (per the UX spec).
const List<GauNavDestination> kGauNavDestinations = [
  GauNavDestination(Icons.home_outlined, Icons.home_rounded, 'Home'),
  GauNavDestination(Icons.pets_outlined, Icons.pets_rounded, 'Cows'),
  GauNavDestination(
    Icons.water_drop_outlined,
    Icons.water_drop_rounded,
    'Milk',
  ),
  GauNavDestination(
    Icons.notifications_outlined,
    Icons.notifications_rounded,
    'Alerts',
  ),
  GauNavDestination(Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More'),
];

/// Custom bottom nav bar: cream surface, top hairline, forest active state,
/// muted inactive. Supports a badge count on the Alerts tab.
class GauBottomNav extends StatelessWidget {
  const GauBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.alertCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < kGauNavDestinations.length; i++)
                Expanded(
                  child: _NavItem(
                    dest: kGauNavDestinations[i],
                    selected: i == currentIndex,
                    badge: kGauNavDestinations[i].label == 'Alerts'
                        ? alertCount
                        : 0,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.dest,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final GauNavDestination dest;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.forest : AppColors.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: dest.label,
      child: InkResponse(
        onTap: onTap,
        radius: 44,
        highlightColor: AppColors.mint,
        splashColor: AppColors.mint,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(selected ? dest.activeIcon : dest.icon, color: color),
                if (badge > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      constraints: const BoxConstraints(minWidth: 16),
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.atRisk,
                        borderRadius: AppRadii.pillAll,
                      ),
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: AppText.labelSm.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dest.label,
              style: AppText.labelSm.copyWith(
                color: color,
                letterSpacing: 0.2,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
