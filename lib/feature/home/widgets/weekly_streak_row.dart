import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qurany/core/const/app_colors.dart';

class WeeklyStreakRow extends StatelessWidget {
  const WeeklyStreakRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Dynamic day calculation
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1; // 0 = Monday, 6 = Sunday
    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(days.length, (index) {
          // For now, assume days before today are completed for the UI visualization
          final isCompleted = index < currentDayIndex;
          final isCurrent = index == currentDayIndex;

          return Column(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFFE8F5E9) // Light green for checked
                      : isCurrent
                      ? Colors.transparent
                      : const Color(0xFFECE7E0), // Grey for others
                  border: isCurrent
                      ? Border.all(color: primaryColor, width: 2)
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? Icon(Icons.check, size: 20.sp, color: primaryColor)
                      : null,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                days[index],
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: (isCompleted || isCurrent)
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
