import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Top Bar with Close Icon
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedCloseButton(
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Title
              Text(
                "Enhance your prayer experience\nwith precise location",
                textAlign: TextAlign.center,
                style: GoogleFonts.abhayaLibre(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),

              Image.asset(
                'assets/image/locationacessimage.png', // Update with your image path
                fit: BoxFit.contain,
              ),

              // Description
              const Text(
                "We need your location to show accurate prayer\ntimes and help you stay connected to your faith.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
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
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Allow Location Access",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.to(NotificationPermissionScreen());
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "May be later",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
