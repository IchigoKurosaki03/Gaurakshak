import 'package:flutter/material.dart';

import '../../state/farm_state.dart';
import '../ui.dart';

/// The signed-in application shell: five primary destinations behind a shared
/// bottom nav. Tabs are kept in an [IndexedStack] so each preserves its scroll
/// position and state when switching.
///
/// Phase 1 establishes the shell and navigation; Home receives the real
/// dashboard in Phase 2 and the remaining tabs are filled in later phases.
/// Their current placeholders are intentionally branded, not throwaway.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.state});

  final FarmState state;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              _HomePlaceholder(state: widget.state),
              const _TabPlaceholder(
                title: 'Cows',
                icon: Icons.pets_rounded,
                message: 'The full herd list with search and filters arrives '
                    'in a later phase.',
              ),
              const _TabPlaceholder(
                title: 'Milk',
                icon: Icons.water_drop_rounded,
                message: 'Daily milk logging and yield history arrives in a '
                    'later phase.',
              ),
              _AlertsPlaceholder(state: widget.state),
              const _TabPlaceholder(
                title: 'More',
                icon: Icons.more_horiz_rounded,
                message: 'Settings, language, and account options arrive in a '
                    'later phase.',
              ),
            ],
          ),
          bottomNavigationBar: GauBottomNav(
            currentIndex: _index,
            alertCount: widget.state.alerts.length,
            onTap: (i) => setState(() => _index = i),
          ),
        );
      },
    );
  }
}

/// Shared scaffold for a tab: header row (title + connectivity) and an offline
/// banner, with the tab's body below.
class TabScaffold extends StatelessWidget {
  const TabScaffold({
    super.key,
    required this.title,
    required this.state,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final FarmState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final connectivity = state.isOnline
        ? ConnectivityState.online
        : ConnectivityState.offline;
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.pageMargin,
              AppSpace.md,
              AppSpace.pageMargin,
              AppSpace.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: AppText.headlineLgMobile),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: AppText.bodySm,
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: ConnectivityPill(connectivity),
                ),
              ],
            ),
          ),
          if (!state.isOnline) const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({required this.state});

  final FarmState state;

  @override
  Widget build(BuildContext context) {
    return TabScaffold(
      title: state.farm.name,
      subtitle: state.farm.location.isEmpty ? 'Your dairy' : state.farm.location,
      state: state,
      child: EmptyState(
        icon: Icons.dashboard_rounded,
        title: "You're all set",
        message:
            'The herd dashboard — overview, milk, and cows needing attention — '
            'is built in the next phase.',
      ),
    );
  }
}

class _AlertsPlaceholder extends StatelessWidget {
  const _AlertsPlaceholder({required this.state});

  final FarmState state;

  @override
  Widget build(BuildContext context) {
    final count = state.alerts.length;
    return TabScaffold(
      title: 'Alerts',
      subtitle: count == 0 ? 'No active alerts' : '$count active',
      state: state,
      child: EmptyState(
        icon: Icons.notifications_rounded,
        title: count == 0 ? 'All calm' : '$count alerts waiting',
        message:
            'The full alerts feed with severity and quick actions is built in '
            'a later phase.',
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    // Placeholder tabs don't need live state; a minimal header keeps them
    // visually consistent with the rest of the shell.
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.pageMargin,
              AppSpace.md,
              AppSpace.pageMargin,
              AppSpace.sm,
            ),
            child: Text(title, style: AppText.headlineLgMobile),
          ),
          Expanded(
            child: EmptyState(icon: icon, title: title, message: message),
          ),
        ],
      ),
    );
  }
}
