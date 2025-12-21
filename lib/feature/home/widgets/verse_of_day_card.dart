import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class VerseOfDayCard extends StatelessWidget {
  const VerseOfDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: AssetImage('assets/image/login_OptionBG.png'), // Placeholder
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Verse of the Day",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12.sp,
                  ),
                ),
                Icon(Icons.share, color: Colors.white, size: 20.sp),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              "📖 Surah Ash-Shams-7:10", // Placeholder reference
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
            Spacer(),
            Text(
              "وَنَفْسٍ وَمَا سَوَّاهَا فَأَلْهَمَهَا فُجُورَهَا وَتَقْوَاهَا",
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              maxLines: 2,
              style: GoogleFonts.amiri(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "\"And I did not create the jinn and mankind\nexcept to worship Me.\"",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
