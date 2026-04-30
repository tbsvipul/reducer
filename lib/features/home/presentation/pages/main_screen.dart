import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reducer/common/widgets/common_app_bar.dart';
import 'package:reducer/common/widgets/common_bottom_nav_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    // Branches 2 (Bulk) and 4 (Profile) handle their own specialized headers
    final showAppBar = navigationShell.currentIndex != 2 && navigationShell.currentIndex != 4;

    return Scaffold(
      appBar: showAppBar ? CommonAppBar(navigationShell: navigationShell) : null,
      body: navigationShell.animate().fadeIn(duration: 400.ms, curve: Curves.easeIn),
      bottomNavigationBar: CommonBottomNavBar(navigationShell: navigationShell),
    );
  }
}

