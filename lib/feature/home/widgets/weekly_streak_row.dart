import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qurany/core/const/app_colors.dart';

class WeeklyStreakRow extends StatelessWidget {
  const WeeklyStreakRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Current day is Thursday (T) based on image, but we can make it dynamic or fixed for now.
    // Let's assume M T W T F S S
    final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(days.length, (index) {
          final isCompleted = index == 0; // Monday checked
          final isCurrent = index == 1; // Tuesday current

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
                      : const Color(0xFFF0F0F0), // Grey for others
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
