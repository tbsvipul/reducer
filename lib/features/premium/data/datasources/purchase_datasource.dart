import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:reducer/core/ads/ad_manager.dart';
import 'package:reducer/core/config/app_config.dart';
import 'package:reducer/core/services/notification_service.dart';
import 'package:reducer/features/auth/presentation/controllers/auth_controller.dart';
import 'package:reducer/features/premium/domain/models/premium_plan.dart';

import '../../../auth/domain/models/user_model.dart';

const String _kSecIsPro = 'is_pro_user';
const String _kSecProVerifiedAt = 'pro_verified_at_ms';
const String _kSecProIntegrity = 'pro_integrity_v1';

const int _kRevalidationIntervalHours = 24;

final premiumControllerProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>(
      (ref) => PurchaseNotifier(ref),
    );

enum PurchaseStatusType { none, purchaseSuccess, restoreSuccess, error }

class PurchaseState {
  final bool isPro;
  final bool isLoading;
  final List<PremiumPlan> availablePackages;
  final PremiumPlan? selectedPackage;
  final String errorMessage;
  final String successMessage;
  final PurchaseStatusType statusType;

  const PurchaseState({
    this.isPro = false,
    this.isLoading = true,
    this.availablePackages = const [],
    this.selectedPackage,
    this.errorMessage = '',
    this.successMessage = '',
    this.statusType = PurchaseStatusType.none,
  });

