import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeelingWidget extends StatelessWidget {
  const FeelingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            "Personalized your recommendation",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9), // Light green bg
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sentiment_satisfied,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "How do you feel today?",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
