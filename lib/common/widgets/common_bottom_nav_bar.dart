import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/theme/app_breakpoints.dart';
import 'package:reducer/l10n/app_localizations.dart';

class CommonBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CommonBottomNavBar({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  List<_NavDestination> _destinations(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      _NavDestination(
        icon: const Icon(Iconsax.home_1),
        selectedIcon: const Icon(Iconsax.home5),
        label: l10n.homeTitle,
      ),
      _NavDestination(
        icon: const Icon(Iconsax.edit),
        selectedIcon: const Icon(Iconsax.edit5),
        label: l10n.singleEditor,
      ),
      _NavDestination(
        icon: const Icon(Iconsax.layer),
        selectedIcon: const Icon(Iconsax.layer5),
        label: l10n.bulkStudio,
      ),
      _NavDestination(
        icon: const Icon(Iconsax.gallery),
        selectedIcon: const Icon(Iconsax.gallery5),
        label: l10n.history,
      ),
      _NavDestination(
        icon: const Icon(Iconsax.user),
        selectedIcon: const Icon(Iconsax.user),
        label: l10n.profile,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(context);

    if (AppBreakpoints.useNavigationRail(context)) {
      return NavigationRail(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        labelType: NavigationRailLabelType.all,
        minWidth: 80,
        groupAlignment: -0.85,
        destinations: destinations
            .map(
              (destination) => NavigationRailDestination(
                icon: destination.icon,
                selectedIcon: destination.selectedIcon,
                label: Text(destination.label),
              ),
            )
            .toList(),
      );
    }

    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: _onTap,
      destinations: destinations
          .map(
            (destination) => NavigationDestination(
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
              label: destination.label,
            ),
          )
          .toList(),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;
}
