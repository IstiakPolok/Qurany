import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DailyGoalsCard extends StatelessWidget {
  const DailyGoalsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Goals",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "See All",
                  style: TextStyle(fontSize: 10.sp, color: Colors.green),
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32), // Green
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book, color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Read Quran Daily",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "22 / 30 min reading Today",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Spacer(),
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: CircularProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2E7D32),
                  ),
                  strokeWidth: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
