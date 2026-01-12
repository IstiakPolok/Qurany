import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/feature/compass/views/qibla_compass_screen.dart';
import 'package:qurany/feature/home/view/home_screen.dart';
import 'package:qurany/feature/prayer/view/prayer_screen.dart';
import 'package:qurany/feature/ask_ai/view/ask_ai_intro_screen.dart';
import 'package:qurany/feature/quran/view/quran_screen.dart';

class BottomNavbarController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

class BottomNavbar extends StatelessWidget {
  final int initialIndex;
  const BottomNavbar({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    final BottomNavbarController controller = Get.put(BottomNavbarController());
    // Set initial index if provided
    if (controller.currentIndex.value != initialIndex) {
      controller.currentIndex.value = initialIndex;
    }

    // Placeholder pages
    final List<Widget> pages = [
      const HomeScreen(),
      const QuranScreen(),
      const AskAIScreen(),
      const PrayerScreen(),
      const QiblaCompassScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => pages[controller.currentIndex.value]),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          top: 10.h,
          bottom: 20.h,
          left: 16.w,
          right: 16.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                controller: controller,
                index: 0,
                iconPath: 'assets/icons/navhomeIcon.png',
                label: "Home",
              ),
              _buildNavItem(
                context,
                controller: controller,
                index: 1,
                iconPath: 'assets/icons/navquranIcons.png',
                label: "Quran",
              ),
              // Ask Button (Special)
              _buildAskButton(controller, 2),

              _buildNavItem(
                context,
                controller: controller,
                index: 3,
                iconPath: 'assets/icons/navprayerIcons.png',
                label: "Prayer",
              ),
              _buildNavItem(
                context,
                controller: controller,
                index: 4,
                iconPath: 'assets/icons/navqiblaIcons.png',
                label: "Qibla",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required BottomNavbarController controller,
    required int index,
    required String iconPath,
    required String label,
  }) {
    final bool isSelected = controller.currentIndex.value == index;
    final Color color = isSelected ? primaryColor : Colors.grey;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 28.sp, height: 28.sp, color: color),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAskButton(BottomNavbarController controller, int index) {
    final bool isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/icons/navaskIcon.png',
              width: 24.sp,
              height: 24.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "Ask",
            style: TextStyle(
              color: Colors
                  .grey, // Label is grey even if active? Or green? Design shows label 'Ask' below.
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
