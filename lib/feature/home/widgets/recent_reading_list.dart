import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/quran/view/surah_reading_screen.dart';

class RecentReadingList extends StatelessWidget {
  const RecentReadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SharedPreferencesHelper.getRecentReadingHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 10.h,
            child: Center(
              child: Text(
                ' ',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
          );
        }

        final history = snapshot.data!;

        return SizedBox(
          height: 250.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: history.length,
            separatorBuilder: (context, index) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final item = history[index];
              final surahName = item['surahName'] ?? 'Unknown';
              final arabicName = item['arabicName'] ?? '';
              final lastVerseId = item['lastVerseId'] ?? 1;
              final totalVerses = item['totalVerses'] ?? 1;
              final surahId = item['surahId'] ?? 1;

              // Calculate percentage
              final percentage = ((lastVerseId / totalVerses) * 100)
                  .clamp(0.0, 100.0)
                  .toInt();

              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => SurahReadingScreen(
                      surahId: surahId,
                      surahName: surahName,
                      arabicName: arabicName,
                      meaning: surahName,
                      origin: 'Meccan',
                      ayaCount: totalVerses,
                      translation: surahName,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 240.w,
                      height: 180.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        image: const DecorationImage(
                          image: AssetImage('assets/image/bg2.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black38,
                            BlendMode.darken,
                          ),
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
                                    "Recently Read",
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$percentage%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 14.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: 200.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "$surahName : $lastVerseId",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: Transform.rotate(
                              angle: math.pi / 4,
                              child: Icon(
                                Icons.arrow_upward,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
