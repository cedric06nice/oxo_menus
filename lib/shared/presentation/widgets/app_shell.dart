import 'package:flutter/material.dart';
import 'package:oxo_menus/core/routing/app_routes.dart';
import 'package:oxo_menus/core/routing/route_navigator.dart';
import 'package:oxo_menus/features/connectivity/presentation/widgets/offline_banner.dart';
import 'package:oxo_menus/shared/presentation/theme/app_spacing.dart';

/// Adaptive navigation scaffold using LayoutBuilder.
///
/// - **Mobile (<600px)**: `NavigationBar` bottom bar
/// - **Tablet (600–1200px)**: `NavigationRail` (icons only, left side)
/// - **Desktop/Web (>1200px)**: Permanent `NavigationDrawer` (icons + labels)
///
/// Pure widget — receives [navigator], [currentLocation], [isAdmin], and
/// [isOffline] from the parent (the `OxoRouter` shell builder). No Riverpod,
/// no router import.
class AppShell extends StatelessWidget {
  final Widget child;
  final RouteNavigator navigator;
  final String currentLocation;
  final bool isAdmin;
  final bool isOffline;

  const AppShell({
    super.key,
    required this.child,
    required this.navigator,
    required this.currentLocation,
    required this.isAdmin,
    required this.isOffline,
  });

  static const _mobileBreakpoint = AppBreakpoints.mobile;
  static const _desktopBreakpoint = AppBreakpoints.desktop;

  @override
  Widget build(BuildContext context) {
    final destinations = _buildDestinations(isAdmin);
    final selectedIndex = _locationToIndex(currentLocation, isAdmin);

    final wrappedChild = isOffline
        ? Column(
            children: [
              const OfflineBanner(),
              Expanded(child: child),
            ],
          )
        : child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= _desktopBreakpoint) {
          return _DesktopLayout(
            destinations: destinations,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) =>
                _onDestinationSelected(index, isAdmin),
            child: wrappedChild,
          );
        }

        if (width >= _mobileBreakpoint) {
          return _TabletLayout(
            destinations: destinations,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) =>
                _onDestinationSelected(index, isAdmin),
            child: wrappedChild,
          );
        }

        return _MobileLayout(
          destinations: destinations,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) =>
              _onDestinationSelected(index, isAdmin),
          child: wrappedChild,
        );
      },
    );
  }

  List<_NavDestination> _buildDestinations(bool isAdmin) {
    return [
      const _NavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Home',
        route: AppRoutes.home,
      ),
      const _NavDestination(
        icon: Icons.restaurant_menu_outlined,
        selectedIcon: Icons.restaurant_menu,
        label: 'Menus',
        route: AppRoutes.menus,
      ),
      if (isAdmin)
        const _NavDestination(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Templates',
          route: AppRoutes.adminTemplates,
        ),
      if (isAdmin)
        const _NavDestination(
          icon: Icons.straighten_outlined,
          selectedIcon: Icons.straighten,
          label: 'Sizes',
          route: AppRoutes.adminSizes,
        ),
      const _NavDestination(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: 'Settings',
        route: AppRoutes.settings,
      ),
    ];
  }

  int _locationToIndex(String location, bool isAdmin) {
    final destinations = _buildDestinations(isAdmin);
    for (int i = 0; i < destinations.length; i++) {
      if (location.startsWith(destinations[i].route)) return i;
    }
    return 0;
  }

  void _onDestinationSelected(int index, bool isAdmin) {
    final destinations = _buildDestinations(isAdmin);
    if (index >= 0 && index < destinations.length) {
      navigator.go(destinations[index].route);
    }
  }
}

class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

class _MobileLayout extends StatelessWidget {
  final List<_NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const _MobileLayout({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.clamp(0, destinations.length - 1),
        onDestinationSelected: onDestinationSelected,
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final List<_NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const _TabletLayout({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex.clamp(0, destinations.length - 1),
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final List<_NavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const _DesktopLayout({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedIndex = selectedIndex.clamp(0, destinations.length - 1);

    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: clampedIndex,
            onDestinationSelected: onDestinationSelected,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
                child: Text(
                  'OXO Menus',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Divider(indent: 28, endIndent: 28),
              ...destinations.map(
                (d) => NavigationDrawerDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: Text(d.label),
                ),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
