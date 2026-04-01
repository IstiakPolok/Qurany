import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseApi {
  // Replace these with your actual API keys from the RevenueCat dashboard
  static const String _appleApiKey = 'appl_eylFxbOmIgnrdgxPJtySWuGEDrZ';
  static const String _googleApiKey = 'goog_YOUR_GOOGLE_API_KEY';

  // This must exactly match the entitlement identifier in RevenueCat dashboard.
  static const String premiumEntitlementId = 'Qurany Premium Pro';

  static bool _isPremium = false;

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[RevenueCat] $message');
    }
  }

  static Future<void> init() async {
    // Enable debug logs in development
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
      _log('Debug log level enabled');
    }

    PurchasesConfiguration configuration;
    if (Platform.isIOS || Platform.isMacOS) {
      if (_appleApiKey.trim().isEmpty || !_appleApiKey.startsWith('appl_')) {
        _log('WARNING: Apple API key looks invalid. Expected appl_...');
      }
      configuration = PurchasesConfiguration(_appleApiKey);
      _log('Configuring for Apple platform');
    } else if (Platform.isAndroid) {
      if (_googleApiKey.trim().isEmpty || !_googleApiKey.startsWith('goog_')) {
        _log('WARNING: Google API key looks invalid. Expected goog_...');
      }
      if (_googleApiKey.contains('YOUR_GOOGLE_API_KEY')) {
        _log('WARNING: Google API key is still placeholder text');
      }
      configuration = PurchasesConfiguration(_googleApiKey);
      _log('Configuring for Android platform');
    } else {
      _log('Unsupported platform for purchases. Skipping configuration');
      return; // RevenueCat doesn't support other platforms in this package
    }

    await Purchases.configure(configuration);
    _log('RevenueCat configured successfully');

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      final active =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
          false;
      _isPremium = active;
      _log('Customer info updated. premium=$active customerInfo=$customerInfo');
    });

    // Initial check for premium status
    await updatePremiumStatus();
  }

  /// Updates the internal [_isPremium] flag based on active entitlements.
  static Future<void> updatePremiumStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // Print backend UID for debugging
      _log('Current UID in RevenueCat: ${customerInfo.originalAppUserId}');

      // Log all entitlements to help debug if the ID is wrong
      if (kDebugMode) {
        final availableEntitlements = customerInfo.entitlements.all.keys.join(
          ', ',
        );
        _log('Available entitlements in RevenueCat: [$availableEntitlements]');

        for (var entitlement in customerInfo.entitlements.all.values) {
          _log(
            'Entitlement "${entitlement.identifier}" is active: ${entitlement.isActive}',
          );
        }
      }

      _isPremium =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
          false;
      _log(
        'Premium status updated: $_isPremium (checked for: $premiumEntitlementId)',
      );
    } catch (e) {
      _log('Error updating premium status: $e');
    }
  }

  /// Factual offerings defined in RevenueCat dashboard.
  static Future<List<Package>> fetchOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      _log('Fetched offerings. current=${offerings.current?.identifier}');

      if (offerings.all.isEmpty) {
        _log('No offerings found in RevenueCat project');
        return [];
      }

      for (final entry in offerings.all.entries) {
        final offeringId = entry.key;
        final offering = entry.value;
        final packageIds = offering.availablePackages
            .map((p) => p.identifier)
            .join(', ');
        _log(
          'Offering "$offeringId" has ${offering.availablePackages.length} packages${packageIds.isNotEmpty ? ': $packageIds' : ''}',
        );
      }

      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        _log(
          'Available packages: ${offerings.current!.availablePackages.map((p) => p.identifier).join(', ')}',
        );
        return offerings.current!.availablePackages;
      }

      // If current offering is not set, merge packages from all offerings.
      final mergedPackages = <Package>[];
      final seenKeys = <String>{};
      for (final offering in offerings.all.values) {
        for (final package in offering.availablePackages) {
          final key =
              '${package.identifier}|${package.storeProduct.identifier}';
          if (seenKeys.add(key)) {
            mergedPackages.add(package);
          }
        }
      }
      if (mergedPackages.isNotEmpty) {
        _log(
          'Using merged packages (${mergedPackages.length}) because current is null/empty: ${mergedPackages.map((p) => '${p.identifier}(${p.storeProduct.identifier})').join(', ')}',
        );
        return mergedPackages;
      }

      _log('No current offering or no available packages found');
    } catch (e) {
      _log('Error fetching offerings: $e');
    }
    return [];
  }

  /// Initiates a purchase for a specific RevenueCat package.
  static Future<(bool, String?)> purchasePackage(Package package) async {
    try {
      final canPay = await Purchases.canMakePayments();
      _log('canMakePayments=$canPay');
      if (!canPay) {
        return (false, 'Purchases are disabled on this device/account.');
      }

      _log('Starting purchase for package=${package.identifier}');
      PurchaseResult purchaseResult = await Purchases.purchasePackage(package);
      CustomerInfo customerInfo = purchaseResult.customerInfo;
      // Print backend UID for debugging
      _log('Purchase for UID in RevenueCat: ${customerInfo.originalAppUserId}');
      _isPremium =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
          false;
      _log('Purchase successful. premium=$_isPremium');
      return (true, null);
    } catch (e) {
      if (e is PlatformException) {
        final details = e.details;
        // Log full details map for diagnosis
        _log('Purchase PlatformException code=${e.code}, message=${e.message}');
        if (details is Map) {
          details.forEach((key, value) {
            _log('  detail[$key] = $value');
          });
        } else {
          _log('  details (raw) = $details');
        }
        final code = details is Map
            ? (details['readableErrorCode'] ?? details['readable_error_code'])
            : null;
        final userCancelled = details is Map
            ? (details['userCancelled'] == true)
            : false;
        if (userCancelled || code == 'PURCHASE_CANCELLED') {
          final underlyingMessage = details is Map
              ? details['underlyingErrorMessage']?.toString()
              : null;
          _log(
            'Purchase marked cancelled. underlyingErrorMessage=${underlyingMessage ?? 'none'}',
          );
          return (
            false,
            (underlyingMessage != null && underlyingMessage.isNotEmpty)
                ? underlyingMessage
                : null,
          );
        }
        // Return a user-friendly message with the error code
        return (
          false,
          'Purchase failed (code: ${code ?? e.code}). Please try again.',
        );
      }
      if (e is UnsupportedError) {
        _log('Purchase failed: unsupported platform');
        return (false, "Purchases not supported on this platform.");
      }
      _log('Purchase failed: $e');
      return (false, e.toString());
    }
  }

  /// Restores previous purchases for the user.
  static Future<(bool, String?)> restorePurchases() async {
    try {
      _log('Restoring purchases');
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _isPremium =
          customerInfo.entitlements.all[premiumEntitlementId]?.isActive ??
          false;
      _log('Restore completed. premium=$_isPremium');
      return (true, null);
    } catch (e) {
      _log('Restore failed: $e');
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
      _log('Logging in RevenueCat user: $userId');
      await Purchases.logIn(userId);
      await updatePremiumStatus();
    } catch (e) {
      _log('Error logging in RevenueCat: $e');
    }
  }

  /// Logs out the user.
  static Future<void> logOut() async {
    try {
      _log('Logging out RevenueCat user');
      await Purchases.logOut();
      _isPremium = false;
    } catch (e) {
      _log('Error logging out RevenueCat: $e');
    }
  }
}
