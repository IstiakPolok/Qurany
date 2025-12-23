import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/feature/prayer/view/electronic_tasbih_screen.dart';
import 'package:qurany/feature/compass/views/qibla_compass_screen.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (Background, Header, Timeline)
            Container(
              height: 425.h,
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
                      left: 24.w,
                      right: 24.w,
                      top: 50.h,
                      bottom: 4.h,
                    ),
                    child: Column(
                      children: [
                        // Location Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Abu Dhabi, Dubai",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.sp,
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
                                    decoration: BoxDecoration(
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

                        SizedBox(height: 24.h),

                        // Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white70,
                              size: 14.sp,
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              children: [
                                Text(
                                  "Today, 3 December",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "20 Rabi' al-Awal 1446",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 14.sp,
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Time
                        Text(
                          "11:18",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 56.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 12.h),

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
                              Text(
                                "Dhohr will begin in",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
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

                        Spacer(),

                        // Timeline Scroller
                        SizedBox(
                          height: 110
                              .h, // Adjusted height for bigger active card + indicator
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            separatorBuilder: (context, index) =>
                                SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
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

                              return Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .end, // Align to bottom so indicators align
                                children: [
                                  Container(
                                    width: 80.w,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF4E4B45)
                                          : Colors
                                                .transparent, // Dark brown/grey bg for active
                                      borderRadius: BorderRadius.circular(12.r),
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
                                          size: 18.sp,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          item['name'] as String,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white70,
                                            fontSize: isSelected
                                                ? 12.sp
                                                : 10.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          item['time'] as String,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.white70,
                                            fontSize: isSelected
                                                ? 12.sp
                                                : 10.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Transform.translate(
                                      offset: Offset(
                                        0,
                                        -6.h,
                                      ), // Move up to overlap slightly or connect
                                      child: CustomPaint(
                                        size: Size(16.w, 10.h),
                                        painter: TrianglePainter(),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      height: 10.h,
                                    ), // Spacer to align unselected items
                                ],
                              );
                            },
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
                        icon: Icons.explore,
                        title: "Locate",
                        subtitle: "Qibla",
                        color: const Color(0xFFE8F5E9),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 50.w,
                                height: 50.w,
                                child: CircularProgressIndicator(
                                  value: 0.2, // 1/5
                                  backgroundColor: Colors.white,
                                  color: const Color(0xFF2E7D32),
                                  strokeWidth: 6,
                                ),
                              ),
                              Text(
                                "1/5",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Prayed",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12.sp,
                            ),
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
                        icon: Icons.touch_app,
                        title: "Electronic",
                        subtitle: "Tasbih",
                        color: const Color(0xFFE8F5E9),
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
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              shape: BoxShape.circle, // Or customized shape
              // Use ClipPath for hexagon if needed, strictly circle for now
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
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
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
          Text(
            data['name'],
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8.w),
          Icon(
            Icons.volume_up_outlined,
            size: 18.sp,
            color: const Color(0xFF2E7D32),
          ),

          Spacer(),

          if (isNext)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                "in 37m 13s",
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
              ),
            ),

          Text(
            data['time'],
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 12.w),

          // Checkbox (custom for style match)
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFF2E7D32) : Colors.transparent,
              border: Border.all(
                color: isChecked ? const Color(0xFF2E7D32) : Colors.grey[400]!,
              ),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: isChecked
                ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                : null,
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
