import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/features/premium/domain/models/premium_plan.dart';

import 'package:reducer/core/config/app_config.dart';
import 'package:reducer/features/auth/presentation/providers/auth_providers.dart';

// ─── Keys for SecureStorage ─────────────────────────────────────────────────
const String _kSecIsPro = 'is_pro_user';
const String _kSecProVerifiedAt = 'pro_verified_at_ms';

/// How often to re-validate the subscription against the store (hours).
const int _kRevalidationIntervalHours = 24;

/// Provider for managing the Premium/Pro status and purchase flow.
final premiumControllerProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(ref),
);

// ─── State ──────────────────────────────────────────────────────────────────
class PurchaseState {
  final bool isPro;
  final bool isLoading;
  final List<PremiumPlan> availablePackages;
  final PremiumPlan? selectedPackage;
  final String errorMessage;

  /// Informational message shown after a successful purchase or restore.
  final String successMessage;

  PurchaseState({
    this.isPro = false,
    this.isLoading = true,
    this.availablePackages = const [],
    this.selectedPackage,
    this.errorMessage = '',
    this.successMessage = '',
  });

  PurchaseState copyWith({
    bool? isPro,
    bool? isLoading,
    List<PremiumPlan>? availablePackages,
    PremiumPlan? selectedPackage,
    String? errorMessage,
    String? successMessage,
  }) {
    return PurchaseState(
      isPro: isPro ?? this.isPro,
      isLoading: isLoading ?? this.isLoading,
      availablePackages: availablePackages ?? this.availablePackages,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

// ─── Notifier ───────────────────────────────────────────────────────────────
class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _purchaseInProgress = false;

  PurchaseNotifier(this._ref) : super(PurchaseState()) {
    _init();
  }

  // ── Initialization ──────────────────────────────────────────────────────

  Future<void> _init() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _purchaseSubscription = purchaseUpdated.listen(
      _listenToPurchaseUpdated,
      onDone: () {
        _purchaseSubscription?.cancel();
      },
      onError: (Object error) {
        if (!mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
        );
      },
    );

    await fetchOffersAndCheckStatus();
  }

  // ── Secure Pro Status ───────────────────────────────────────────────────

  Future<void> _checkProStatusLocally() async {
    final String? isProStr = await _secureStorage.read(key: _kSecIsPro);
    final isPro = isProStr == 'true';

    if (isPro) {
      final String? lastVerifiedMsStr =
          await _secureStorage.read(key: _kSecProVerifiedAt);
      final lastVerifiedMs = int.tryParse(lastVerifiedMsStr ?? '') ?? 0;
      final timeSinceMs =
          DateTime.now().millisecondsSinceEpoch - lastVerifiedMs;
      final hoursSince = timeSinceMs / (1000 * 60 * 60);

      if (hoursSince > _kRevalidationIntervalHours) {
        debugPrint('[Purchase] Pro-status stale (${hoursSince.toStringAsFixed(1)}h)');
      }
    }

    AdManager.isPremium = isPro;
    if (!mounted) return;
    state = state.copyWith(isPro: isPro);
  }

  Future<void> _setProStatusLocally(bool pro) async {
    await _secureStorage.write(key: _kSecIsPro, value: pro ? 'true' : 'false');
    if (pro) {
      await _secureStorage.write(
        key: _kSecProVerifiedAt,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } else {
      await _secureStorage.delete(key: _kSecProVerifiedAt);
    }
    AdManager.isPremium = pro;
    if (!mounted) return;
    state = state.copyWith(isPro: pro);
  }

  Future<void> clearProStatus() async {
    await _setProStatusLocally(false);
  }

  // ── Fetch Offers ────────────────────────────────────────────────────────

  // ── Fetch Offers ────────────────────────────────────────────────────────

  Future<void> fetchOffersAndCheckStatus() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: '', successMessage: '');

    try {
      await _checkProStatusLocally();

      final bool available = await _iap.isAvailable();
      if (!available) {
        if (!mounted) return;
        state = state.copyWith(errorMessage: 'Store unavailable.', isLoading: false);
        return;
      }

      // Query parent product ID(s)
      final ProductDetailsResponse response = await _iap.queryProductDetails(AppConfig.productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('[Purchase] ❌ Products not found: ${response.notFoundIDs}. Check your Google Play Console Product IDs.');
      }

      if (response.error != null) {
        if (!mounted) return;
        state = state.copyWith(errorMessage: 'Store error: ${response.error?.message}', isLoading: false);
        return;
      }

      final packages = <PremiumPlan>[];
      final seenPlanIds = <String>{};

      for (final product in response.productDetails) {
        if (product is GooglePlayProductDetails) {
          final offers = product.productDetails.subscriptionOfferDetails;
          if (offers != null && offers.isNotEmpty) {
            for (final offer in offers) {
              final plan = PremiumPlan(product: product, offer: offer);
              
              // Unique key for preventing duplicate UI entries
              final planId = '${product.id}_${offer.basePlanId}_${offer.offerId ?? "base"}';
              
              if (!seenPlanIds.contains(planId)) {
                packages.add(plan);
                seenPlanIds.add(planId);
                debugPrint('🔹 Plan Loaded: ${plan.titleText} | ${plan.price} | BasePlan: ${offer.basePlanId} | Offer: ${offer.offerId ?? "Standard"}');
              }
            }
          } else {
            debugPrint('[Purchase] ⚠️ Product ${product.id} has no subscriptionOfferDetails. Check Base Plan status.');
            packages.add(PremiumPlan(product: product));
          }
        } else {
          packages.add(PremiumPlan(product: product));
        }
      }

      // Sort: Yearly plans first for better conversion
      packages.sort((a, b) {
        if (a.isYearly && !b.isYearly) return -1;
        if (!a.isYearly && b.isYearly) return 1;
        return 0;
      });

      if (!mounted) return;
      state = state.copyWith(
        availablePackages: packages,
        selectedPackage: packages.isNotEmpty ? packages.first : null,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[Purchase] Fetch Error: $e');
      if (!mounted) return;
      state = state.copyWith(errorMessage: 'Failed to load plans: $e', isLoading: false);
    }
  }

  void selectPackage(PremiumPlan package) {
    state = state.copyWith(
      selectedPackage: package,
      errorMessage: '',
      successMessage: '',
    );
  }

  // ── Purchase ────────────────────────────────────────────────────────────

  /// Purchases the selected package. 
  /// 
  /// IMPORTANT: For Google Play Billing 5+, the [offerToken] is mandatory for subscriptions.
  Future<void> purchaseSelectedPackage() async {
    if (state.selectedPackage == null || _purchaseInProgress) return;

    final plan = state.selectedPackage!;
    _purchaseInProgress = true;
    state = state.copyWith(isLoading: true, errorMessage: '', successMessage: '');

    try {
      PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        final String? offerToken = (plan.offer as dynamic)?.offerToken;
        
        if (offerToken == null) {
          throw Exception('Missing offerToken for Android subscription. Ensure base plans are active.');
        }

        // TODO: Implement Upgrade/Downgrade logic with GooglePlayPurchaseParam(changeSubscriptionParam: ...)
        // if user already has an active subscription token.
        
        purchaseParam = GooglePlayPurchaseParam(
          productDetails: plan.product,
          offerToken: offerToken,
        );
      } else {
        purchaseParam = PurchaseParam(productDetails: plan.product);
      }

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('[Purchase] Initiation Failed: $e');
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: 'Purchase failed: ${e.toString()}');
    } finally {
      _purchaseInProgress = false;
    }
  }

  // ── Restore ─────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: '', successMessage: '');
    try {
      debugPrint('[Purchase] Restoring...');
      await _iap.restorePurchases();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: 'Restore failed: $e');
    }
  }

  // ── Stream Listener ─────────────────────────────────────────────────────

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          if (!mounted) return;
          state = state.copyWith(isLoading: true, errorMessage: '');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(purchaseDetails);
          break;
        case PurchaseStatus.error:
          debugPrint('[Purchase] ❌ Error: ${purchaseDetails.error}');
          if (!mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: purchaseDetails.error?.message ?? 'Purchase error.',
          );
          break;
        case PurchaseStatus.canceled:
          debugPrint('[Purchase] User canceled.');
          if (!mounted) return;
          state = state.copyWith(isLoading: false, errorMessage: '');
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails details) async {
    try {
      if (details.pendingCompletePurchase) {
        await _iap.completePurchase(details);
      }

      // Verify this is a product we recognize
      if (details.productID == AppConfig.productId || AppConfig.productIds.contains(details.productID)) {
        await _setProStatusLocally(true);
        await _syncSubscriptionToFirestore(details);
      }

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        successMessage: details.status == PurchaseStatus.restored ? 'Restored Successfully!' : 'Welcome to Premium! 🎉',
      );
    } catch (e) {
      debugPrint('[Purchase] Handle Success Error: $e');
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: 'Verification failed.');
    }
  }

  Future<void> _syncSubscriptionToFirestore(PurchaseDetails details) async {
    try {
      final user = _ref.read(authServiceProvider).currentUser;
      if (user == null) {
        debugPrint('[Purchase] Sync failed: User not logged in.');
        return;
      }

      final selectedPlan = state.selectedPackage;
      final Map<String, dynamic> subData = {
        'subscriptionStatus': 'premium',
        'productId': details.productID,
        'purchaseToken': details.verificationData.serverVerificationData, // CRITICAL for server-side validation
        'orderId': details.purchaseID,
        'subscriptionStartDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (selectedPlan != null) {
        subData['priceAmount'] = selectedPlan.price;
        subData['priceCurrencyCode'] = selectedPlan.product.currencyCode;
        subData['billingPeriod'] = selectedPlan.isYearly ? 'yearly' : 'monthly';
        
        // Strictly capture basePlanId for backend tracking
        try {
          if (selectedPlan.offer != null) {
            subData['basePlanId'] = selectedPlan.offer.basePlanId;
            subData['offerId'] = selectedPlan.offer.offerId;
          }
        } catch (_) {}
      }

      await _ref.read(userServiceProvider).updateSubscription(user.uid, subData);
      debugPrint('[Purchase] ✅ Firestore synced successfully with PurchaseToken.');
    } catch (e) {
      debugPrint('[Purchase] ❌ Firestore sync error: $e');
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
