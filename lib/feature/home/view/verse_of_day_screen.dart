import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/feature/home/controller/verse_of_day_controller.dart';

class VerseOfDayScreen extends StatelessWidget {
  const VerseOfDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the existing controller instance or create a new one
    final controller = Get.find<VerseOfDayController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshVerse,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF66BB6A), // Light Green
                  Color(0xFF388E3C), // Darker Green
                ],
              ),
            ),
          ),
          // Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                // Error state
                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 60.sp,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Failed to load verse',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ElevatedButton.icon(
                          onPressed: controller.refreshVerse,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Success state - display verse
                final verse = controller.randomVerse.value;
                if (verse == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      "Verse of the Day",
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, color: Colors.white, size: 20.sp),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            controller.getVerseReference(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(flex: 1),

                    // Arabic Text
                    Text(
                      verse.data.verse.verse.text,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Display Translation from API
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        verse.data.verse.verse.translation,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // Reflection Box
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.white70,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  "Reflect on this verse and let it guide your day. May Allah's words bring peace to your heart.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Share Button
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement share functionality
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.black87,
                      ),
                      label: const Text(
                        "Share",
                        style: TextStyle(color: Colors.black87),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to full surah reading
                        // You can use verse.data.verse.surahId to navigate
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Read Full Surah",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 16.sp,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
