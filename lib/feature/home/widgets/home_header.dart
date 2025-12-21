import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/core/const/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380.h,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/image/login_OptionBG.png', // Using existing BG as placeholder/base
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    const Color(0xFFFFF9F0), // Match app background at bottom
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ),

          // Top Bar (Icons)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Notification Icon
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 24.sp,
                          color: Colors.black87,
                        ),
                      ),
                      Positioned(
                        right: 8.w,
                        top: 8.w,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Profile Icon
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 24.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Circular Helper / Streak
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120.w,
                    height: 120.w,
                    child: CircularProgressIndicator(
                      value: 0.25, // 1/4 days
                      strokeWidth: 8,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  SizedBox(
                    width: 110.w,
                    height: 110.w,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade300,
                      ),
                    ),
                  ),
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "1",
                          style: GoogleFonts.poppins(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "Day",
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
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
}
