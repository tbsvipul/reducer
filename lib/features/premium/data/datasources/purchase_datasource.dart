import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reducer/core/ads/ad_manager.dart';

// ─── Keys for SecureStorage ─────────────────────────────────────────────────
const String _kSecIsPro = 'is_pro_user';
const String _kSecProVerifiedAt = 'pro_verified_at_ms';

/// How often to re-validate the subscription against the store (hours).
const int _kRevalidationIntervalHours = 24;

/// Provider for managing the Premium/Pro status and purchase flow.
///
/// **MUST NOT be autoDispose** — the purchase-stream listener must survive
/// navigation away from the paywall. If the listener dies while a purchase is
/// pending, the purchase will never be acknowledged and Google will auto-refund
/// it after 3 days.
final premiumControllerProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>(
  (ref) => PurchaseNotifier(),
);

// ─── State ──────────────────────────────────────────────────────────────────
class PurchaseState {
  final bool isPro;
  final bool isLoading;
  final List<ProductDetails> availablePackages;
  final ProductDetails? selectedPackage;
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
    List<ProductDetails>? availablePackages,
    ProductDetails? selectedPackage,
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
  final InAppPurchase _iap = InAppPurchase.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  /// Prevents double-tap on the Subscribe button.
  bool _purchaseInProgress = false;

  // EXACT PLAY CONSOLE IDs
  static const Set<String> _kProductIds = {
    'premium_monthly',
    'premium_yearly',
  };

  PurchaseNotifier() : super(PurchaseState()) {
    _init();
  }

  // ── Initialization ──────────────────────────────────────────────────────

  Future<void> _init() async {
    // 1. Subscribe to the purchase stream FIRST so we never miss events.
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

    // 2. Load cached pro status and fetch offers.
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
        debugPrint(
          '[Purchase] Pro-status stale (${hoursSince.toStringAsFixed(1)}h), '
          're-validation will run via restore in background.',
        );
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
    }
    AdManager.isPremium = pro;
    if (!mounted) return;
    state = state.copyWith(isPro: pro);
  }

  // ── Fetch Offers ────────────────────────────────────────────────────────

  Future<void> fetchOffersAndCheckStatus() async {
    if (!mounted) return;
    state =
        state.copyWith(isLoading: true, errorMessage: '', successMessage: '');

    try {
      await _checkProStatusLocally();

      final bool available = await _iap.isAvailable();
      if (!available) {
        if (!mounted) return;
        state = state.copyWith(
          errorMessage: 'Store is currently unavailable.',
          isLoading: false,
        );
        return;
      }

      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_kProductIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found in store: ${response.notFoundIDs}');
      }

      if (response.productDetails.isEmpty) {
        if (!mounted) return;
        state = state.copyWith(
          errorMessage: 'No subscription plans available.',
          isLoading: false,
        );
        return;
      }

      final packages = List<ProductDetails>.from(response.productDetails);
      packages.sort((a, b) {
        if (a.id == 'premium_yearly') return -1;
        if (b.id == 'premium_yearly') return 1;
        return 0;
      });

      if (!mounted) return;
      state = state.copyWith(
        availablePackages: packages,
        selectedPackage: packages.isNotEmpty ? packages.first : null,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        errorMessage: 'Failed to load plans: $e',
        isLoading: false,
      );
    }
  }

  void selectPackage(ProductDetails package) {
    state = state.copyWith(
      selectedPackage: package,
      errorMessage: '',
      successMessage: '',
    );
  }

  // ── Purchase ────────────────────────────────────────────────────────────

  Future<void> purchaseSelectedPackage() async {
    if (state.selectedPackage == null || _purchaseInProgress) return;

    _purchaseInProgress = true;
    state =
        state.copyWith(isLoading: true, errorMessage: '', successMessage: '');

    try {
      final ProductDetails product = state.selectedPackage!;

      late PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        purchaseParam = GooglePlayPurchaseParam(productDetails: product);
      } else {
        purchaseParam = PurchaseParam(productDetails: product);
      }

      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    } finally {
      _purchaseInProgress = false;
    }
  }

  // ── Restore ─────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    state =
        state.copyWith(isLoading: true, errorMessage: '', successMessage: '');
    try {
      await _iap.restorePurchases();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to restore: $e',
      );
    }
  }

  // ── Stream Listener ─────────────────────────────────────────────────────

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
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
          debugPrint('Purchase error: ${purchaseDetails.error}');
          if (!mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: purchaseDetails.error?.message ?? 'Purchase error.',
          );
          break;

        case PurchaseStatus.canceled:
          if (!mounted) return;
          state = state.copyWith(isLoading: false, errorMessage: '');
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(PurchaseDetails details) async {
    try {
      // TODO: IMPLEMENT SERVER VALIDATION HERE

      if (details.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(details);
        } catch (e) {
          debugPrint('completePurchase failed: $e');
        }
      }

      if (_kProductIds.contains(details.productID)) {
        await _setProStatusLocally(true);
        AdManager().disposeAll();
      }

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        successMessage: details.status == PurchaseStatus.restored
            ? 'Purchase restored!'
            : 'Welcome to Premium! 🎉',
      );
    } catch (e) {
      debugPrint('Error handling purchase: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Verification failed. Try restoring later.',
      );
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
