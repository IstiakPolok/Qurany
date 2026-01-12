import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'notification_sound_screen.dart';

class PrayerNotificationSettingSheet extends StatefulWidget {
  final String prayerName;
  const PrayerNotificationSettingSheet({super.key, required this.prayerName});

  @override
  State<PrayerNotificationSettingSheet> createState() =>
      _PrayerNotificationSettingSheetState();
}

class _PrayerNotificationSettingSheetState
    extends State<PrayerNotificationSettingSheet> {
  bool isAllowed = true;
  Set<int> selectedDays = {0, 1, 6}; // Mon, Tue, Sun

  String notificationSound = "Adhan(Makkah)";
  String preAdhanReminder = "None";

  final List<String> days = ["M", "T", "W", "T", "F", "S", "S"];

  String _getSelectedDaysText() {
    if (selectedDays.isEmpty) return "None";
    if (selectedDays.length == 7) return "Everyday";
    List<String> selectedNames = [];
    if (selectedDays.contains(6)) selectedNames.add("Sun");
    if (selectedDays.contains(0)) selectedNames.add("Mon");
    if (selectedDays.contains(1)) selectedNames.add("Tue");
    if (selectedDays.contains(2)) selectedNames.add("Wed");
    if (selectedDays.contains(3)) selectedNames.add("Thu");
    if (selectedDays.contains(4)) selectedNames.add("Fri");
    if (selectedDays.contains(5)) selectedNames.add("Sat");
    return selectedNames.join(", ");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 30.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${widget.prayerName} Notification Setting",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F2630),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(Icons.close, size: 20.sp, color: Colors.black87),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Allow Notification Card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Allow Notification",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Switch(
                  value: isAllowed,
                  onChanged: (value) => setState(() => isAllowed = value),
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF2E7D32),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Repeats Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Repeats",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                _getSelectedDaysText(),
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              bool isSelected = selectedDays.contains(index);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedDays.remove(index);
                    } else {
                      selectedDays.add(index);
                    }
                  });
                },
                child: _HexagonDay(day: days[index], isSelected: isSelected),
              );
            }),
          ),
          SizedBox(height: 20.h),
          const Divider(height: 1),
          SizedBox(height: 4.h),

          // Notification Sound
          _buildMenuItem("Notification Sound", notificationSound, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSoundScreen(),
              ),
            );
          }),
          _buildDivider(),

          // Pre-Adhan Reminder
          _buildMenuItem("Pre-Adhan Reminder", preAdhanReminder, () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200]);
  }
}

class _HexagonDay extends StatelessWidget {
  final String day;
  final bool isSelected;
  const _HexagonDay({required this.day, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HexagonClipper(),
      child: Container(
        width: 44.w,
        height: 48.h,
        color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE8EDE3),
        alignment: Alignment.center,
        child: Text(
          day,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.lineTo(0, size.height * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
