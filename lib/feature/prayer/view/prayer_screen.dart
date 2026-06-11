import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qurany/feature/prayer/view/electronic_tasbih_screen.dart';
import 'package:qurany/feature/compass/views/qibla_compass_screen.dart';
import 'package:qurany/feature/profile/view/prayer_notification_setting_sheet.dart';
import '../../../core/services/location_service.dart';
import '../../home/view/notification_screen.dart';
import '../controller/prayer_controller.dart';
import 'islamic_calendar_screen.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  /// Converts 24-hour format time string to 12-hour format with AM/PM
  static String convertTo12Hour(String time) {
    if (time == '--:--') return time;
    try {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $ampm';
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PrayerController controller = Get.put(PrayerController());
    final LocationService locationService = Get.find<LocationService>();

    return Scaffold(
      backgroundColor: Color(0XFFFFFAF3),
      body: Obx(() {
        if ((controller.isLoading.value &&
                controller.prayerData.value == null) ||
            locationService.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return _buildErrorState(controller);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Column(
                    children: [
                      // Hero background section
                      _buildTopSection(context, controller, locationService),
                      // Extra space to ensure Stack encompasses the protruding cards
                      SizedBox(height: 100.h),
                    ],
                  ),
                  // Action cards float over the bottom of the hero
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0XFFFFFAF3),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildActionCardsRow(context, controller),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildPrayerTimesSection(context, controller, locationService),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(PrayerController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'prayer_times_unavailable'.tr,
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
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => controller.refreshPrayerTimes(),
            icon: const Icon(Icons.refresh),
            label: Text('try_again'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    PrayerController controller,
    LocationService locationService,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/prayerBG.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.25),
              Colors.black.withOpacity(0.55),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            // Extra bottom padding so the card overlap area stays visible
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 80.h),
            child: Column(
              children: [
                _buildLocationHeader(locationService),
                SizedBox(height: 14.h),
                _buildDateNavigation(context, controller),
                SizedBox(height: 4.h),
                _buildCountdownBadge(controller),
                // SizedBox(height: 20.h),
                _buildTimeline(controller),
              ],
            ),
          ),
        ),
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 15.sp),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Obx(
                      () => Text(
                        locationService.currentLocation.value,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.chevron_right, color: Colors.white70, size: 16.sp),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () => Get.to(() => const NotificationScreen()),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "2",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => controller.previousDay(),
                child: Icon(
                  Icons.chevron_left,
                  color: Colors.white70,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IslamicCalendarScreen(),
                  ),
                ),
                child: Text(
                  DateFormat('EEEE, d MMMM').format(date),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => controller.nextDay(),
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            controller.getFormattedHijriDate(),
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 12.sp),
          ),
        ],
      );
    });
  }

  Widget _buildCountdownBadge(PrayerController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${'next_prayer_begin'.trParams({'prayer': controller.getNextPrayerName()})}  ',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 13.sp),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Obx(
            () => Text(
              controller.getTimeRemaining(),
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(PrayerController controller) {
    if (controller.prayerData.value == null) return SizedBox(height: 90.h);

    final times = controller.prayerData.value!.times;
    final timelineItems = [
      {
        'name': 'Fajr',
        'time': convertTo12Hour(times['Fajr'] ?? '--:--'),
        'icon': Icons.wb_twilight,
      },
      {
        'name': 'Sunrise',
        'time': convertTo12Hour(times['Sunrise'] ?? '--:--'),
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'name': 'Dhuhr',
        'time': convertTo12Hour(times['Dhuhr'] ?? '--:--'),
        'icon': Icons.wb_sunny,
      },
      {
        'name': 'Asr',
        'time': convertTo12Hour(times['Asr'] ?? '--:--'),
        'icon': Icons.cloud_outlined,
      },
      {
        'name': 'Maghrib',
        'time': convertTo12Hour(times['Maghrib'] ?? '--:--'),
        'icon': Icons.wb_twilight_outlined,
      },
      {
        'name': 'Isha',
        'time': convertTo12Hour(times['Isha'] ?? '--:--'),
        'icon': Icons.nights_stay_outlined,
      },
    ];

    final nextPrayer = controller.getNextPrayerName();

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 6.w;
        final cardWidth = (constraints.maxWidth - (spacing * 5)) / 6;

        return SizedBox(
          height: 132.h,
          width: double.infinity,
          child: Row(
            children: List.generate(timelineItems.length, (index) {
              final item = timelineItems[index];
              final bool isSelected = (item['name'] as String) == nextPrayer;

              return Padding(
                padding: EdgeInsets.only(
                  right: index == timelineItems.length - 1 ? 0 : spacing,
                ),
                child: SizedBox(
                  width: cardWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 105.h,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF3A3A35).withOpacity(0.85)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14.r),
                          border: isSelected
                              ? Border.all(color: Colors.white24, width: 1)
                              : Border.all(
                                  color: Colors.transparent.withOpacity(0.2),
                                  width: 1,
                                ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 8.h),
                            Icon(
                              item['icon'] as IconData,
                              color: isSelected ? Colors.white : Colors.white60,
                              size: 22.sp,
                            ),
                            SizedBox(height: 10.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item['name'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: GoogleFonts.outfit(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white60,
                                  fontSize: 11.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item['time'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: GoogleFonts.outfit(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 10.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            SizedBox(height: 6.h),
                          ],
                        ),
                      ),
                      if (isSelected)
                        CustomPaint(
                          size: Size(14.w, 8.h),
                          painter: _TrianglePainter(),
                        )
                      else
                        SizedBox(height: 8.h),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  /// Cards rendered inside the Stack overlap — no white wrapper background here.
  Widget _buildActionCardsRow(
    BuildContext context,
    PrayerController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              print('[DEBUG] Qibla Compass button tapped!');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const QiblaCompassScreen(showBackButton: true),
                ),
              );
            },
            child: _buildActionCard(
              imagePath: "assets/icons/qibladirctioninprayerIcons.png",
              title: "locate".tr,
              subtitle: "qibla".tr,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(child: _buildPrayerProgressCard(controller)),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              print('[DEBUG] Electronic Tasbih button tapped!');
              Get.to(ElectronicTasbihScreen());
            },
            child: _buildActionCard(
              imagePath: "assets/icons/electrictasbihinpracyericon.png",
              title: "electronic".tr,
              subtitle: "tasbih".tr,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Container(
      height: 118.h,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E9D8),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 36.w, height: 36.w),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 11.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerProgressCard(PrayerController controller) {
    return Container(
      height: 118.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E9D8),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: GetBuilder<PrayerController>(
        builder: (ctrl) {
          final checkedCount = [
            'Fajr',
            'Dhuhr',
            'Asr',
            'Maghrib',
            'Isha',
          ].where((p) => ctrl.isPrayerChecked(p)).length;
          final progress = checkedCount / 5.0;

          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72.w,
                  height: 72.w,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Color(0XFFFFFAF3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E7D32),
                    ),
                    strokeWidth: 8.w,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$checkedCount/5",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.sp,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "prayed".tr,
                      style: GoogleFonts.outfit(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrayerTimesSection(
    BuildContext context,
    PrayerController controller,
    LocationService locationService,
  ) {
    return Container(
      color: Color(0XFFFFFAF3),
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "today_prayer_times".tr,
            style: GoogleFonts.outfit(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 14.h),
          if (controller.prayerData.value == null)
            _buildLocationErrorMessage(locationService, controller)
          else
            ...(() {
              final times = controller.prayerData.value!.times;
              final prayerItems = [
                {
                  'name': 'Fajr',
                  'time': convertTo12Hour(times['Fajr'] ?? '--:--'),
                },
                {
                  'name': 'Dhuhr',
                  'time': convertTo12Hour(times['Dhuhr'] ?? '--:--'),
                },
                {
                  'name': 'Asr',
                  'time': convertTo12Hour(times['Asr'] ?? '--:--'),
                },
                {
                  'name': 'Maghrib',
                  'time': convertTo12Hour(times['Maghrib'] ?? '--:--'),
                },
                {
                  'name': 'Isha',
                  'time': convertTo12Hour(times['Isha'] ?? '--:--'),
                },
              ];
              return prayerItems.map(
                (item) => _buildPrayerItem(context, item, controller),
              );
            })(),
        ],
      ),
    );
  }

  Widget _buildLocationErrorMessage(
    LocationService locationService,
    PrayerController controller,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEA),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF44336).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            color: const Color(0xFFD32F2F),
            size: 48.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            "location_required_title".tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD32F2F),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "location_required_msg".tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.black87),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () => locationService.refreshLocation(),
            icon: Icon(Icons.my_location, size: 18.sp),
            label: Text("enable_location".tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(
    BuildContext context,
    Map<String, String> data,
    PrayerController controller,
  ) {
    final prayerName = data['name']!;
    final nextPrayer = controller.getNextPrayerName();
    final bool isNext = prayerName == nextPrayer;

    return GetBuilder<PrayerController>(
      builder: (ctrl) {
        final checked = ctrl.isPrayerChecked(prayerName);
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isNext
                  ? const Color(0xFF2E7D32).withOpacity(0.2)
                  : Colors.grey[200]!,
              width: isNext ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: checked
                      ? const Color(0xFF2E7D32).withOpacity(0.1)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getPrayerIcon(prayerName),
                  size: 18.sp,
                  color: checked ? const Color(0xFF2E7D32) : Colors.grey[500],
                ),
              ),
              SizedBox(width: 12.w),

              // Name + volume
              Expanded(
                child: Row(
                  children: [
                    Text(
                      prayerName,
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: checked
                            ? const Color(0xFF2E7D32)
                            : Colors.black87,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => PrayerNotificationSettingSheet(
                            prayerName: prayerName,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.volume_up_outlined,
                        size: 16.sp,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),

              // Countdown + time + checkbox
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isNext) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Obx(
                        () => Text(
                          controller.getTimeRemaining(),
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    data['time']!,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: checked ? const Color(0xFF2E7D32) : Colors.black54,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () => ctrl.togglePrayerChecked(prayerName),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: checked
                            ? const Color(0xFF2E7D32)
                            : Colors.transparent,
                        border: Border.all(
                          color: checked
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[350]!,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: checked
                          ? Icon(Icons.check, color: Colors.white, size: 14.sp)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
        return Icons.wb_twilight_outlined;
      case 'isha':
        return Icons.nights_stay_outlined;
      default:
        return Icons.wb_sunny_outlined;
    }
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
