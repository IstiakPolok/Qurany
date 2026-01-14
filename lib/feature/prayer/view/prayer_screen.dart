import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:qurany/feature/prayer/view/electronic_tasbih_screen.dart';
import 'package:qurany/feature/compass/views/qibla_compass_screen.dart';
import 'package:qurany/feature/profile/view/prayer_notification_setting_sheet.dart';
import 'islamic_calendar_screen.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  DateTime _selectedDate = DateTime.now();
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _changeDate(int offset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offset));
    });
  }

  String _getFormattedGregorianDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    String prefix = "";
    if (selected == today) {
      prefix = "Today, ";
    } else if (selected == today.add(const Duration(days: 1))) {
      prefix = "Tomorrow, ";
    } else if (selected == today.subtract(const Duration(days: 1))) {
      prefix = "Yesterday, ";
    } else {
      return DateFormat('EEEE, d MMMM').format(date);
    }
    return "$prefix${DateFormat('d MMMM').format(date)}";
  }

  String _getFormattedHijriDate(DateTime date) {
    final hDate = HijriCalendar.fromDate(date);
    return "${hDate.hDay} ${hDate.longMonthName} ${hDate.hYear}";
  }

  // Mock data for prayer times
  final List<Map<String, dynamic>> _prayerTimes = [
    {
      'name': 'Fajar',
      'time': '4:37 AM',
      'icon':
          'assets/icons/navprayerIcons.png', // Placeholder, use suitable sun/moon icons
      'isPassed': true,
      'isNext': false,
    },
    {
      'name': 'Dhohr',
      'time': '11:55 AM',
      'icon': 'assets/icons/navprayerIcons.png',
      'isPassed': false,
      'isNext': true,
    },
    {
      'name': 'Asr',
      'time': '3:00 PM',
      'icon': 'assets/icons/navprayerIcons.png',
      'isPassed': false,
      'isNext': false,
    },
    {
      'name': 'Maghreb',
      'time': '5:55 PM',
      'icon': 'assets/icons/navprayerIcons.png',
      'isPassed': false,
      'isNext': false,
    },
    {
      'name': 'Isha',
      'time': '7:55 PM',
      'icon': 'assets/icons/navprayerIcons.png',
      'isPassed': false,
      'isNext': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topSectionHeight = (screenHeight * 0.52).clamp(380.0, 500.0);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (Background, Header, Timeline)
            Container(
              height: topSectionHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/image/prayerBG.png',
                  ), // Need a suitable mosque image in assets. If not, color fallback
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  // Gradient Overlay for visibility
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Flexible(
                                      child: Text(
                                        "Abu Dhabi, Dubai",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => _changeDate(-1),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white70,
                                  size: 14.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const IslamicCalendarScreen(),
                                  ),
                                );
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                children: [
                                  Text(
                                    _getFormattedGregorianDate(_selectedDate),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _getFormattedHijriDate(_selectedDate),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 4.w),
                            GestureDetector(
                              onTap: () => _changeDate(1),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                  size: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16.h),

                        // Time
                        FittedBox(
                          child: Text(
                            DateFormat('HH:mm').format(_currentTime),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 56.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Countdown Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "Dhohr will begin in",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  "-00:37:25",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Timeline Row (No Scroll)
                        SizedBox(
                          height: 110.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              // Data for the timeline
                              final List<Map<String, dynamic>> timelineItems = [
                                {
                                  'name': 'Fajar',
                                  'time': '04:37 AM',
                                  'icon': Icons.wb_twilight,
                                },
                                {
                                  'name': 'Sunrise',
                                  'time': '05:55 AM',
                                  'icon': Icons.wb_sunny_outlined,
                                },
                                {
                                  'name': 'Dhohr',
                                  'time': '11:55 AM',
                                  'icon': Icons.wb_sunny,
                                },
                                {
                                  'name': 'Asr',
                                  'time': '03:00 PM',
                                  'icon': Icons.cloud_outlined,
                                },
                                {
                                  'name': 'Maghreb',
                                  'time': '05:55 PM',
                                  'icon': Icons.wb_twilight,
                                },
                                {
                                  'name': 'Isha',
                                  'time': '07:55 PM',
                                  'icon': Icons.nights_stay_outlined,
                                },
                              ];

                              bool isSelected = index == 2; // Dhohr active
                              final item = timelineItems[index];

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
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            item['icon'] as IconData,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white70,
                                            size: 16.sp,
                                          ),
                                          SizedBox(height: 6.h),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              item['name'] as String,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white70,
                                                fontSize: isSelected
                                                    ? 11.sp
                                                    : 9.sp,
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
                                              (item['time'] as String)
                                                  .replaceFirst(' AM', 'am')
                                                  .replaceFirst(' PM', 'pm'),
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.white70,
                                                fontSize: isSelected
                                                    ? 10.sp
                                                    : 8.sp,
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Cards
            Padding(
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
                        imagePath:
                            "assets/icons/qibladirctioninprayerIcons.png",
                        title: "Locate",
                        subtitle: "Qibla",
                        color: const Color(0xFFE2E9D8),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      height: 115.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E9D8),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
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
                                  value: 0.2, // 1/5
                                  backgroundColor: Colors.white,
                                  color: const Color(0xFF2E7D32),
                                  strokeWidth: 10.w,
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "1/5",
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
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ElectronicTasbihScreen(),
                          ),
                        );
                      },
                      child: _buildActionCard(
                        imagePath:
                            "assets/icons/electrictasbihinpracyericon.png",
                        title: "Electronic",
                        subtitle: "Tasbih",
                        color: const Color(0xFFE2E9D8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Today's Prayer Times
            Container(
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
                  ...List.generate(_prayerTimes.length, (index) {
                    return _buildPrayerItem(_prayerTimes[index]);
                  }),
                  SizedBox(height: 80.h), // Bottom text padding
                ],
              ),
            ),
          ],
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

  Widget _buildPrayerItem(Map<String, dynamic> data) {
    bool isNext = data['isNext'];
    bool isChecked = data['isPassed'];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          // Subtle shadow
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
            Icons.wb_sunny_outlined,
            size: 24.sp,
            color: Colors.grey[700],
          ), // Placeholder icon
          SizedBox(width: 12.w),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    data['name'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
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
                        prayerName: data['name'],
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
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        "in 37m 13s",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                Text(
                  data['time'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 12.w),

                // Checkbox (custom for style match)
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? const Color(0xFF2E7D32)
                        : Colors.transparent,
                    border: Border.all(
                      color: isChecked
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: isChecked
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
