import 'package:flutter/material.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';

class BestValueBadge extends StatelessWidget {
  const BestValueBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.premiumGradient),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: const Text(
        "BEST VALUE",
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

