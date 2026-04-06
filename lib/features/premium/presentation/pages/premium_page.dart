import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reducer/features/premium/premium.dart';
import 'package:reducer/core/theme/design_tokens.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumControllerProvider);
    final notifier = ref.read(premiumControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Listen for success → auto-pop after a short delay ─────────────
    ref.listen<PurchaseState>(premiumControllerProvider, (prev, next) {
      if (next.successMessage.isNotEmpty &&
          (prev == null || prev.successMessage != next.successMessage)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Pop back after a brief moment so the user sees the SnackBar.
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (context.mounted) Navigator.pop(context);
        });
      }

      // Show error snackbar if it changed.
      if (next.errorMessage.isNotEmpty &&
          (prev == null || prev.errorMessage != next.errorMessage)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // ── Already subscribed state ──────────────────────────────────────
    if (state.isPro) {
      return _buildAlreadyProState(context, isDark);
    }

    if (state.errorMessage.isNotEmpty && state.availablePackages.isEmpty) {
      return _buildErrorState(context, notifier, state.errorMessage);
    }

    if (!state.isLoading && state.availablePackages.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: Text(
            "No plans available",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/premium_screen/bg_image.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
              ),
            ),
          ),

          // Close button
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 16),
                child: _buildCloseButton(context),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 255, 16, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                   Center(
                    child: Text(
                      "Unlock Premium",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Benefits
                  _infoRow(context, "Unlimited access"),
                  _infoRow(context, "Ad-free experience"),
                  _infoRow(context, "Priority support"),

                  const SizedBox(height: 10),

                  // Packages
                  Flexible(child: _buildPackagesList(context, state, notifier)),
                  _buildSubscribeButton(context, state, notifier),
                  const SizedBox(height: 10),

                  // Auto-renew
                  Center(
                    child: Text(
                      "Subscriptions auto-renew. Cancel anytime.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
                        height: 1.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                  Center(child: _buildFooterLinks(notifier, context)),
                ],
              ),
            ),
          ),

          if (state.isLoading) _buildLoadingOverlay(isDark),
        ],
      ),
    );
  }

  // ── Already-Pro State ───────────────────────────────────────────────────

  Widget _buildAlreadyProState(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                size: 72,
                color: Colors.green.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'You\'re a Pro member!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you for your support. You have full access to all premium features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => _openSubscriptionManagement(),
                icon: const Icon(Icons.settings),
                label: const Text('Manage Subscription'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSubscriptionManagement() async {
    final uri = Uri.parse(
      'https://play.google.com/store/account/subscriptions',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Close Button ────────────────────────────────────────────────────────

  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Image.asset(
        "assets/premium_screen/close_icon.png",
        width: 35,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.close, size: 35),
      ),
    );
  }

  // ── Error State ─────────────────────────────────────────────────────────

  Widget _buildErrorState(
    BuildContext context,
    PurchaseNotifier notifier,
    String error,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: notifier.fetchOffersAndCheckStatus,
                icon: const Icon(Icons.refresh),
                label: const Text("Try again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Packages List ───────────────────────────────────────────────────────

  Widget _buildPackagesList(
    BuildContext context,
    PurchaseState state,
    PurchaseNotifier notifier,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: state.availablePackages
          .map(
            (package) => _PackageCard(
              package: package,
              isSelected: package == state.selectedPackage,
              onTap: () => notifier.selectPackage(package),
            ),
          )
          .toList(),
    );
  }

  // ── Subscribe Button ────────────────────────────────────────────────────

  Widget _buildSubscribeButton(
    BuildContext context,
    PurchaseState state,
    PurchaseNotifier notifier,
  ) {
    final isLoading = state.isLoading;

    return GestureDetector(
      onTap: () {
        if (state.selectedPackage == null || isLoading) return;
        // Fire-and-forget — result arrives via the purchase stream.
        // Do NOT await and pop; see ref.listen above for navigation.
        notifier.purchaseSelectedPackage();
      },
      child: Container(
        height: 43,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [DesignTokens.accentBlue, DesignTokens.primaryBlue],
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/common/king_icon.png",
                      color: Colors.white,
                      width: 20,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.star, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Subscribe Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Loading Overlay ─────────────────────────────────────────────────────

  Widget _buildLoadingOverlay(bool isDark) {
    return Positioned.fill(
      child: Container(
        color: isDark
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.75),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.8,
            valueColor: AlwaysStoppedAnimation<Color>(DesignTokens.primaryBlue),
          ),
        ),
      ),
    );
  }

  // ── Footer Links ────────────────────────────────────────────────────────

  Widget _buildFooterLinks(PurchaseNotifier notifier, BuildContext context) {
    const linkStyle = TextStyle(fontSize: 13, color: Color(0xFF6C6C6C));
    const divider = Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text("|", style: TextStyle(fontSize: 16, color: Color(0xFF6C6C6C))),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () => _launchLink('https://tarur.com/terms'),
            child: const Text(
              "Terms of use",
              style: TextStyle(fontSize: 14, color: Color(0xFF6C6C6C)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        divider,
        Flexible(
          child: GestureDetector(
            onTap: () => _launchLink('https://tarur.com/privacy'),
            child: const Text(
              "Privacy Policy",
              style: linkStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        divider,
        Flexible(
          child: GestureDetector(
            onTap: () {
              notifier.restorePurchases();
              // Result handled via ref.listen above — no immediate SnackBar.
            },
            child: const Text(
              "Restore",
              style: linkStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Info Row ────────────────────────────────────────────────────────────

  Widget _infoRow(BuildContext context, String value) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          "assets/premium_screen/black_check_icon.png",
          width: 22,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.check_circle,
            size: 22,
            color: onSurface.withValues(alpha: 0.87),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: onSurface.withValues(alpha: 0.87),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Package Card ─────────────────────────────────────────────────────────────
class _PackageCard extends StatelessWidget {
  final ProductDetails package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  bool get _isYearly => _containsAny(
        package.title,
        package.id,
        ['year', 'annual', '12month', 'yr'],
      );

  bool get _isWeekly => _containsAny(
        package.title,
        package.id,
        ['week', 'weekly', '7day', '7d'],
      );

  bool get _isMonthly =>
      !_isWeekly &&
      !_isYearly &&
      _containsAny(
        package.title,
        package.id,
        ['month', 'monthly', '1month', 'mo'],
      );

  static bool _containsAny(String a, String b, List<String> terms) {
    final lowerA = a.toLowerCase();
    final lowerB = b.toLowerCase();
    return terms.any((t) => lowerA.contains(t) || lowerB.contains(t));
  }

  String _getTitleText() {
    if (_isYearly) return "Yearly Plan";
    if (_isMonthly) return "Monthly Plan";
    if (_isWeekly) return "Weekly Plan";
    return package.price;
  }

  String _getPeriodText() {
    final price = package.price;
    if (_isYearly) return "Pay $price / Year";
    if (_isMonthly) return "Pay $price / Month";
    if (_isWeekly) return "Pay $price / Week";
    return price;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surfaceVariant = isDark ? Colors.grey.shade800 : Colors.white;
    final borderColor = isDark ? Colors.grey.shade700 : const Color(0xFFE9E9E9);

    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? DesignTokens.primaryBlue.withValues(alpha: 0.5)
                  : borderColor,
              width: 1.5,
            ),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [
                      DesignTokens.accentBlue,
                      DesignTokens.lightBg,
                      DesignTokens.accentBlue,
                      DesignTokens.lightBg,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : surfaceVariant,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Image.asset(
                      isSelected
                          ? "assets/premium_screen/check_icon.png"
                          : "assets/premium_screen/uncheck_icon.png",
                      width: 28,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? DesignTokens.primaryBlue
                            : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTitleText(),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getPeriodText(),
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? onSurface
                                  : onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      package.price,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: isSelected
                            ? onSurface
                            : onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isYearly)
                Positioned(
                  top: -15,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          DesignTokens.accentBlue,
                          DesignTokens.primaryBlue,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "BEST VALUE",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
