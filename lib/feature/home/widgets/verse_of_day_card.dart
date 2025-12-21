import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class VerseOfDayCard extends StatelessWidget {
  const VerseOfDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      height: 230.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: AssetImage('assets/image/VerseOfDayCard.png'), // Placeholder
          fit: BoxFit.fill,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Verse of the Day",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.share_outlined, color: Colors.white, size: 20.sp),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Image.asset(
                    'assets/icons/navquranIcons.png',
                    width: 20.w,
                    height: 20.h,
                    color: Colors.white,
                  ), // Placeholder Bismillah icon
                  SizedBox(width: 8.w),
                  Text(
                    "Surah Ash-Shams (7:10)", // Placeholder reference
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/icons/123.png',
                    width: 24.w,
                    height: 24.h,
                  ), // Placeholder icon
                  SizedBox(width: 8.w),
                  Text(
                    "وَمَا خَلَقْتُ الْجِنَّ وَالْإِنسَ إِلَّا لِيَعْبُدُونِ",
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                "\"And I did not create the jinn and mankind\nexcept to worship Me.\"",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Read Full Surah →',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
