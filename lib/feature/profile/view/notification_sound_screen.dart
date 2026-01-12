import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationSoundScreen extends StatefulWidget {
  const NotificationSoundScreen({super.key});

  @override
  State<NotificationSoundScreen> createState() =>
      _NotificationSoundScreenState();
}

class _NotificationSoundScreenState extends State<NotificationSoundScreen> {
  String selectedAlert = 'silent';
  String selectedAdhan = 'madinah';
  String playingAdhan =
      ''; // Track which adhan is "playing" (showing pause icon)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Alerts",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildAlertCard(
                      id: 'silent',
                      icon: Icons.notifications_off_outlined,
                      title: "Silent",
                    ),
                    _buildAlertCard(
                      id: 'default',
                      icon: Icons.notifications_outlined,
                      title: "Default Notification Sound",
                    ),
                    _buildAlertCard(
                      id: 'long_beep',
                      icon: Icons.notifications_active_outlined,
                      title: "Long Beep",
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      "Choose the Adhan Sound",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildAdhanCard(id: 'without', title: "Without sound"),
                    _buildAdhanCard(
                      id: 'madinah',
                      title: "Adhan(Madinah)",
                      subtitle: "Mishary Rashid Alafasy",
                      showPlayButton: true,
                    ),
                    _buildAdhanCard(
                      id: 'makkah',
                      title: "Adhan(Makkah)",
                      subtitle: "Abdul Basit Abdul Samad",
                      showPlayButton: true,
                      isInitiallyPlaying: true,
                    ),
                    _buildAdhanCard(
                      id: 'indonesia1',
                      title: "Adhan(Indonesia)",
                      subtitle: "Ahmed Al Ajmy",
                      showPlayButton: true,
                    ),
                    _buildAdhanCard(
                      id: 'indonesia2',
                      title: "Adhan(Indonesia)",
                      subtitle: "Ahmed Al Ajmy",
                      showPlayButton: true,
                    ),
                    _buildAdhanCard(
                      id: 'makkah2',
                      title: "Adhan(Makkah)",
                      subtitle: "Abdul Rehman Sudais",
                      showPlayButton: true,
                    ),
                    SizedBox(height: 20.h),
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
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
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
          ),
          Text(
            "Notification Sound",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F2630),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String id,
    required IconData icon,
    required String title,
  }) {
    bool isSelected = selectedAlert == id;
    return GestureDetector(
      onTap: () => setState(() => selectedAlert = id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: Colors.black87),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildSelectionIndicator(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildAdhanCard({
    required String id,
    required String title,
    String? subtitle,
    bool showPlayButton = false,
    bool isInitiallyPlaying = false,
  }) {
    bool isSelected = selectedAdhan == id;
    bool isPlaying =
        playingAdhan == id || (isInitiallyPlaying && playingAdhan == '');

    return GestureDetector(
      onTap: () => setState(() => selectedAdhan = id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (showPlayButton) ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (playingAdhan == id) {
                      playingAdhan = 'stopped';
                    } else {
                      playingAdhan = id;
                    }
                  });
                },
                child: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_arrow_rounded,
                  size: 32.sp,
                  color: isPlaying ? const Color(0xFF2E7D32) : Colors.black87,
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            _buildSelectionIndicator(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[400]!,
          width: 1.5,
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
    );
  }
}
