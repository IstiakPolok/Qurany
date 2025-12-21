import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/core/const/app_colors.dart';

import 'package:get/get.dart';
import 'package:qurany/feature/welcome/view/preparing_space_screen.dart';

class LoginOptionsScreen extends StatelessWidget {
  const LoginOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Top-aligned full-width background image
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
                children: [
                  Spacer(flex: 4),

                  // Arabic Greeting
                  Text(
                    "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      // Assuming Amiri font is available/preferred for Arabic
                      fontSize: 24.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Welcome Title
                  Text(
                    "Welcome to Qurany",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.abhayaLibre(
                      fontSize: 32.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Subtitle
                  Text(
                    "Create an account to sync your bookmarks,\nprogress, and khatams across devices.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),

                  Spacer(flex: 2),

                  // Google Button
                  _buildSocialButton(
                    onPressed: () {
                      Get.to(() => const PreparingSpaceScreen());
                    },
                    icon: Image.asset(
                      'assets/icons/googleIcon.png',
                      width: 28.sp,
                      height: 28.sp,
                    ),
                    label: "Continue with Google",
                  ),

                  SizedBox(height: 16.h),

                  // Apple Button
                  _buildSocialButton(
                    onPressed: () {
                      Get.to(() => const PreparingSpaceScreen());
                    },
                    icon: Icon(Icons.apple, color: Colors.black, size: 28.sp),
                    label: "Continue with Apple",
                  ),

                  SizedBox(height: 24.h),

                  // "or" Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Guest Button
                  OutlinedButton(
                    onPressed: () {
                      Get.to(() => const PreparingSpaceScreen());
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          "Continue as a guest",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(flex: 1),

                  // Footer Text
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Column(
                      children: [
                        Text(
                          "By clicking \"Continue\" you agree to Qurany",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Term of Use",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              " and ",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Privacy Policy",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required Widget icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF9F0), // Cream/White
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
