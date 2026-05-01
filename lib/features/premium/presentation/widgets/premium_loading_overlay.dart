import 'package:flutter/material.dart';
import 'package:reducer/core/theme/app_colors.dart';

class PremiumLoadingOverlay extends StatelessWidget {
  const PremiumLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: Container(
        color: (isDark ? AppColors.darkBackground : AppColors.lightBackground)
            .withValues(alpha: 0.7),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.8,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }
}
