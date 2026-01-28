import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/home/controller/verse_of_day_controller.dart';
import 'package:qurany/feature/home/view/verse_of_day_screen.dart';

class VerseOfDayCard extends StatelessWidget {
  const VerseOfDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerseOfDayController());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VerseOfDayScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        constraints: BoxConstraints(minHeight: 180.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: const DecorationImage(
            image: AssetImage('assets/image/VerseOfDayCard.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Center(
            child: Obx(() {
              // Loading state
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              // Error state
              if (controller.errorMessage.value.isNotEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 40.sp),
                    SizedBox(height: 8.h),
                    Text(
                      'Failed to load verse',
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton(
                      onPressed: controller.refreshVerse,
                      child: const Text('Retry'),
                    ),
                  ],
                );
              }

              // Success state - display verse
              final verse = controller.randomVerse.value;
              if (verse == null) {
                return const SizedBox.shrink();
              }

              return Column(
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
                      Icon(
                        Icons.share_outlined,
                        color: Colors.white,
                        size: 20.sp,
                      ),
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
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          controller.getVerseReference(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/icons/123.png',
                            width: 30.w,
                            height: 30.h,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              verse.data.verse.verse.text,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      verse.data.verse.verse.translation,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerseOfDayScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Read Full Surah →',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