  PurchaseState copyWith({
    bool? isPro,
    bool? isLoading,
    List<PremiumPlan>? availablePackages,
    PremiumPlan? selectedPackage,
    String? errorMessage,
    String? successMessage,
    PurchaseStatusType? statusType,
  }) {
    return PurchaseState(
      isPro: isPro ?? this.isPro,
      isLoading: isLoading ?? this.isLoading,
      availablePackages: availablePackages ?? this.availablePackages,
      selectedPackage: selectedPackage ?? this.selectedPackage,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      statusType: statusType ?? this.statusType,
    );
  }
}

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _purchaseInProgress = false;

  PurchaseNotifier(this._ref) : super(const PurchaseState()) {
    _init();
    _listenToUserChanges();
  }

  AppUser? get _currentUser => _ref.read(authRepositoryProvider).currentUser;

  void _listenToUserChanges() {
    // Watch userProvider for real-time Firestore updates
    _ref.listen<AsyncValue<AppUser?>>(userProvider, (previous, next) {
      final user = next.value;
      if (user != null) {
        final isPro = user.subscriptionStatus == 'premium';
        if (isPro != state.isPro) {
          _setProStatusLocally(isPro);
        }
      } else {
        if (state.isPro) {
          _setProStatusLocally(false);
        }
      }
    });
  }

  bool get _hasEligiblePremiumAccount {
    final user = _currentUser;
    return user != null && !user.isAnonymous;
  }

  Future<void> _init() async {
    _purchaseSubscription = _iap.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onError: (Object error) {
        if (!mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: _sanitizeMessage(error.toString()),
          statusType: PurchaseStatusType.error,
        );
      },
    );

    await fetchOffersAndCheckStatus();
  }

  String _sanitizeMessage(String raw) {
    if (raw.startsWith('Exception: ')) {
      return raw.replaceFirst('Exception: ', '');
    }
    return raw;
  }

  String _generateIntegrityHash(String uid) {
    const salt = String.fromEnvironment(
      'PREMIUM_INTEGRITY_SALT',
      defaultValue: 'reducer_default_secure_fallback_2026',
    );

    if (kDebugMode && salt == 'reducer_default_secure_fallback_2026') {
      debugPrint(
        '[Security] PREMIUM_INTEGRITY_SALT is default. Configure a project salt in production.',
      );
    }

    final key = utf8.encode(salt);
    final bytes = utf8.encode(uid);
    return Hmac(sha256, key).convert(bytes).toString();
  }

  Future<void> _setProStatusLocally(bool pro) async {
    final user = _currentUser;
    if (user == null) return;

    await _secureStorage.write(key: _kSecIsPro, value: pro ? 'true' : 'false');
    if (pro) {
      await _secureStorage.write(
        key: _kSecProVerifiedAt,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      await _secureStorage.write(
        key: _kSecProIntegrity,
        value: _generateIntegrityHash(user.uid),
      );
    } else {
      await _secureStorage.delete(key: _kSecProVerifiedAt);
      await _secureStorage.delete(key: _kSecProIntegrity);
    }

    AdManager.updatePremiumStatus(pro);
    if (!mounted) return;
    state = state.copyWith(isPro: pro);
  }

  Future<void> clearProStatus() async {
    await _setProStatusLocally(false);
  }

  Future<void> _checkProStatusLocally() async {
    final user = _currentUser;
    if (user == null || user.isAnonymous) {
      await _setProStatusLocally(false);
      return;
    }

    final isProStr = await _secureStorage.read(key: _kSecIsPro);
    var isPro = isProStr == 'true';

    final storedHash = await _secureStorage.read(key: _kSecProIntegrity);
    final expectedHash = _generateIntegrityHash(user.uid);
    if (isPro && storedHash != expectedHash) {
      debugPrint(
        '[Security] Local entitlement hash mismatch. Resetting premium state.',
      );
      await clearProStatus();
      return;
    }

    if (isPro) {
      final lastVerifiedMsStr = await _secureStorage.read(
        key: _kSecProVerifiedAt,
      );
      final lastVerifiedMs = int.tryParse(lastVerifiedMsStr ?? '') ?? 0;
      final hoursSince =
          (DateTime.now().millisecondsSinceEpoch - lastVerifiedMs) /
          (1000 * 60 * 60);
      if (hoursSince > _kRevalidationIntervalHours) {
        final verified = await _verifyStoredSubscriptionFromServer();
        if (!verified) {
          await _setProStatusLocally(false);
          return;
        }
        isPro = true;
      }
    } else {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final userData = AppUser.fromFirestore(doc);
          final remoteStatus = userData.subscriptionStatus;
          
          if (remoteStatus == 'premium') {
            // We trust Firestore status, but trigger background verification if possible
            isPro = true;
            unawaited(_verifyStoredSubscriptionFromServer());
          }
        }
      } catch (e) {
        debugPrint('[Purchase] Firestore check failed: $e');
      }
    }

    AdManager.updatePremiumStatus(isPro);
    if (!mounted) return;
    state = state.copyWith(isPro: isPro);
  }

  Future<bool> _verifyStoredSubscriptionFromServer() async {
    try {
      final callable = _functions.httpsCallable('verifyStoredSubscription');
      final result = await callable.call();
      final data = Map<String, dynamic>.from(
        (result.data as Map?) ?? const <String, dynamic>{},
      );
      final isActive = data['isActive'] == true;
      await _setProStatusLocally(isActive);
      return isActive;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('[Purchase] verifyStoredSubscription failed: ${e.code}');
      return false;
    } catch (e) {
      debugPrint('[Purchase] verifyStoredSubscription unexpected error: $e');
      return false;
    }
  }

  Future<void> fetchOffersAndCheckStatus() async {
    if (!mounted) return;
    state = state.copyWith(
      isLoading: true,
      errorMessage: '',
      successMessage: '',
      statusType: PurchaseStatusType.none,
    );

    try {
      await _checkProStatusLocally();

      final available = await _iap.isAvailable();
      if (!available) {
        if (!mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Store unavailable.',
        );
        return;
      }

      final response = await _iap.queryProductDetails(AppConfig.productIds);

      if (response.error != null) {
        if (!mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Store error: ${response.error!.message}',
        );
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
              final planId =
                  '${product.id}_${offer.basePlanId}_${offer.offerId ?? "base"}';
              if (seenPlanIds.add(planId)) {
                packages.add(plan);
              }
            }
          } else {
            packages.add(PremiumPlan(product: product));
          }
        } else {
          packages.add(PremiumPlan(product: product));
        }
      }

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
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load plans: ${_sanitizeMessage(e.toString())}',
      );
    }
  }

  void selectPackage(PremiumPlan package) {
    state = state.copyWith(
      selectedPackage: package,
      errorMessage: '',
      successMessage: '',
      statusType: PurchaseStatusType.none,
    );
  }

  Future<void> purchaseSelectedPackage() async {
    if (state.selectedPackage == null || _purchaseInProgress) return;
    if (!_hasEligiblePremiumAccount) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please login to unlock Premium.',
      );
      return;
    }

    final plan = state.selectedPackage!;
    _purchaseInProgress = true;
    state = state.copyWith(
      isLoading: true,
      errorMessage: '',
      successMessage: '',
      statusType: PurchaseStatusType.none,
    );

    try {
      final purchaseParam = _createPurchaseParam(plan);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Purchase failed: ${_sanitizeMessage(e.toString())}',
        statusType: PurchaseStatusType.error,
      );
    } finally {
      _purchaseInProgress = false;
    }
  }

  PurchaseParam _createPurchaseParam(PremiumPlan plan) {
    if (!Platform.isAndroid) {
      return PurchaseParam(productDetails: plan.product);
    }

    final offerToken = _resolveAndroidOfferToken(plan);
    if (offerToken == null || offerToken.isEmpty) {
      throw Exception(
        'Missing Android offer token for selected plan. '
        'Check Play Console base plan activation.',
      );
    }

    return GooglePlayPurchaseParam(
      productDetails: plan.product,
      offerToken: offerToken,
    );
  }

  String? _resolveAndroidOfferToken(PremiumPlan plan) {
    if (plan.offer != null && plan.offer!.offerIdToken.isNotEmpty) {
      return plan.offer!.offerIdToken;
    }

    if (plan.product is GooglePlayProductDetails) {
      final details = plan.product as GooglePlayProductDetails;
      final token = details.offerToken;
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }
    return null;
  }

  Future<void> restorePurchases() async {
    if (!_hasEligiblePremiumAccount) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please login to unlock Premium.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: '',
      successMessage: '',
      statusType: PurchaseStatusType.none,
    );

    try {
      await _iap.restorePurchases();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Restore failed: ${_sanitizeMessage(e.toString())}',
        statusType: PurchaseStatusType.error,
      );
    }
  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final details in purchases) {
      switch (details.status) {
        case PurchaseStatus.pending:
          if (!mounted) return;
          state = state.copyWith(isLoading: true, errorMessage: '');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _handleSuccessfulPurchase(details);
          break;
        case PurchaseStatus.error:
          if (!mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: details.error?.message ?? 'Purchase error.',
            statusType: PurchaseStatusType.error,
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
      if (details.pendingCompletePurchase) {
        await _iap.completePurchase(details);
      }

      final recognized =
          details.productID == AppConfig.productId ||
          AppConfig.productIds.contains(details.productID);
      if (!recognized) {
        throw Exception('Unrecognized product purchase.');
      }

      final verified = await _verifyWithServer(details);
      if (!verified) {
        throw Exception('Server verification rejected the purchase.');
      }

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        statusType: details.status == PurchaseStatus.restored
            ? PurchaseStatusType.restoreSuccess
            : PurchaseStatusType.purchaseSuccess,
      );

      if (details.status == PurchaseStatus.purchased) {
        unawaited(
          Future<void>.delayed(const Duration(milliseconds: 500), () {
            return NotificationService().showNotification(
              id: 102,
              title: 'Congratulations!',
              body: 'Premium unlocked successfully.',
            );
          }),
        );
      }
    } catch (e) {
      await _setProStatusLocally(false);
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: _sanitizeMessage(e.toString()),
        statusType: PurchaseStatusType.error,
      );
    }
  }

  Future<bool> _verifyWithServer(PurchaseDetails details) async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final selected = state.selectedPackage;
      final callable = _functions.httpsCallable('verifySubscription');

      final payload = <String, dynamic>{
        'platform': platform,
        'productId': details.productID,
        'purchaseToken': details.verificationData.serverVerificationData,
        'receiptData': platform == 'ios'
            ? (details.verificationData.localVerificationData.isNotEmpty
                  ? details.verificationData.localVerificationData
                  : details.verificationData.serverVerificationData)
            : null,
        'basePlanId': selected?.offer?.basePlanId,
      };

      final response = await callable.call(payload);
      final data = Map<String, dynamic>.from(
        (response.data as Map?) ?? const <String, dynamic>{},
      );

      final isActive = data['isActive'] == true;
      await _setProStatusLocally(isActive);
      return isActive;
    } on FirebaseFunctionsException catch (e) {
      final message = e.message ?? 'Subscription verification failed.';
      throw Exception(message);
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
