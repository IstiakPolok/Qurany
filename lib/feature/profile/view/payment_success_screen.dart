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
              image: AssetImage('assets/image/CustomizeExperienceBZ.jpg'),
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
                          color: Colors.white.withOpacity(0.0),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70),
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
                    fontFamily: 'Arial',
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

                SizedBox(height: 20.h),

                // Features Card
                _buildFeaturesCard(context),
                SizedBox(height: 10.h),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to home or main screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 6.h),
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
                ),
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
        'image': 'assets/icons/update1.png',
        'title': 'Exclusive Design Themes',
        'description':
            'Unlock beautiful premium themes and customize your experience',
      },
      {
        'image': 'assets/icons/update2.png',
        'title': 'Unlimited AI Companion queries',
        'description': "Get all the answers and insights you're looking for",
      },
      {
        'image': 'assets/icons/update3.png',
        'title': 'Premium reciters library',
        'description': 'Explore a diverse collection of renowned reciters',
      },
      {
        'image': 'assets/icons/update4.png',
        'title': 'Advanced memorization tracking',
        'description': 'Personalized learning strategies',
      },
      {
        'image': 'assets/icons/update5.png',
        'title': 'Unlock all Qibla compass styles',
        'description': 'Find your direction with unique designs',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.only(
        top: 10.h,
        bottom: 10.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF16641A), Color(0xFF2F7D33)],
        ),
        borderRadius: BorderRadius.all(Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            return Column(
              children: [
                _buildFeatureItem(
                  feature['image'] as String,
                  feature['title'] as String,
                  feature['description'] as String,
                ),
                if (index != features.length - 1)
                  Divider(
                    color: Colors.white.withOpacity(0.3),
                    thickness: 1,
                    height: 4.h,
                  ),
              ],
            );
          }),

          // Start Exploring Button
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String imagePath, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(8.w),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),

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

        Container(
          width: 16.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 14.sp, color: Color(0xFF2E7D32)),
        ),
      ],
    );
  }
}
