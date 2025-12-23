import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF2E7D32),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/login_OptionBG.png'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: GestureDetector(
                      onTap: () {
                        // Pop all payment screens and go back to profile
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Crown Icon
                Image.asset(
                  'assets/image/crown.png',
                  width: 80.w,
                  height: 80.h,
                  errorBuilder: (context, error, stackTrace) =>
                      Text("👑", style: TextStyle(fontSize: 60.sp)),
                ),

                SizedBox(height: 12.h),

                // Arabic text
                Text(
                  "ٱلْحَمْدُ لِلَّٰهِ",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Arabic',
                  ),
                ),

                SizedBox(height: 12.h),

                // Success Title
                Text(
                  "Your Upgrade Was Successful",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 8.h),

                // Subtitle
                Text(
                  "Enjoy your Premium Qurany experience",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                SizedBox(height: 24.h),

                // Features Card
                Expanded(child: _buildFeaturesCard(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    final features = [
      {
        'icon': Icons.palette_outlined,
        'title': 'Exclusive Design Themes',
        'description':
            'Unlock beautiful premium themes and customize your experience',
      },
      {
        'icon': Icons.star,
        'title': 'Unlimited AI Companion queries',
        'description': "Get all the answers and insights you're looking for",
      },
      {
        'icon': Icons.headphones,
        'title': 'Premium reciters library',
        'description': 'Explore a diverse collection of renowned reciters',
      },
      {
        'icon': Icons.auto_graph,
        'title': 'Advanced memorization tracking',
        'description': 'Personalized learning strategies',
      },
      {
        'icon': Icons.explore_outlined,
        'title': 'Unlock all Qibla compass styles',
        'description': 'Find your direction with unique designs',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.only(
        top: 20.h,
        bottom: 24.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF3D8B40),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: features.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final feature = features[index];
                return _buildFeatureItem(
                  feature['icon'] as IconData,
                  feature['title'] as String,
                  feature['description'] as String,
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          // Start Exploring Button
          GestureDetector(
            onTap: () {
              // Navigate to home or main screen
              Navigator.of(context).popUntil((route) => route.isFirst);
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
                  "Start Exploring",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 22.sp, color: Colors.white),
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
                  color: Colors.white.withOpacity(0.8),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 14.sp, color: Colors.white),
        ),
      ],
    );
  }
}
