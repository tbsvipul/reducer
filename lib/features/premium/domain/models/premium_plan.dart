import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:reducer/core/config/app_config.dart';

/// Model representing a specific subscription plan (offer) fetched from the store.
///
/// This implementation is 100% dynamic, deriving all text and pricing from
/// the ProductDetails and SubscriptionOfferDetailsWrapper objects provided by Google Play.
///
/// Each PremiumPlan maps to one base plan (offer) within a parent subscription product.
class PremiumPlan {
  final ProductDetails product;

  /// The specific subscription offer from Google Play.
  /// Each offer corresponds to a base plan (monthly, yearly, test, etc.)
  /// and contains its own pricing phases with correct prices.
  final SubscriptionOfferDetailsWrapper? offer;

  const PremiumPlan({required this.product, this.offer});

  /// Map of ISO 8601 durations to human-readable period names.
  static const Map<String, String> _periodMap = {
    'P1W': 'Weekly',
    'P1M': 'Monthly',
    'P3M': 'Quarterly',
    'P6M': '6 Months',
    'P1Y': 'Yearly',
  };

  // ── Unique Identity ──────────────────────────────────────────────────────

  /// A unique key for this plan, combining product ID + base plan ID + offer ID.
  String get _offerKey {
    if (offer != null) {
      return '${offer!.basePlanId}_${offer!.offerId ?? "base"}';
    }
    return 'no_offer';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PremiumPlan &&
          runtimeType == other.runtimeType &&
          product.id == other.product.id &&
          _offerKey == other._offerKey;

  @override
  int get hashCode => product.id.hashCode ^ _offerKey.hashCode;

  // ── Billing Period ───────────────────────────────────────────────────────

  /// The raw ISO 8601 billing period (e.g., "P1M", "P1Y") from the last pricing phase.
  /// The last phase is typically the recurring (non-trial) phase.
  String get _billingPeriod {
    if (offer != null) {
      final phases = offer!.pricingPhases;
      if (phases.isNotEmpty) {
        return phases.last.billingPeriod;
      }
    }
    return '';
  }

  /// The human-readable name of the billing cycle (e.g., "Monthly").
  String get periodName {
    if (isYearly) return 'Yearly';
    if (isMonthly) return 'Monthly';
    if (isTestPlan) return 'Trial';

    final bp = _billingPeriod.toUpperCase();
    return _periodMap[bp] ?? 'Premium';
  }

  // ── Price ────────────────────────────────────────────────────────────────

  /// Returns the current formatted price text (e.g., "₹99.00", "$9.99").
  /// Uses the LAST pricing phase (the recurring phase) from the specific offer.
  String get price {
    if (offer != null) {
      final phases = offer!.pricingPhases;
      if (phases.isNotEmpty) {
        final formattedPrice = phases.last.formattedPrice;
        if (formattedPrice.isNotEmpty) {
          return formattedPrice;
        }
      }
    }
    // Fallback: product-level price (same for all offers - should rarely hit)
    return product.price;
  }

  /// Price amount in micros (millionths of the currency) for the recurring phase.
  /// Useful for computing savings between plans.
  int get priceAmountMicros {
    if (offer != null) {
      final phases = offer!.pricingPhases;
      if (phases.isNotEmpty) {
        return phases.last.priceAmountMicros;
      }
    }
    return 0;
  }

  /// Monthly equivalent price in micros (for comparing yearly vs monthly).
  int get monthlyEquivalentMicros {
    if (isYearly) return (priceAmountMicros / 12).round();
    return priceAmountMicros;
  }

  // ── Trial ────────────────────────────────────────────────────────────────

  /// Checks if this plan has an active introductory or free trial phase.
  String? get trialPeriod {
    if (offer != null) {
      final phases = offer!.pricingPhases;
      if (phases.length > 1) {
        // Typically the first phase(s) are trials/intro prices
        final firstPhase = phases.first;
        if (firstPhase.priceAmountMicros == 0) {
          final period = firstPhase.billingPeriod;
          if (period == 'P3D') return '3 Days';
          if (period == 'P7D') return '7 Days';
          if (period == 'P1W') return '1 Week';
          if (period == 'P1M') return '1 Month';
          return period.replaceAll('P', '');
        }
      }
    }
    return null;
  }

  // ── Plan Identification ──────────────────────────────────────────────────

  /// Strictly identifies if this is the yearly plan based on the Base Plan ID in Console.
  bool get isYearly {
    if (offer != null) {
      return offer!.basePlanId == AppConfig.yearlyBasePlanId;
    }
    return _billingPeriod.toUpperCase() == 'P1Y' ||
        product.id.contains('yearly');
  }

  /// Strictly identifies if this is the monthly plan based on the Base Plan ID in Console.
  bool get isMonthly {
    if (offer != null) {
      return offer!.basePlanId == AppConfig.monthlyBasePlanId;
    }
    return _billingPeriod.toUpperCase() == 'P1M' ||
        product.id.contains('monthly');
  }

  /// Strictly identifies if this is the test/trial plan.
  bool get isTestPlan {
    if (offer != null) {
      return offer!.basePlanId == AppConfig.testplan;
    }
    return product.id.contains('test');
  }

  // ── Display Text ─────────────────────────────────────────────────────────

  /// The main title shown on the plan card.
  String get titleText {
    return '$periodName Plan';
  }

  /// Text describing the billing frequency.
  String get billingFrequencyText {
    if (isYearly) return 'Billed yearly';
    if (isMonthly) return 'Billed monthly';
    if (isTestPlan) return 'Trial access';
    return 'Billed every ${_billingPeriod.replaceAll('P', '')}';
  }

  /// The combined price/period text (e.g., "$99.99 / year").
  String get periodPriceLabel {
    final suffix = isYearly ? 'year' : (isMonthly ? 'month' : 'period');
    return '$price / $suffix';
  }

  /// The offer token needed for purchasing this specific base plan on Android.
  String get offerToken {
    return offer?.offerIdToken ?? '';
  }

  @override
  String toString() =>
      'PremiumPlan(${product.id}, ${offer?.basePlanId ?? "no-offer"}, $price)';
}
