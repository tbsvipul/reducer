import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reducer/core/theme/app_text_styles.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/l10n/app_localizations.dart';

class PremiumFooterLinks extends ConsumerWidget {
  const PremiumFooterLinks({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final linkStyle = AppTextStyles.labelMedium(
      context,
    ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.w,
      children: [
        _Link(
          text: l10n.termsOfService,
          onTap: () => _launch('https://tarur.com/terms'),
        ),
        Text("|", style: linkStyle),
        _Link(
          text: l10n.privacyPolicy,
          onTap: () =>
              _launch('https://tarurinfotech.base44.app/privacy/reducer'),
        ),
        Text("|", style: linkStyle),
        _Link(
          text: l10n.restorePurchases,
          onTap: () =>
              ref.read(premiumControllerProvider.notifier).restorePurchases(),
        ),
      ],
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _Link extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _Link({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      link: true,
      label: text,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Text(
              text,
              style: AppTextStyles.labelMedium(context).copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
