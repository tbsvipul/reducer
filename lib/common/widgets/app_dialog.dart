import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reducer/common/widgets/app_button.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

enum AppDialogType { info, confirm, error, success }

/// Standardized dialog for the application.
class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final AppDialogType type;
  final List<Widget>? customActions;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.type = AppDialogType.info,
    this.customActions,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    AppDialogType type = AppDialogType.info,
    List<Widget>? customActions,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        type: type,
        customActions: customActions,
      ),
    );
  }

  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.xl2.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            SizedBox(height: AppDimensions.lg.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge(context).copyWith(
                color: isDark
                    ? AppColors.onDarkSurface
                    : AppColors.onLightSurface,
              ),
            ),
            SizedBox(height: AppDimensions.md.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: isDark
                    ? AppColors.onDarkSurfaceVariant
                    : AppColors.onLightSurfaceVariant,
              ),
            ),
            SizedBox(height: AppDimensions.xl2.h),
            if (customActions != null)
              Column(
                children: customActions!
                    .map(
                      (action) => Padding(
                        padding: EdgeInsets.only(bottom: AppDimensions.sm.h),
                        child: SizedBox(width: double.infinity, child: action),
                      ),
                    )
                    .toList(),
              )
            else
              Row(
                children: [
                  if (cancelLabel != null)
                    Expanded(
                      child: AppButton(
                        label: cancelLabel!,
                        style: AppButtonStyle.ghost,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onCancel?.call();
                        },
                      ),
                    ),
                  if (cancelLabel != null && confirmLabel != null)
                    SizedBox(width: AppDimensions.md.w),
                  if (confirmLabel != null)
                    Expanded(
                      child: AppButton(
                        label: confirmLabel!,
                        style: type == AppDialogType.error
                            ? AppButtonStyle.secondary
                            : AppButtonStyle.primary,
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          onConfirm?.call();
                        },
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color color;

    switch (type) {
      case AppDialogType.error:
        iconData = Icons.error_outline;
        color = AppColors.error;
        break;
      case AppDialogType.success:
        iconData = Icons.check_circle_outline;
        color = AppColors.success;
        break;
      case AppDialogType.confirm:
        iconData = Icons.help_outline;
        color = AppColors.primary;
        break;
      case AppDialogType.info:
        iconData = Icons.info_outline;
        color = AppColors.secondary;
        break;
    }

    return Icon(iconData, size: 48.r, color: color);
  }
}
