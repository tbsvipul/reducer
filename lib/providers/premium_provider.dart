import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/purchase_service.dart';
import '../ads/remote_config_service.dart';
import '../services/connectivity_service.dart';
import '../ads/ad_service.dart';

class PremiumState {
  final bool isPro;
  final bool isLoading;
  final List<Package> availablePackages;
  final Package? selectedPackage;
  final String? errorMessage;
  final int retryCount;
  final bool hasAttemptedFetch;

  PremiumState({
    required this.isPro,
    required this.isLoading,
    required this.availablePackages,
    this.selectedPackage,
    this.errorMessage,
    this.retryCount = 0,
    this.hasAttemptedFetch = false,
  });

  PremiumState copyWith({
    bool? isPro,
    bool? isLoading,
    List<Package>? availablePackages,
    Package? selectedPackage,
    String? errorMessage,
    int? retryCount,
    bool? hasAttemptedFetch,
  }) {
    return PremiumState(
      isPro: isPro ?? this.isPro,
      isLoading: isLoading ?? this.isLoading,
      availablePackages: availablePackages ?? this.availablePackages,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      hasAttemptedFetch: hasAttemptedFetch ?? this.hasAttemptedFetch,
    );
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  return PremiumNotifier();
});

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier()
      : super(PremiumState(
          isPro: false,
          isLoading: true,
          availablePackages: [],
          errorMessage: null,
        )) {
    _init();
  }

  final _connectivity = ConnectivityService();
  final _remoteConfig = RemoteConfigService();

  void _init() {
    if (!PurchaseService.isMockMode) {
      // Listen for changes
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updateStatus(customerInfo);
      });

      // Listen for connectivity changes and retry if needed
      _connectivity.isConnected.addListener(() {
        if (_connectivity.isConnected.value &&
            state.availablePackages.isEmpty &&
            state.hasAttemptedFetch &&
            state.retryCount < 3) {
          debugPrint('🔄 Connectivity restored - retrying purchase fetch');
          fetchOffersAndCheckStatus();
        }
      });
    }
    fetchOffersAndCheckStatus();
  }

  Future<void> fetchOffersAndCheckStatus() async {
    // Skip real logic in mock mode
    if (PurchaseService.isMockMode) {
      debugPrint('ℹ️ PurchaseNotifier: Running in Mock Mode');
      state = state.copyWith(isLoading: true, errorMessage: null);
      await Future.delayed(const Duration(milliseconds: 800));
      state = state.copyWith(isLoading: false, isPro: false);
      AdService.isPremium = false;
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        hasAttemptedFetch: true,
        retryCount: state.retryCount + 1,
      );

      // Check connectivity first
      if (!_connectivity.currentStatus) {
        state = state.copyWith(
          errorMessage: "No internet connection. Please check your network.",
          isLoading: false,
        );
        debugPrint('❌ No internet connection');
        return;
      }

      debugPrint('🔄 Fetching offerings (attempt ${state.retryCount})...');

      final offerings = await Purchases.getOfferings();

      if (offerings.current == null || offerings.current!.availablePackages.isEmpty) {
        state = state.copyWith(
          errorMessage: "No subscription plans available at this time.",
          isLoading: false,
        );
        debugPrint('⚠️ No offerings available');
        return;
      }

      final packages = offerings.current!.availablePackages
          .where((package) => _isSubscriptionPackage(package))
          .toList();

      // Sort: Yearly > 6-month > 3-month > Monthly > Weekly
      packages.sort((a, b) {
        int score(Package p) {
          if (_isYearly(p)) return 5;
          if (p.packageType == PackageType.sixMonth) return 4;
          if (p.packageType == PackageType.threeMonth) return 3;
          if (p.packageType == PackageType.monthly) return 2;
          if (p.packageType == PackageType.weekly) return 1;
          return 0;
        }
        return score(b).compareTo(score(a)); // Highest first
      });

      debugPrint('✅ PACKAGES LOADED (${packages.length})');

      // Select default package based on remote config
      Package? selectedPackage;
      if (packages.isNotEmpty) {
        final preferYearly = _remoteConfig.getBool(RemoteConfigService.defaultYearlySelectPackage);
        if (preferYearly) {
          selectedPackage = packages.first;
          debugPrint('📌 Selected yearly package by default');
        } else {
          selectedPackage = packages.firstWhere(
            (p) => !_isYearly(p),
            orElse: () => packages.first,
          );
          debugPrint('📌 Selected non-yearly package by default');
        }
      }

      // Check subscription status
      final customerInfo = await Purchases.getCustomerInfo();
      final isPro = customerInfo.entitlements.active.isNotEmpty;
      debugPrint('👤 User Pro Status: $isPro');

      state = state.copyWith(
        availablePackages: packages,
        selectedPackage: selectedPackage,
        isPro: isPro,
        isLoading: false,
        retryCount: 0, // Reset retry count on success
      );

      debugPrint('✅ Purchase notifier initialized successfully');

    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to load plans: ${_getErrorMessage(errorCode)}",
      );
      debugPrint('❌ Purchase Error (PlatformException): $errorCode - ${e.message}');

      // Retry logic for network/config errors
      if (_shouldRetry(errorCode) && state.retryCount < 3) {
        final delaySeconds = 2 * state.retryCount;
        debugPrint('⏳ Retrying in $delaySeconds seconds...');
        await Future.delayed(Duration(seconds: delaySeconds));
        fetchOffersAndCheckStatus();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to load plans: ${e.toString()}",
      );
      debugPrint('❌ Purchase Error (General): $e');

      // Retry for general errors
      if (state.retryCount < 3) {
        final delaySeconds = 2 * state.retryCount;
        debugPrint('⏳ Retrying in $delaySeconds seconds...');
        await Future.delayed(Duration(seconds: delaySeconds));
        fetchOffersAndCheckStatus();
      }
    } finally {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  void _updateStatus(CustomerInfo info) {
    state = state.copyWith(isPro: info.entitlements.active.isNotEmpty);
    AdService.isPremium = state.isPro;
    debugPrint('👤 User subscription updated: Pro = ${state.isPro}');
  }

  void selectPackage(Package package) {
    state = state.copyWith(selectedPackage: package);
    debugPrint('📌 Package selected: ${package.identifier}');
  }

  Future<bool> purchase(Package? package) async {
    final toPurchase = package ?? state.selectedPackage;

    if (PurchaseService.isMockMode) {
      debugPrint('🛒 Mock Mode: Simulating successful purchase');
      state = state.copyWith(isPro: true);
      AdService.isPremium = true;
      return true;
    }

    if (toPurchase == null) {
      debugPrint('❌ No package selected');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true);
      debugPrint('🛒 Starting purchase: ${toPurchase.identifier}');

      final result = await Purchases.purchasePackage(toPurchase);

      if (result.customerInfo.entitlements.active.isNotEmpty) {
        debugPrint('✅ Purchase successful!');
        _updateStatus(result.customerInfo);
        return true;
      } else {
        debugPrint('⚠️ Purchase completed but no active entitlements');
        return false;
      }
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('❌ Purchase error: $code - ${e.message}');
      state = state.copyWith(errorMessage: _getErrorMessage(code));
      return false;
    } catch (e) {
      debugPrint('❌ Purchase error (general): $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> restore() async {
    if (PurchaseService.isMockMode) {
      state = state.copyWith(isPro: true);
      return;
    }

    try {
      state = state.copyWith(isLoading: true);
      debugPrint('🔄 Restoring purchases...');
      final info = await Purchases.restorePurchases();
      _updateStatus(info);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('❌ Restore error: $code - ${e.message}');
      state = state.copyWith(errorMessage: "Restore failed: ${_getErrorMessage(code)}");
    } catch (e) {
      debugPrint('❌ Restore error (general): $e');
      state = state.copyWith(errorMessage: "Restore failed: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // --- Helpers ported from user logic ---

  bool _shouldRetry(PurchasesErrorCode errorCode) {
    return errorCode == PurchasesErrorCode.networkError ||
        errorCode == PurchasesErrorCode.unknownError ||
        errorCode == PurchasesErrorCode.configurationError;
  }

  String _getErrorMessage(PurchasesErrorCode errorCode) {
    switch (errorCode) {
      case PurchasesErrorCode.networkError:
        return "Network error. Please check your connection.";
      case PurchasesErrorCode.configurationError:
        return "Configuration error. Please try again later.";
      case PurchasesErrorCode.unknownError:
        return "Unknown error. Please try again.";
      case PurchasesErrorCode.purchaseCancelledError:
        return "Purchase cancelled.";
      default:
        return errorCode.toString();
    }
  }

  bool _isSubscriptionPackage(Package package) {
    final id = package.identifier.toLowerCase();
    final title = package.storeProduct.title.toLowerCase();
    final desc = package.storeProduct.description.toLowerCase();

    // Exclude non-subscriptions
    final exclude = ['coin', 'credit', 'token', 'point', 'pack', 'bundle', 'tip'];
    if (exclude.any((k) => id.contains(k) || title.contains(k) || desc.contains(k))) {
      return false;
    }

    // Include subscriptions
    return package.packageType == PackageType.monthly ||
        package.packageType == PackageType.annual ||
        package.packageType == PackageType.sixMonth ||
        package.packageType == PackageType.threeMonth ||
        package.packageType == PackageType.weekly ||
        ['month', 'year', 'annual', 'week', 'subscription', 'pro', 'premium']
            .any((k) => id.contains(k) || title.contains(k));
  }

  bool _isYearly(Package package) {
    final id = package.identifier.toLowerCase();
    final title = package.storeProduct.title.toLowerCase();
    return package.packageType == PackageType.annual ||
        id.contains('year') ||
        id.contains('annual') ||
        title.contains('year') ||
        title.contains('annual');
  }
}
