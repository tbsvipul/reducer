import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static const _apiKey = "goog_placeholder_api_key"; // User needs to replace this
  static bool isMockMode = kDebugMode; // Use mock mode in debug, real in release

  static Future<void> initialize() async {
    if (isMockMode) return;
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKey);
    }
    
    if (configuration != null) {
      await Purchases.configure(configuration);
    }
  }

  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      return null;
    }
  }

  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    try {
      await Purchases.purchasePackage(package);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
    } catch (e) {
      // Handle error
    }
  }
}
