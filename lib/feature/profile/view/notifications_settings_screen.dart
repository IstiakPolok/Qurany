import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'adhan_notifications_screen.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool islamicCalendarEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            SizedBox(height: 24.h),

            // Settings Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    // Adhan Notifications
                    _buildSettingsItem(
                      "Adhan Notifications",
                      hasArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdhanNotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),

                    // Dhikr Reminder
                    _buildSettingsItem(
                      "Dhikr Reminder",
                      hasArrow: true,
                      onTap: () => _showDhikrReminderDialog(context),
                    ),
                    _buildDivider(),

                    // Ayah of the day
                    _buildSettingsItem(
                      "Ayah of the day",
                      hasArrow: true,
                      onTap: () {},
                    ),
                    _buildDivider(),

                    // Islamic Calendar
                    _buildToggleItem(
                      "Islamic Calender",
                      islamicCalendarEnabled,
                      (value) {
                        setState(() {
                          islamicCalendarEnabled = value;
                        });
                      },
                    ),
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
                "Push Notifications",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 40.w), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title, {
    bool hasArrow = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
            if (hasArrow)
              Icon(Icons.chevron_right, size: 22.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E7D32),
            activeTrackColor: const Color(0xFFE8F5E9),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  void _showDhikrReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // Bell icon
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 28.sp,
                  color: const Color(0xFF2E7D32),
                ),
              ),

              SizedBox(height: 16.h),

              // Title
              Text(
                "Dhikr Reminder",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8.h),

              // Subtitle
              Text(
                "Set you daily Dhikr reminders",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),

              SizedBox(height: 20.h),

              // Select Time field
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    // Handle time selection
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Time",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      Icon(
                        Icons.access_time,
                        size: 20.sp,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
