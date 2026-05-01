import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:reducer/common/widgets/common_app_bar.dart';
import 'package:reducer/common/widgets/common_bottom_nav_bar.dart';
import 'package:reducer/core/theme/app_breakpoints.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    // Branches 2 (Bulk) and 4 (Profile) handle their own specialized headers
    final showAppBar =
        navigationShell.currentIndex != 2 && navigationShell.currentIndex != 4;
    final useRail = AppBreakpoints.useNavigationRail(context);
    final body = navigationShell.animate().fadeIn(
      duration: 400.ms,
      curve: Curves.easeIn,
    );

    if (!useRail) {
      return Scaffold(
        appBar: showAppBar
            ? CommonAppBar(navigationShell: navigationShell)
            : null,
        body: body,
        bottomNavigationBar: CommonBottomNavBar(
          navigationShell: navigationShell,
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            CommonBottomNavBar(navigationShell: navigationShell),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  if (showAppBar)
                    CommonAppBar(navigationShell: navigationShell),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
