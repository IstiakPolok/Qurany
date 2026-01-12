import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mq = MediaQuery.of(context);
            final width = mq.size.width;
            final height = mq.size.height;
            final hPad = (width * 0.06).clamp(12.0, 28.0);
            final vPad = (height * 0.02).clamp(12.0, 28.0);
            final imageHeight = (height * 0.30).clamp(140.0, 340.0);
            final buttonHeight = (height * 0.07).clamp(48.0, 64.0);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Bar with Close Icon
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: (width * 0.05).clamp(18.0, 28.0) * 2,
                      height: (width * 0.05).clamp(18.0, 28.0) * 2,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white70),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: (width * 0.05).clamp(16.0, 22.0),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  SizedBox(height: vPad * 0.6),

                  // Title
                  Text(
                    "Stay on time with Adhan reminders.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.abhayaLibre(
                      color: Colors.white,
                      fontSize: ((width * 0.055).clamp(18.0, 26.0)).sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: vPad * 0.8),

                  Image.asset(
                    'assets/image/notiPermission.png',
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: vPad * 0.8),

                  // Description
                  Text(
                    "You'll also get gentle reminders to read Quran, track your prayers, and stay connected to your faith",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ((width * 0.035).clamp(12.0, 16.0)).sp,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: vPad),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => PreferencesFlowScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFFFF9F0,
                        ), // Off-white/Cream
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            (buttonHeight * 0.5).clamp(20.0, 40.0),
                          ),
                        ),
                      ),
                      child: Text(
                        "Enable notification",
                        style: TextStyle(
                          color: black,
                          fontSize: ((width * 0.045).clamp(14.0, 18.0)).sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: vPad * 0.5),

                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(() => PreferencesFlowScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            (buttonHeight * 0.5).clamp(20.0, 40.0),
                          ),
                        ),
                      ),
                      child: Text(
                        "May be later",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ((width * 0.045).clamp(14.0, 18.0)).sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: vPad),

                  // Privacy Note
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: (width * 0.03).clamp(8.0, 16.0),
                      vertical: (vPad * 0.3).clamp(6.0, 12.0),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white70,
                          size: ((width * 0.035).clamp(14.0, 18.0)),
                        ),
                        SizedBox(width: (width * 0.02).clamp(6.0, 12.0)),
                        Expanded(
                          child: Text(
                            "Your privacy is important to us. We only use these permissions to enhance your experience.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ((width * 0.032).clamp(11.0, 13.0)).sp,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: vPad * 0.4),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
