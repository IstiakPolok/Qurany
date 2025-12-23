import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdhanNotificationsScreen extends StatefulWidget {
  const AdhanNotificationsScreen({super.key});

  @override
  State<AdhanNotificationsScreen> createState() =>
      _AdhanNotificationsScreenState();
}

class _AdhanNotificationsScreenState extends State<AdhanNotificationsScreen> {
  String selectedAlert = 'silent'; // silent, default, long_beep
  String selectedAdhanSound =
      'madinah'; // without, madinah, makkah, indonesia, etc.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            _buildAppBar(context),

            SizedBox(height: 16.h),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Alerts Section
                    Text(
                      "Alerts",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildAlertOption(
                      Icons.notifications_off_outlined,
                      "Silent",
                      'silent',
                      isFirst: true,
                    ),
                    _buildAlertOption(
                      Icons.notifications_outlined,
                      "Default Notification Sound",
                      'default',
                    ),
                    _buildAlertOption(
                      Icons.notifications_active_outlined,
                      "Long Beep",
                      'long_beep',
                      isLast: true,
                    ),

                    SizedBox(height: 24.h),

                    // Choose Adhan Sound Section
                    Text(
                      "Choose the Adhan Sound",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Without sound
                    _buildAdhanSoundOption("Without sound", null, 'without'),

                    SizedBox(height: 8.h),

                    // Adhan options
                    _buildAdhanSoundOption(
                      "Adhan(Madinah)",
                      "Mishary Rashid Alafasy",
                      'madinah',
                    ),
                    SizedBox(height: 8.h),
                    _buildAdhanSoundOption(
                      "Adhan(Makkah)",
                      "Abdul Basit Abdul Samad",
                      'makkah',
                      isPaused: true,
                    ),
                    SizedBox(height: 8.h),
                    _buildAdhanSoundOption(
                      "Adhan(Indonesia)",
                      "Ahmed Al Ajmy",
                      'indonesia1',
                    ),
                    SizedBox(height: 8.h),
                    _buildAdhanSoundOption(
                      "Adhan(Indonesia)",
                      "Ahmed Al Ajmy",
                      'indonesia2',
                    ),
                    SizedBox(height: 8.h),
                    _buildAdhanSoundOption(
                      "Adhan(Makkah)",
                      "Abdul Rehman Sudais",
                      'makkah2',
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Adhan Notifications",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 40.w), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildAlertOption(
    IconData icon,
    String title,
    String value, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = selectedAlert == value;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[200]!,
          width: isSelected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? Radius.circular(12.r) : Radius.zero,
          bottom: isLast ? Radius.circular(12.r) : Radius.zero,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedAlert = value;
          });
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Icon(icon, size: 22.sp, color: Colors.grey[600]),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E7D32)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdhanSoundOption(
    String title,
    String? subtitle,
    String value, {
    bool isPaused = false,
  }) {
    final isSelected = selectedAdhanSound == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAdhanSound = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            // Play/Pause button
            if (subtitle != null) ...[
              Icon(
                isPaused ? Icons.pause : Icons.play_arrow,
                size: 24.sp,
                color: Colors.grey[700],
              ),
              SizedBox(width: 12.w),
            ],
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Selection indicator
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
