import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qurany/feature/profile/view/profile_screen.dart';

import 'dayProgressWidgets.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/image/homeCover1.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            alignment: Alignment.topCenter,
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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
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
                  ),
                ],
              ),
            ),
          ),

          // Circular Helper / Streak
          Positioned(
            bottom: 0.h,
            left: 0,
            right: 0,
            child: Center(
              child: Center(
                child: DayProgressWidget(
                  currentDay: 1,
                  totalDays: 5, // Based on the 5 segments in the image
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
