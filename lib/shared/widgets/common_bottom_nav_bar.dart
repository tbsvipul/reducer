import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
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

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: _onTap,
      destinations: [
        NavigationDestination(
          icon: const Icon(Iconsax.home_1),
          selectedIcon: const Icon(Iconsax.home5),
          label: AppLocalizations.of(context)!.homeTitle,
        ),
        NavigationDestination(
          icon: const Icon(Iconsax.edit),
          selectedIcon: const Icon(Iconsax.edit5),
          label: AppLocalizations.of(context)!.singleEditor,
        ),
        NavigationDestination(
          icon: const Icon(Iconsax.layer),
          selectedIcon: const Icon(Iconsax.layer5),
          label: AppLocalizations.of(context)!.bulkStudio,
        ),
        NavigationDestination(
          icon: const Icon(Iconsax.gallery),
          selectedIcon: const Icon(Iconsax.gallery5),
          label: AppLocalizations.of(context)!.history,
        ),
        NavigationDestination(
          icon: const Icon(Iconsax.user),
          selectedIcon: const Icon(Iconsax.user),
          label: AppLocalizations.of(context)!.profile,
        ),
      ],
    );
  }
}
