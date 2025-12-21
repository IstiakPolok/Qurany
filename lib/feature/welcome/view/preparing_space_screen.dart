import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/feature/bottom_nav_bar/screen/bottom_nav_bar.dart';

import '../../../core/const/gradiant_loader.dart';

class PreparingSpaceScreen extends StatefulWidget {
  const PreparingSpaceScreen({super.key});

  @override
  State<PreparingSpaceScreen> createState() => _PreparingSpaceScreenState();
}

class _PreparingSpaceScreenState extends State<PreparingSpaceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Navigate to BottomNavbar after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNavbar()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/image/login_OptionBG.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Verse Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 32.h,
                      horizontal: 20.w,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF17651B),
                          Color(0xFF216F25),
                          Color(0xFF2D7B31),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/123.png',
                              width: 36.w,
                              height: 36.h,
                              color: Colors.white,
                            ),

                            Text(
                              "إِنَّمَا يُوَفَّى الصَّابِرُونَ أَجْرَهُم بِغَيْرِ حِسَابٍ",
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.amiri(
                                fontSize: 20.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "“Indeed, the patient will be given their reward\nwithout account.”",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Surah Az-Zumar-10",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50.h),

                  Center(
                    child: GradientLoader(
                      size: 80,
                      strokeWidth: 20,
                      colors: [Colors.white, primaryColor],
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Loading Text
                  Text(
                    "Preparing your space,",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "May it lead you to goodness.",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
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
