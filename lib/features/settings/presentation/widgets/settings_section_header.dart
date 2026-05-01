import 'package:flutter/material.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.sm,
        bottom: AppDimensions.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelLarge(
          context,
        ).copyWith(color: AppColors.primary),
      ),
    );
  }
}
