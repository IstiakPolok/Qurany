import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:get/get.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

class WeeklyStreakRow extends StatefulWidget {
  const WeeklyStreakRow({super.key});

  @override
  State<WeeklyStreakRow> createState() => _WeeklyStreakRowState();
}

class _WeeklyStreakRowState extends State<WeeklyStreakRow> {
  final List<bool> _completedDays = List.filled(7, false);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  Future<void> _loadStreakData() async {
    final now = DateTime.now();
    // Monday is 1, Sunday is 7 in DateTime.weekday
    // We want to find the start of the current week (Monday)
    final monday = now.subtract(Duration(days: now.weekday - 1));

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      _completedDays[i] = await SharedPreferencesHelper.isLoggedAt(date);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink(); // Or a loader
    }

    // Dynamic day calculation
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1; // 0 = Monday, 6 = Sunday
    final List<String> days = [
      'mon'.tr,
      'tue'.tr,
      'wed'.tr,
      'thu'.tr,
      'fri'.tr,
      'sat'.tr,
      'sun'.tr,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(days.length, (index) {
          final isCompleted = _completedDays[index];
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
