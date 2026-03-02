import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../core/services/purchase_api.dart';

class PremiumPlanScreen extends StatefulWidget {
  const PremiumPlanScreen({super.key});

  @override
  State<PremiumPlanScreen> createState() => _PremiumPlanScreenState();
}

class _PremiumPlanScreenState extends State<PremiumPlanScreen> {
  bool isYearlySelected = true;
  List<Package> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOfferings();
  }

  Future<void> _fetchOfferings() async {
    try {
      final offerings = await PurchaseApi.fetchOfferings();
      if (offerings.isNotEmpty) {
        setState(() {
          packages = offerings.first.availablePackages;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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

                  // CTA Button
                  _buildTrialButton(),

                  SizedBox(height: 16.h),

                  // Auto-renew text
                  _buildAutoRenewText(),

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
      return Center(
        child: Text(
          "No plans available at the moment.",
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: packages.map((package) {
          final isYearly = package.packageType == PackageType.annual;
          final isMonthly = package.packageType == PackageType.monthly;

          // Use index to add spacing between cards
          final isLast = packages.last == package;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 16.w),
              child: _buildPricingCard(
                title: package.storeProduct.title.split('(')[0].trim(),
                price: package.storeProduct.priceString,
                isSelected: isYearly ? isYearlySelected : !isYearlySelected,
                showBadge: isYearly,
                badgeText: isYearly ? "Save 40%" : null,
                onTap: () {
                  setState(() {
                    isYearlySelected = isYearly;
                  });
                  _handlePurchase(package);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handlePurchase(Package package) async {
    final success = await PurchaseApi.purchasePackage(package);
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Purchase Successful!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Purchase Failed or Cancelled")),
      );
    }
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
    bool showBadge = false,
    String? badgeText,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GlassmorphicContainer(
              width: double.infinity,
              height: 135.h,
              borderRadius: 20.r,
              blur: 18,
              alignment: Alignment.center,
              border: 0,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.05),
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
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showBadge && badgeText != null)
              Positioned(
                top: -12.h,
                right: -8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
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

  Widget _buildTrialButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () {
          if (packages.isNotEmpty) {
            final package = packages.firstWhere(
              (p) => p.packageType == PackageType.annual,
              orElse: () => packages.first,
            );
            _handlePurchase(package);
          }
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Center(
            child: Text(
              "Get 7 days free trial",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoRenewText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 13.sp, color: Colors.white),
        children: [
          const TextSpan(text: "Auto-renews at "),
          TextSpan(
            text: "\$29.99/year",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
          ),
          const TextSpan(text: " after trial.\nCancel anytime."),
        ],
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
        "Payment will be charged to your account at confirmation of purchase. Subscription automatically renews unless cancelled at least 24 hours before the end of the current period.",
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
