import 'package:flutter/material.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

enum AppSnackbarType { success, error, warning, info }

class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackbarType type = AppSnackbarType.info,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Clear existing snackbars
    scaffoldMessenger.removeCurrentSnackBar();
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white),
        ),
        backgroundColor: _getBackgroundColor(type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static Color _getBackgroundColor(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return AppColors.success;
      case AppSnackbarType.error:
        return AppColors.error;
      case AppSnackbarType.warning:
        return AppColors.warning;
      case AppSnackbarType.info:
      return AppColors.primary;
    }
  }
}
