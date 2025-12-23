import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'payment_checkout_screen.dart';

class PremiumPlanScreen extends StatefulWidget {
  const PremiumPlanScreen({super.key});

  @override
  State<PremiumPlanScreen> createState() => _PremiumPlanScreenState();
}

class _PremiumPlanScreenState extends State<PremiumPlanScreen> {
  bool isYearlySelected = true;

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
              image: AssetImage('assets/image/login_OptionBG.png'),
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
                    width: 80.w,
                    height: 80.h,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        size: 50.sp,
                        color: Colors.white,
                      ),
                    ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          // Monthly Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isYearlySelected = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentCheckoutScreen(
                      planType: 'Monthly',
                      price: '\$4.99',
                    ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                decoration: BoxDecoration(
                  color: isYearlySelected
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16.r),
                  border: !isYearlySelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      "Monthly",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "\$4.99",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Yearly Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isYearlySelected = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentCheckoutScreen(
                      planType: 'Yearly',
                      price: '\$29.99',
                      savingsText: 'Save 40%',
                    ),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    decoration: BoxDecoration(
                      color: isYearlySelected
                          ? Colors.white.withOpacity(0.25)
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16.r),
                      border: isYearlySelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Yearly",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "\$29.99",
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save badge
                  Positioned(
                    top: -12.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "Save 40%",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),
                ],
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
          _buildFeatureItem(
            Icons.palette_outlined,
            "Exclusive Design Themes",
            "Unlock beautiful premium themes and customize your experience",
            const Color(0xFF4CAF50),
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            Icons.star,
            "Unlimited AI Companion queries",
            "Get all the answers and insights you're looking for",
            const Color(0xFFFFB300),
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            Icons.headphones,
            "Premium reciters library",
            "Explore a diverse collection of renowned reciters",
            const Color(0xFF4CAF50),
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            Icons.auto_graph,
            "Advanced memorization tracking",
            "Personalized learning strategies",
            const Color(0xFF4CAF50),
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            Icons.explore_outlined,
            "Unlock all Qibla compass styles",
            "Find your direction with unique designs",
            const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Color iconBgColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: iconBgColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 22.sp, color: iconBgColor),
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
          // Handle trial subscription
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
