import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';
import '../../../core/services/purchase_api.dart';
import '../controller/profile_controller.dart';

class PremiumPlanScreen extends StatefulWidget {
  const PremiumPlanScreen({super.key});

  @override
  State<PremiumPlanScreen> createState() => _PremiumPlanScreenState();
}

class _PremiumPlanScreenState extends State<PremiumPlanScreen> {
  bool isYearlySelected = true;
  List<Package> packages = [];
  bool isLoading = true;
  bool isPurchasing = false;
  bool isRestoring = false;
  String? errorMessage;

  bool get _isApple => Platform.isIOS || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final offerings = await PurchaseApi.fetchOfferings();
      if (!mounted) return;
      setState(() {
        packages = offerings;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load plans. Please check your connection.';
      });
    }
  }

  Future<void> _handlePurchase(Package package) async {
    // Force sync backend UID before purchase to prevent anonymous purchase
    final profileController = Get.find<ProfileController>();
    if (profileController.user.value != null) {
      debugPrint(
        '[Purchase] Ensuring RevenueCat is logged in with backend ID: ${profileController.user.value!.id}',
      );
      await PurchaseApi.logIn(profileController.user.value!.id);
    } else {
      debugPrint(
        '[Purchase] WARNING: Profile user is null, might be purchasing anonymously',
      );
    }

    setState(() {
      isPurchasing = true;
      errorMessage = null;
    });

    final (success, error) = await PurchaseApi.purchasePackage(package);

    if (!mounted) return;
    setState(() => isPurchasing = false);

    if (success) {
      _showSuccessDialog();
    } else {
      setState(
        () => errorMessage =
            error ?? 'Purchase was cancelled or could not be completed.',
      );
      // If it's a silent cancellation (no error message but success=false),
      // it might be a simulator or non-configured product.
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment cancelled. Please use a real device with a Sandbox account.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    // Force sync backend UID before restore
    final profileController = Get.find<ProfileController>();
    if (profileController.user.value != null) {
      await PurchaseApi.logIn(profileController.user.value!.id);
    }

    setState(() {
      isRestoring = true;
      errorMessage = null;
    });

    final (success, error) = await PurchaseApi.restorePurchases();

    if (!mounted) return;
    setState(() => isRestoring = false);

    if (success && PurchaseApi.isUserPremium()) {
      _showSuccessDialog(isRestore: true);
    } else {
      setState(() {
        errorMessage = error ?? 'No active subscriptions found to restore.';
      });
    }
  }

  void _showSuccessDialog({bool isRestore = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text(
          '🎉 Welcome to Premium!',
          textAlign: TextAlign.center,
        ),
        content: Text(
          isRestore
              ? 'Your premium access has been restored successfully.'
              : 'You now have full access to all Qurany Premium features.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text(
              'Continue',
              style: TextStyle(color: Color(0xFF2E7D32)),
            ),
          ),
        ],
      ),
    );
  }

  Package? get _selectedPackage {
    if (packages.isEmpty) return null;
    if (isYearlySelected) {
      return packages.firstWhere(
        (p) => p.packageType == PackageType.annual,
        orElse: () => packages.first,
      );
    } else {
      return packages.firstWhere(
        (p) => p.packageType == PackageType.monthly,
        orElse: () => packages.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF2F7D33),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/Premiumbg.png'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // App Bar
                  _buildAppBar(),

                  SizedBox(height: 20.h),

                  // Crown Icon
                  Image.asset(
                    'assets/image/crown.png',
                    width: 120.w,
                    height: 120.h,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    "Qurany Premium",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Subtitle
                  Text(
                    "Unlock the complete Qurani+ experience",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Pricing Cards
                  _buildPricingSection(),

                  SizedBox(height: 24.h),

                  // Premium Features
                  _buildPremiumFeatures(),

                  SizedBox(height: 24.h),

                  // Error message if any
                  if (errorMessage != null) _buildErrorBanner(),

                  SizedBox(height: errorMessage != null ? 16.h : 0),

                  // CTA Button (Apple Pay / Google Pay / Subscribe)
                  _buildPaymentButton(),

                  SizedBox(height: 12.h),

                  // Auto-renew text
                  //_buildAutoRenewText(),
                  SizedBox(height: 12.h),

                  // Restore Purchases
                  //  _buildRestoreButton(),
                  SizedBox(height: 12.h),

                  // Links
                  _buildLinks(),

                  SizedBox(height: 16.h),

                  // Fine print
                  _buildFinePrint(),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18.sp,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              "Premium Plan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 36.w),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (packages.isEmpty) {
      return Column(
        children: [
          Text(
            "No plans available at the moment.",
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _fetchOfferings,
            child: Text(
              "Tap to retry",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: packages.map((package) {
          final isYearly = package.packageType == PackageType.annual;
          final isLast = packages.last == package;
          final isSelected = isYearly ? isYearlySelected : !isYearlySelected;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 16.w),
              child: _buildPricingCard(
                title: isYearly ? "Yearly" : "Monthly",
                price: package.storeProduct.priceString,
                period: isYearly ? '/year' : '/month',
                isSelected: isSelected,
                showBadge: isYearly,
                badgeText: isYearly ? "Save 40%" : null,
                onTap: () {
                  setState(() {
                    isYearlySelected = isYearly;
                  });
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required bool isSelected,
    required VoidCallback onTap,
    bool showBadge = false,
    String? badgeText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 145.h,
              borderRadius: 20.r,
              blur: 18,
              alignment: Alignment.center,
              border: 0,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(isSelected ? 0.20 : 0.10),
                  Colors.white.withOpacity(isSelected ? 0.10 : 0.05),
                ],
                stops: const [0.1, 1],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(height: 6.h),
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (showBadge && badgeText != null)
            Positioned(
              top: -12.h,
              right: -8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Premium Features",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          _buildFeatureImageItem(
            'assets/icons/Premium1.png',
            "Exclusive Design Themes",
            "Unlock beautiful premium themes and customize your experience",
          ),
          SizedBox(height: 16.h),
          _buildFeatureImageItem(
            'assets/icons/Premium2.png',
            "Unlimited AI Companion queries",
            "Get all the answers and insights you're looking for",
          ),
          SizedBox(height: 16.h),
          _buildFeatureImageItem(
            'assets/icons/Premium3.png',
            "Premium reciters library",
            "Explore a diverse collection of renowned reciters",
          ),
          SizedBox(height: 16.h),
          _buildFeatureImageItem(
            'assets/icons/Premium4.png',
            "Advanced memorization tracking",
            "Personalized learning strategies",
          ),
          SizedBox(height: 16.h),
          _buildFeatureImageItem(
            'assets/icons/Premium5.png',
            "Unlock all Qibla compass styles",
            "Find your direction with unique designs",
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureImageItem(
    String imagePath,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(6.w),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                errorMessage!,
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => errorMessage = null),
              child: Icon(Icons.close, color: Colors.white, size: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    final package = _selectedPackage;
    final isDisabled = package == null || isPurchasing || isLoading;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: isDisabled ? null : () => _handlePurchase(package),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.white.withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: isDisabled
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: isPurchasing
              ? Center(
                  child: SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Apple Pay / Google Pay logo
                    if (_isApple) ...[
                      Icon(Icons.apple, color: Colors.black, size: 22.sp),
                      SizedBox(width: 6.w),
                      Text(
                        "Pay",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ] else ...[
                      Image.asset(
                        'assets/icons/google_pay.png',
                        height: 22.h,
                        errorBuilder: (ctx, e, s) => Icon(
                          Icons.payment,
                          size: 22.sp,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Pay",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                    SizedBox(width: 8.w),
                    Container(width: 1.w, height: 18.h, color: Colors.black38),
                    SizedBox(width: 8.w),
                    Text(
                      package != null
                          ? "Get 7 days free • ${package.storeProduct.priceString}"
                          : "Get 7 days free trial",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAutoRenewText() {
    final priceString = _selectedPackage?.storeProduct.priceString ?? '\$29.99';
    final period = isYearlySelected ? '/year' : '/month';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 13.sp, color: Colors.white),
        children: [
          const TextSpan(text: "Auto-renews at "),
          TextSpan(
            text: "$priceString$period",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
          const TextSpan(text: " after trial.\nCancel anytime."),
        ],
      ),
    );
  }

  Widget _buildRestoreButton() {
    return GestureDetector(
      onTap: isRestoring ? null : _handleRestore,
      child: isRestoring
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              "Restore Purchases",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.9),
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
    );
  }

  Widget _buildLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            // Handle Terms of Service
          },
          child: Text(
            "Terms of Service",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
        Text(
          " • ",
          style: TextStyle(fontSize: 12.sp, color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            // Handle Privacy Policy
          },
          child: Text(
            "Privacy Policy",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinePrint() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(
        "Payment will be charged to your ${_isApple ? 'Apple ID' : 'Google Play'} account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage subscriptions in your ${_isApple ? 'App Store' : 'Google Play'} account settings.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.sp,
          color: Colors.white.withOpacity(0.8),
          height: 1.4,
        ),
      ),
    );
  }
}
