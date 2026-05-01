import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/features/premium/data/datasources/purchase_datasource.dart';
import 'package:reducer/core/theme/app_colors.dart';
import 'package:reducer/core/theme/app_text_styles.dart';

enum NativeAdSize { small, medium }

class NativeAdWidget extends ConsumerStatefulWidget {
  const NativeAdWidget({super.key, this.size = NativeAdSize.small});

  final NativeAdSize size;

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_nativeAd == null && !_isLoaded) {
      _loadAd();
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    if (AdManager.isPremium) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    _nativeAd = NativeAd(
      adUnitId: AdManager.nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.size == NativeAdSize.small
            ? TemplateType.small
            : TemplateType.medium,
        mainBackgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        cornerRadius: 12.0,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[NativeAdWidget] Ad failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _nativeAd = null;
              _isLoaded = false;
            });
          }
        },
        onAdImpression: (ad) {
          debugPrint('[NativeAdWidget] Native ad impression');
        },
        onAdClicked: (ad) {
          debugPrint('[NativeAdWidget] Native ad clicked');
        },
      ),
    );

    _nativeAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(premiumControllerProvider).isPro;
    if (isPro || AdManager.isPremium) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double safeWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 32;
        final double fixedHeight = widget.size == NativeAdSize.small
            ? (safeWidth >= 600 ? 120 : 100)
            : (safeWidth >= 600 ? 300 : 280);

        if (!_isLoaded || _nativeAd == null) {
          return Container(
            height: fixedHeight,
            width: safeWidth,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return Container(
          height: fixedHeight,
          width: safeWidth,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceVariant
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(child: AdWidget(ad: _nativeAd!)),
              Positioned(
                top: 0,
                left: 0,
                child: Semantics(
                  label: 'Advertisement',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.premium,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      'AD',
                      style: AppTextStyles.labelSmall(context).copyWith(
                        color: AppColors.onPremium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
