import 'package:flutter/material.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompressTabView extends StatefulWidget {
  final ImageSettings settings;
  final ValueChanged<ImageSettings> onSettingsChanged;

  const CompressTabView({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<CompressTabView> createState() => _CompressTabViewState();
}

class _CompressTabViewState extends State<CompressTabView> {
  late TextEditingController _sizeController;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.settings.targetFileSizeKB != null
        ? (widget.settings.isTargetUnitMb
              ? widget.settings.targetFileSizeKB! / 1024
              : widget.settings.targetFileSizeKB!)
        : '';
    _sizeController = TextEditingController(text: initialValue.toString());
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  void _updateSettings({double? size, bool? isMb}) {
    final newIsMb = isMb ?? widget.settings.isTargetUnitMb;
    final rawSize = size ?? double.tryParse(_sizeController.text) ?? 0;

    widget.onSettingsChanged(
      widget.settings.copyWith(
        targetFileSizeKB: newIsMb ? rawSize * 1024 : rawSize,
        isTargetUnitMb: newIsMb,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.lg.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCard(
            context,
            title: l10n.targetFileSize.toUpperCase(),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sizeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.titleMedium(context),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: isDark
                            ? const BorderSide(color: Colors.white10)
                            : const BorderSide(color: AppColors.lightBorder),
                      ),
                      hintText: l10n.sizeHint,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    onChanged: (value) => _updateSettings(),
                  ),
                ),
                SizedBox(width: AppDimensions.md.w),
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark ? Colors.white10 : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildUnitButton(
                        'MB',
                        widget.settings.isTargetUnitMb,
                        isDark,
                        () => _updateSettings(isMb: true),
                      ),
                      _buildUnitButton(
                        'KB',
                        !widget.settings.isTargetUnitMb,
                        isDark,
                        () => _updateSettings(isMb: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimensions.xl.h),
          _buildCard(
            context,
            title: l10n.imageQuality.toUpperCase(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.smallerFile,
                      style: AppTextStyles.labelSmall(context).copyWith(
                        color: isDark
                            ? AppColors.onDarkSurfaceVariant
                            : AppColors.onLightSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${widget.settings.quality.toInt()}%',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    Text(
                      l10n.higherQuality,
                      style: AppTextStyles.labelSmall(context).copyWith(
                        color: isDark
                            ? AppColors.onDarkSurfaceVariant
                            : AppColors.onLightSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Slider(
                  value: widget.settings.quality,
                  min: 1,
                  max: 100,
                  activeColor: AppColors.primary,
                  inactiveColor: isDark
                      ? Colors.white10
                      : AppColors.lightBorder,
                  onChanged: (v) => widget.onSettingsChanged(
                    widget.settings.copyWith(quality: v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelSmall(context).copyWith(
            letterSpacing: 1.2.w,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.onDarkSurfaceVariant
                : AppColors.onLightSurfaceVariant,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: AppDimensions.sm.h),
        Container(
          padding: EdgeInsets.all(AppDimensions.lg.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.r,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildUnitButton(
    String label,
    bool isSelected,
    bool isDark,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white10 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.primary
                : (isDark
                      ? AppColors.onDarkSurfaceVariant
                      : AppColors.onLightSurfaceVariant),
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
