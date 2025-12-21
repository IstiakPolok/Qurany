import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/core/const/app_colors.dart';

import '../../preferences/views/preferences_flow_screen.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              // Top Bar with Close Icon
              Align(
                alignment: Alignment.centerRight,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  radius: 20.r,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 20.sp),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Title
              Text(
                "Stay on time with Adhan reminders.",
                textAlign: TextAlign.center,
                style: GoogleFonts.abhayaLibre(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),

              const Spacer(flex: 1),

              Image.asset(
                'assets/image/notiPermission.png',
                fit: BoxFit.contain,
              ),

              const Spacer(flex: 1),

              // Description
              Text(
                "You'll also get gentle reminders to read Quran, track\nyour prayers, and stay connected to your faith",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 24.h),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => PreferencesFlowScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF9F0), // Off-white/Cream
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Enable notification",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () {
                    Get.to(() => PreferencesFlowScreen());
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "May be later",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Privacy Note
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your privacy is important to us. We only use\nthese permissions to enhance your experience.",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
