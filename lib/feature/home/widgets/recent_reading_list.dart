import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentReadingList extends StatelessWidget {
  const RecentReadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (context, index) => SizedBox(width: 16.w),
        itemBuilder: (context, index) {
          final isFirst = index == 0;
          return Container(
            width: 200.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: const DecorationImage(
                image: AssetImage(
                  'assets/image/bg2.png',
                ), // Placeholder for Quran book image
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          "Verse - Read",
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        isFirst ? "Al-Baqarah : 120" : "Al-Imran : 130",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 16.h,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32), // Green
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
                // Progress Bar
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      "17% 📚",
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
