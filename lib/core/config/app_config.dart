import 'package:reducer/core/services/remote_config_service.dart';

class AppConfig {
  static const String appName = 'Reducer';

  // Subscription Configuration
  /// The parent subscription product ID configured in Google Play Console.
  static String get productId => RemoteConfigService().productId;

  /// Base Plan IDs (children of the product, configured under the subscription in Console).
  static String get monthlyBasePlanId => RemoteConfigService().monthlyPlanId;
  static String get testplan => RemoteConfigService().testPlanId;
  static String get yearlyBasePlanId => RemoteConfigService().yearlyPlanId;

  /// Product IDs to query from the store via `queryProductDetails`.
  /// IMPORTANT: Only include actual product IDs here, NOT base plan IDs.
  /// Base plans are returned as `subscriptionOfferDetails` within each product.
  static Set<String> get productIds => {productId};

  /// All recognized base plan IDs for validation purposes.
  static Set<String> get basePlanIds => {
    monthlyBasePlanId,
    yearlyBasePlanId,
    testplan,
  };

  // Firebase Collection Names
  static const String usersCollection = 'users';
}
