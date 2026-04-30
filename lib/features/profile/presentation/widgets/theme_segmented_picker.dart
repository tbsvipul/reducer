import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/theme_provider.dart';
import 'package:reducer/l10n/app_localizations.dart';

class ThemeSegmentedPicker extends ConsumerWidget {
  const ThemeSegmentedPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ThemeMode>(
        segments: [
          ButtonSegment(
            value: ThemeMode.light,
            label: Text(l10n.light),
            icon: const Icon(Iconsax.sun_1, size: 16),
          ),
          ButtonSegment(
            value: ThemeMode.system,
            label: Text(l10n.auto),
            icon: const Icon(Iconsax.setting, size: 16),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            label: Text(l10n.dark),
            icon: const Icon(Iconsax.moon, size: 16),
          ),
        ],
        selected: {currentTheme},
        onSelectionChanged: (set) => ref.read(themeModeProvider.notifier).setThemeMode(set.first),
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.transparent,
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          side: BorderSide.none,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
