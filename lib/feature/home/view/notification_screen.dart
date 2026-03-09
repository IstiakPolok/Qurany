import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/home/view/verse_of_day_screen.dart';
import '../controller/verse_of_day_controller.dart';
import '../../prayer/controller/prayer_controller.dart';

class NotificationModel {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  NotificationModel({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFFF0F5ED),
    this.onTap,
  });
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VerseOfDayController verseController =
        Get.find<VerseOfDayController>();
    final PrayerController prayerController =
        Get.isRegistered<PrayerController>()
        ? Get.find<PrayerController>()
        : Get.put(PrayerController());

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.w),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.black),
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<String?>(
        future: SharedPreferencesHelper.getDailyPracticeReminderTime(),
        builder: (context, snapshot) {
          final reminderTime = snapshot.data;

          return Obx(() {
            final List<NotificationModel> dynamicNotifications = [];

            if (reminderTime != null && reminderTime.trim().isNotEmpty) {
              dynamicNotifications.add(
                NotificationModel(
                  title: 'Daily Practice Reminder',
                  subtitle:
                      'Your memorization reminder is set for $reminderTime.',
                  date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                  icon: Icons.notifications_active,
                ),
              );
            }

            // 1. Add Verse of the Day if available
            if (verseController.randomVerse.value != null) {
              final verse = verseController.randomVerse.value!.data.verse;
              dynamicNotifications.add(
                NotificationModel(
                  title: 'Verse of the Day',
                  subtitle:
                      '"${verse.ayate}" [${verse.transliteration} ${verse.verseId}]',
                  date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                  icon: Icons.menu_book,
                  onTap: () => Get.to(() => const VerseOfDayScreen()),
                ),
              );
            }

            // 2. Add Prayer Reminders from data
            if (prayerController.prayerData.value != null) {
              final times = prayerController.prayerData.value!.times;
              final String nextPrayer = prayerController.getNextPrayerName();
              final String? nextTime = times[nextPrayer];

              if (nextTime != null) {
                dynamicNotifications.add(
                  NotificationModel(
                    title: 'Reminder: $nextPrayer Prayer',
                    subtitle:
                        "The $nextPrayer prayer is at $nextTime. Don't forget your dhikr.",
                    date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                    icon: Icons.access_time,
                  ),
                );
              }
            }

            // Fallback or additional static notifications
            if (dynamicNotifications.isEmpty) {
              dynamicNotifications.add(
                NotificationModel(
                  title: 'Welcome to Qurany',
                  subtitle:
                      'Stay connected with your daily prayers and Quran reading.',
                  date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                  icon: Icons.notifications_active,
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  _buildSectionHeader('Today', onMarkAllAsRead: () {}),
                  ...dynamicNotifications.map((n) => _buildNotificationTile(n)),
                  SizedBox(height: 10.h),
                  const Divider(),
                  SizedBox(height: 20.h),
                  _buildSectionHeader('Yesterday'),
                  // Sample static notification for "Yesterday"
                  _buildNotificationTile(
                    NotificationModel(
                      title: 'Al-Kahf Reminder',
                      subtitle:
                          'Friday is here, don\'t forget to read Surah Al-Kahf.',
                      date: 'Last Friday',
                      icon: Icons.auto_stories,
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onMarkAllAsRead}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (onMarkAllAsRead != null)
            GestureDetector(
              onTap: onMarkAllAsRead,
              child: Text(
                'Mark all as read',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF2E7D32),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: notification.onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/Polygon2.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Center(child: _buildNotificationIcon(notification)),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.date,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    notification.subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notification) {
    if (notification.title.toLowerCase().contains('subscription')) {
      return Image.asset(
        'assets/image/crown.png',
        width: 30.w,
        height: 30.w,
        fit: BoxFit.contain,
      );
    } else if (notification.title.toLowerCase().contains('prayer')) {
      return Image.asset(
        'assets/icons/navprayerIcons.png',
        width: 24.w,
        height: 24.w,
        color: const Color(0xFF2F7D33),
        fit: BoxFit.contain,
      );
    } else if (notification.title.toLowerCase().contains('verse')) {
      return Image.asset(
        'assets/icons/navquranIcons.png',
        width: 24.w,
        height: 24.w,
        color: const Color(0xFF2F7D33),
        fit: BoxFit.contain,
      );
    }
    return Icon(notification.icon, color: const Color(0xFF2F7D33), size: 24.sp);
  }
}
