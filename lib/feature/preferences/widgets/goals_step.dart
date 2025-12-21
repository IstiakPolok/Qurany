import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalsStep extends StatefulWidget {
  const GoalsStep({super.key});

  @override
  State<GoalsStep> createState() => _GoalsStepState();
}

class _GoalsStepState extends State<GoalsStep> {
  // Using Set for multi-selection
  final Set<String> _selectedGoals = {'Memorize Quran'};

  final List<Map<String, dynamic>> goals = [
    {'title': 'Memorize Quran', 'iconPath': 'assets/icons/MemorizeQuran.png'},
    {'title': 'Prayer Guidance', 'iconPath': 'assets/icons/PrayerGuidance.png'},
    {'title': 'Learn Tajweed', 'iconPath': 'assets/icons/LearnTajweed.png'},
    {
      'title': 'Spiritual Growth',
      'iconPath': 'assets/icons/SpiritualGrowth.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Text(
            "What are your goals?",
            style: GoogleFonts.abhayaLibre(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Select all that apply to personalize your experience.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 30.h),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: goals.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              return _buildGoalOption(goals[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption(Map<String, dynamic> goal) {
    String title = goal['title'];
    String iconPath = goal['iconPath'];
    bool isSelected = _selectedGoals.contains(title);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedGoals.remove(title);
          } else {
            _selectedGoals.add(title);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 28.w,
              height: 28.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey.shade400,
                  width: 2.w,
                ),
                color: isSelected ? Colors.green : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
