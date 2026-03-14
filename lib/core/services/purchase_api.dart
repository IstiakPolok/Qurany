import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseApi {
  // Replace these with your actual API keys from the RevenueCat dashboard
  static const String _appleApiKey = 'appl_tyNGhoTvHRJisxWuEbXuODzxzqW';
  static const String _googleApiKey = 'goog_YOUR_GOOGLE_API_KEY';

  // The entitlement ID you defined in the RevenueCat dashboard (e.g., "premium" or "premium_access")
  static const String premiumEntitlementId = 'premium';

  static bool _isPremium = false;

  static Future<void> init() async {
    // Enable debug logs in development
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    PurchasesConfiguration configuration;
    if (Platform.isIOS || Platform.isMacOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    } else if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else {
      return; // RevenueCat doesn't support other platforms in this package
    }

    await Purchases.configure(configuration);

    // Initial check for premium status
    await updatePremiumStatus();
  }

  /// Updates the internal [_isPremium] flag based on active entitlements.
  static Future<void> updatePremiumStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _isPremium =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
          false;
      debugPrint("Premium status updated: $_isPremium");
    } catch (e) {
      debugPrint("Error updating premium status: $e");
    }
  }

  /// Factual offerings defined in RevenueCat dashboard.
  static Future<List<Package>> fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      debugPrint("Error fetching offerings: $e");
    }
    return [];
  }

  /// Initiates a purchase for a specific RevenueCat package.
  static Future<(bool, String?)> purchasePackage(Package package) async {
    try {
      PurchaseResult purchaseResult = await Purchases.purchasePackage(package);
      CustomerInfo customerInfo = purchaseResult.customerInfo;
      _isPremium =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
          false;
      return (true, null);
    } catch (e) {
      if (e is UnsupportedError) {
        return (false, "Purchases not supported on this platform.");
      }
      // Check if user cancelled
      // RevenueCat throws a PlatformException for cancellations
      return (false, e.toString());
    }
  }

  /// Restores previous purchases for the user.
  static Future<(bool, String?)> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _isPremium =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
          false;
      return (true, null);
    } catch (e) {
      return (false, "Failed to restore purchases: $e");
    }
  }

  static bool isUserPremium() {
    return _isPremium;
  }

  /// Logs in the user with their unique ID (e.g., Firebase UID).
  /// This ensures that webhooks correctly identify who made the purchase.
  static Future<void> logIn(String userId) async {
    try {
      await Purchases.logIn(userId);
      await updatePremiumStatus();
    } catch (e) {
      debugPrint("Error logging in RevenueCat: $e");
    }
  }

  /// Logs out the user.
  static Future<void> logOut() async {
    try {
      await Purchases.logOut();
      _isPremium = false;
    } catch (e) {
      debugPrint("Error logging out RevenueCat: $e");
    }
  }
}
