import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/localization/locale_provider.dart';
import 'package:reducer/core/theme/app_breakpoints.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/l10n/app_localizations.dart';

import '../../domain/models/app_language.dart';
import '../constants/languages.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  final bool isFromSettings;

  const LanguageSelectionPage({super.key, this.isFromSettings = false});

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends ConsumerState<LanguageSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.of(context).disableAnimations ||
        MediaQuery.of(context).accessibleNavigation;

    final filteredLanguages = AppLanguages.all.where((lang) {
      final name = lang.name.toLowerCase();
      final sub = lang.sub.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || sub.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          _buildBackgroundGlows(isDark, reduceMotion),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AppBreakpoints.contentMaxWidth(
                    context,
                    compactWidth: 680,
                    mediumWidth: 760,
                    expandedWidth: 860,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    _buildHeader(context, l10n, isDark),
                    SizedBox(height: 24.h),
                    _buildSearchBar(l10n, isDark),
                    SizedBox(height: 24.h),
                    Expanded(
                      child: _buildLanguageList(
                        filteredLanguages,
                        currentLocale,
                        isDark,
                        reduceMotion,
                      ),
                    ),
                    if (!widget.isFromSettings) _buildContinueButton(l10n),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlows(bool isDark, bool reduceMotion) {
    Widget animatedGlow({
      required double top,
      required double left,
      required double size,
      required Color color,
      required Duration duration,
      required Offset endScale,
    }) {
      final glow = Positioned(
        top: top,
        left: left,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      );

      if (reduceMotion) {
        return glow;
      }

      return glow
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(duration: duration, begin: const Offset(1, 1), end: endScale);
    }

    return Positioned.fill(
      child: Stack(
        children: [
          animatedGlow(
            top: -100,
            left: MediaQuery.sizeOf(context).width - 220,
            size: 300,
            color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
            duration: 5.seconds,
            endScale: const Offset(1.2, 1.2),
          ),
          animatedGlow(
            top: MediaQuery.sizeOf(context).height - 220,
            left: -50,
            size: 250,
            color: AppColors.secondary.withValues(alpha: isDark ? 0.05 : 0.03),
            duration: 7.seconds,
            endScale: const Offset(1.3, 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          if (widget.isFromSettings)
            IconButton.filledTonal(
              tooltip: l10n.cancel,
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new),
            ),
          if (widget.isFromSettings) SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectLanguage,
                  style: AppTextStyles.headlineMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                if (!widget.isFromSettings)
                  Text(
                    l10n.setupLanguageSubtitle,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05);
  }

  Widget _buildSearchBar(AppLocalizations l10n, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.onDarkBackground.withValues(alpha: 0.05)
              : AppColors.onLightBackground.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _searchQuery.isNotEmpty
                ? AppColors.primary.withValues(alpha: 0.4)
                : colorScheme.outline.withValues(alpha: 0.55),
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(
            color: isDark
                ? AppColors.onDarkBackground
                : AppColors.onLightBackground,
          ),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: l10n.searchLanguage,
            hintStyle: AppTextStyles.bodyMedium(
              context,
            ).copyWith(color: colorScheme.onSurfaceVariant),
            prefixIcon: Icon(
              Iconsax.search_normal,
              color: _searchQuery.isNotEmpty
                  ? AppColors.primary
                  : colorScheme.onSurfaceVariant,
              size: 20.r,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    tooltip: l10n.cancel,
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                      size: 16.r,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      unawaited(HapticFeedback.lightImpact());
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildLanguageList(
    List<AppLanguage> languages,
    Locale currentLocale,
    bool isDark,
    bool reduceMotion,
  ) {
    return ListView.separated(
      padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
      itemCount: languages.length,
      physics: const BouncingScrollPhysics(),
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final lang = languages[index];
        final isSelected = currentLocale.languageCode == lang.code;

        final tile = _LanguageTile(
          lang: lang,
          isSelected: isSelected,
          isDark: isDark,
          onTap: () {
            ref.read(localeProvider.notifier).setLocale(Locale(lang.code));
            unawaited(HapticFeedback.mediumImpact());
          },
        );

        if (reduceMotion) {
          return tile;
        }

        return tile
            .animate()
            .fadeIn(delay: (index * 20).ms, duration: 300.ms)
            .slideX(begin: 0.05);
      },
    );
  }

  Widget _buildContinueButton(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () async {
            await HapticFeedback.mediumImpact();
            await ref.read(onboardingProvider.notifier).completeOnboarding();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              l10n.continueLabel,
              style: AppTextStyles.labelLarge(
                context,
              ).copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2);
  }
}

class _LanguageTile extends StatelessWidget {
  final AppLanguage lang;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.lang,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${lang.sub}, ${lang.name}',
      child: AnimatedContainer(
        duration: 300.ms,
        constraints: const BoxConstraints(minHeight: 72),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark
                    ? AppColors.onDarkBackground.withValues(alpha: 0.03)
                    : AppColors.onLightBackground.withValues(alpha: 0.03)),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected && !isDark
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : colorScheme.outline.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(lang.flag, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang.sub,
                          style: AppTextStyles.titleMedium(context).copyWith(
                            color: isSelected
                                ? (isDark
                                      ? AppColors.onDarkBackground
                                      : AppColors.primary)
                                : colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        Text(
                          lang.name,
                          style: AppTextStyles.bodySmall(context).copyWith(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.85)
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.onPrimary,
                        size: 14.r,
                      ),
                    ).animate().scale(
                      duration: 250.ms,
                      curve: Curves.easeOutBack,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
