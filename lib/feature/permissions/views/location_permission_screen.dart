import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/feature/permissions/views/notification_permission_screen.dart';
import 'package:qurany/core/global_widgets/outlined_close_button.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

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
            final hPad = (width * 0.06).clamp(12.0, 32.0);
            final vPad = (height * 0.02).clamp(12.0, 28.0);
            final imageHeight = (height * 0.28).clamp(120.0, 320.0);
            final buttonHeight = (height * 0.07).clamp(48.0, 64.0);

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Bar with Close Icon
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedCloseButton(
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  SizedBox(height: vPad * 0.4),

                  // Title
                  Text(
                    "Enhance your prayer experience with precise location",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.abhayaLibre(
                      color: Colors.white,
                      fontSize: ((width * 0.06).clamp(18.0, 28.0)).sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),

                  SizedBox(height: vPad * 0.8),

                  Image.asset(
                    'assets/image/locationacessimage.png', // Update with your image path
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: vPad * 0.8),

                  // Description
                  Text(
                    "We need your location to show accurate prayer xtimes and help you stay connected to your faith.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ((width * 0.037).clamp(12.0, 16.0)).sp,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: vPad),

                  // Buttons
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.to(() => NotificationPermissionScreen());
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
                            "Allow Location Access",
                            style: TextStyle(
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
                            Get.to(NotificationPermissionScreen());
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
                    ],
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
                              color: Colors.white.withOpacity(0.8),
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
