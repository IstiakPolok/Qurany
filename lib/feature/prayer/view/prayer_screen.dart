import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qurany/feature/prayer/view/electronic_tasbih_screen.dart';
import 'package:qurany/feature/compass/views/qibla_compass_screen.dart';
import 'package:qurany/feature/profile/view/prayer_notification_setting_sheet.dart';
import '../../../core/services/location_service.dart';
import '../controller/prayer_controller.dart';
import 'islamic_calendar_screen.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PrayerController controller = Get.put(PrayerController());
    final LocationService locationService = Get.find<LocationService>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: Obx(() {
        // Show loading indicator while location or prayer data is loading
        if ((controller.isLoading.value &&
                controller.prayerData.value == null) ||
            locationService.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error state if there's an error
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[600]),
                SizedBox(height: 16.h),
                Text(
                  'Prayer Times Unavailable',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    controller.error.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () => controller.refreshPrayerTimes(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Top Section (Background, Header, Timeline)
              _buildTopSection(context, controller, locationService),

              // Action Cards
              _buildActionCards(context),

              // Today's Prayer Times
              _buildPrayerTimesSection(context, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    PrayerController controller,
    LocationService locationService,
  ) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topSectionHeight = (screenHeight * 0.52).clamp(380.0, 500.0);

    return Container(
      height: topSectionHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/prayerBG.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: MediaQuery.of(context).padding.top + 10.h,
              bottom: 4.h,
            ),
            child: Column(
              children: [
                // Location Header
                _buildLocationHeader(locationService),

                SizedBox(height: 16.h),

                // Date Navigation
                _buildDateNavigation(context, controller),

                SizedBox(height: 16.h),

                // Time
                FittedBox(
                  child: Text(
                    DateFormat('HH:mm').format(controller.currentTime.value),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 56.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Countdown Badge
                _buildCountdownBadge(controller),

                const Spacer(),

                // Timeline Row
                _buildTimeline(controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader(LocationService locationService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () => locationService.refreshLocation(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => locationService.isLoading.value
                        ? SizedBox(
                            width: 16.sp,
                            height: 16.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Obx(
                      () => Text(
                        locationService.currentLocation.value,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Stack(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 28.sp,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "2",
                  style: TextStyle(color: Colors.white, fontSize: 8.sp),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateNavigation(
    BuildContext context,
    PrayerController controller,
  ) {
    return Obx(() {
      final date = controller.selectedDate.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => controller.previousDay(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white70,
              size: 14.sp,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IslamicCalendarScreen(),
                ),
              );
            },
            child: Column(
              children: [
                Text(
                  DateFormat('EEEE, d MMMM').format(date),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  controller.getFormattedHijriDate(),
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          IconButton(
            onPressed: () => controller.nextDay(),
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 14.sp,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCountdownBadge(PrayerController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              "${controller.getNextPrayerName()} will begin in",
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              controller.getTimeRemaining(),
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(PrayerController controller) {
    if (controller.prayerData.value == null) return const SizedBox();

    final times = controller.prayerData.value!.times;
    final timelineItems = [
      {
        'name': 'Fajr',
        'time': times['Fajr'] ?? '00:00',
        'icon': Icons.wb_twilight,
      },
      {
        'name': 'Sunrise',
        'time': times['Sunrise'] ?? '00:00',
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'name': 'Dhuhr',
        'time': times['Dhuhr'] ?? '00:00',
        'icon': Icons.wb_sunny,
      },
      {
        'name': 'Asr',
        'time': times['Asr'] ?? '00:00',
        'icon': Icons.cloud_outlined,
      },
      {
        'name': 'Maghrib',
        'time': times['Maghrib'] ?? '00:00',
        'icon': Icons.wb_twilight,
      },
      {
        'name': 'Isha',
        'time': times['Isha'] ?? '00:00',
        'icon': Icons.nights_stay_outlined,
      },
    ];

    final nextPrayer = controller.getNextPrayerName();

    return SizedBox(
      height: 110.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(timelineItems.length, (index) {
          final item = timelineItems[index];
          bool isSelected = item['name'] == nextPrayer;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 8.w,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4E4B45)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        color: isSelected ? Colors.white : Colors.white70,
                        size: 16.sp,
                      ),
                      SizedBox(height: 6.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item['name'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: isSelected ? 11.sp : 9.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item['time'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: isSelected ? 10.sp : 8.sp,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Transform.translate(
                    offset: Offset(0, -6.h),
                    child: CustomPaint(
                      size: Size(16.w, 10.h),
                      painter: TrianglePainter(),
                    ),
                  )
                else
                  SizedBox(height: 10.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QiblaCompassScreen(),
                  ),
                );
              },
              child: _buildActionCard(
                imagePath: "assets/icons/qibladirctioninprayerIcons.png",
                title: "Locate",
                subtitle: "Qibla",
                color: const Color(0xFFE2E9D8),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          _buildPrayerProgressCard(),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ElectronicTasbihScreen(),
                  ),
                );
              },
              child: _buildActionCard(
                imagePath: "assets/icons/electrictasbihinpracyericon.png",
                title: "Electronic",
                subtitle: "Tasbih",
                color: const Color(0xFFE2E9D8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerProgressCard() {
    return Expanded(
      child: Container(
        height: 115.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E9D8),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: GetBuilder<PrayerController>(
          builder: (controller) {
            // Count how many prayers have passed today
            final passedPrayers = [
              'Fajr',
              'Dhuhr',
              'Asr',
              'Maghrib',
              'Isha',
            ].where((prayer) => controller.isPrayerPassed(prayer)).length;

            final progress = passedPrayers / 5.0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70.w,
                      height: 70.w,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white,
                        color: const Color(0xFF2E7D32),
                        strokeWidth: 10.w,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          "$passedPrayers/5",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                          ),
                        ),
                        Text(
                          "Prayed",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String imagePath,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      height: 115.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 40.w, height: 40.w),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesSection(
    BuildContext context,
    PrayerController controller,
  ) {
    if (controller.prayerData.value == null) return const SizedBox();

    final times = controller.prayerData.value!.times;
    final prayerItems = [
      {'name': 'Fajr', 'time': times['Fajr'] ?? '00:00'},
      {'name': 'Dhuhr', 'time': times['Dhuhr'] ?? '00:00'},
      {'name': 'Asr', 'time': times['Asr'] ?? '00:00'},
      {'name': 'Maghrib', 'time': times['Maghrib'] ?? '00:00'},
      {'name': 'Isha', 'time': times['Isha'] ?? '00:00'},
    ];

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Prayer Times",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          ...prayerItems.map(
            (item) => _buildPrayerItem(context, item, controller),
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(
    BuildContext context,
    Map<String, String> data,
    PrayerController controller,
  ) {
    final nextPrayer = controller.getNextPrayerName();
    bool isNext = data['name'] == nextPrayer;

    // Check if this prayer has passed using the controller
    bool isPassed = controller.isPrayerPassed(data['name']!);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getPrayerIcon(data['name']!),
            size: 24.sp,
            color: isPassed ? const Color(0xFF2E7D32) : Colors.grey[700],
          ),
          SizedBox(width: 12.w),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    data['name']!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isPassed
                          ? const Color(0xFF2E7D32)
                          : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => PrayerNotificationSettingSheet(
                        prayerName: data['name']!,
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.volume_up_outlined,
                    size: 18.sp,
                    color: const Color(0xFF2E7D32),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isNext)
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                Text(
                  data['time']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isPassed ? const Color(0xFF2E7D32) : Colors.black87,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: isPassed
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    border: Border.all(
                      color: isPassed
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: isPassed
                      ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.cloud_outlined;
      case 'maghrib':
        return Icons.wb_twilight;
      case 'isha':
        return Icons.nights_stay_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF2E7D32) // Green color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Top center
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
