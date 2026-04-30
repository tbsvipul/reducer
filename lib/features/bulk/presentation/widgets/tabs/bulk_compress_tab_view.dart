import 'package:flutter/material.dart';
import 'package:reducer/core/models/image_settings.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_dimensions.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BulkCompressTabView extends StatefulWidget {
  final ImageSettings settings;
  final ValueChanged<ImageSettings> onSettingsChanged;

  const BulkCompressTabView({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<BulkCompressTabView> createState() => _BulkCompressTabViewState();
}

class _BulkCompressTabViewState extends State<BulkCompressTabView> {
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
    
    widget.onSettingsChanged(widget.settings.copyWith(
      targetFileSizeKB: newIsMb ? rawSize * 1024 : rawSize,
      isTargetUnitMb: newIsMb,
    ));
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
          _buildInfoNote(context, l10n.bulkSettingsNote),
          SizedBox(height: AppDimensions.lg.h),
          _buildCard(
            context,
            title: l10n.targetFileSize.toUpperCase(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _sizeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTextStyles.titleMedium(context).copyWith(color: isDark ? AppColors.onDarkSurface : AppColors.onLightSurface),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                            borderSide: isDark ? const BorderSide(color: Colors.white10) : const BorderSide(color: AppColors.lightBorder),
                          ),
                          hintText: l10n.sizeHint,
                          contentPadding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w, vertical: AppDimensions.sm.h),
                          suffixIcon: _sizeController.text.isNotEmpty 
                            ? IconButton(
                                icon: Icon(Icons.close, size: AppDimensions.iconMd, color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant), 
                                onPressed: () {
                                  _sizeController.clear();
                                  _updateSettings(size: 0);
                                },
                              ) 
                            : null,
                        ),
                      ),
                    ),
                    SizedBox(width: AppDimensions.md.w),
                    Container(
                      padding: EdgeInsets.all(AppDimensions.xs.r),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                      ),
                      child: Row(
                        children: [
                          _buildUnitButton('MB', widget.settings.isTargetUnitMb, isDark, () => _updateSettings(isMb: true)),
                          _buildUnitButton('KB', !widget.settings.isTargetUnitMb, isDark, () => _updateSettings(isMb: false)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.settings.targetFileSizeKB != null && widget.settings.targetFileSizeKB! > 0) ...[
                  SizedBox(height: AppDimensions.md.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w, vertical: AppDimensions.sm.h),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_fix_high, size: AppDimensions.iconSm.r, color: AppColors.warning),
                        SizedBox(width: AppDimensions.sm.w),
                        Expanded(
                          child: Text(
                            l10n.autoQualityActive,
                            style: AppTextStyles.labelSmall(context).copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          Opacity(
            opacity: (widget.settings.targetFileSizeKB != null && widget.settings.targetFileSizeKB! > 0) ? 0.5 : 1.0,
            child: _buildCard(
              context,
              title: l10n.imageQuality.toUpperCase(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.smallerFile, style: AppTextStyles.labelSmall(context).copyWith(color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant, fontSize: 11.sp)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: AppDimensions.md.w, vertical: AppDimensions.xs.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                        ),
                        child: Text(
                          '${widget.settings.quality.toInt()}%',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12.sp),
                        ),
                      ),
                      Text(l10n.higherQuality, style: AppTextStyles.labelSmall(context).copyWith(color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant, fontSize: 11.sp)),
                    ],
                  ),
                  Slider(
                    value: widget.settings.quality,
                    min: 1,
                    max: 100,
                    activeColor: AppColors.primary,
                    inactiveColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    onChanged: (widget.settings.targetFileSizeKB != null && widget.settings.targetFileSizeKB! > 0) 
                      ? null 
                      : (v) => widget.onSettingsChanged(widget.settings.copyWith(quality: v)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoNote(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(AppDimensions.md.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: AppDimensions.iconSm.r, color: AppColors.primary),
          SizedBox(width: AppDimensions.sm.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSmall(context).copyWith(
                color: isDark ? AppColors.onDarkSurface : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelSmall(context).copyWith(
            letterSpacing: 1.2.w,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: AppDimensions.sm.h),
        Container(
          padding: EdgeInsets.all(AppDimensions.lg.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg.r),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.r),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildUnitButton(String label, bool isSelected, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.lg.w, vertical: AppDimensions.sm.h),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppColors.darkSurfaceVariant : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm.r),
          boxShadow: isSelected && !isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4.r, offset: Offset(0, 2.h))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.onDarkSurfaceVariant : AppColors.onLightSurfaceVariant),
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}

