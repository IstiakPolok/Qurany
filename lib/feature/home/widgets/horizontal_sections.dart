import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DidYouKnowSection extends StatelessWidget {
  const DidYouKnowSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader("Did you know", () {}),
        SizedBox(
          height: 140.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return Container(
                width: 220.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: const DecorationImage(
                    image: AssetImage('assets/image/bg2.png'), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  padding: EdgeInsets.all(12.w),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Masjid Quba is the first mosque in Islam",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              "See all",
              style: TextStyle(fontSize: 12.sp, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class RecitersSection extends StatelessWidget {
  const RecitersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader("Reciters", () {}),
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35.r,
                        backgroundImage: AssetImage(
                          'assets/image/bg2.png',
                        ), // Placeholder
                      ),
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          size: 16.sp,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text("Mishary", style: TextStyle(fontSize: 12.sp)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              "See all",
              style: TextStyle(fontSize: 12.sp, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader("Quranic Stories", () {}),
        SizedBox(
          height: 140.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              return Container(
                width: 160.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: const DecorationImage(
                    image: AssetImage('assets/image/bg2.png'), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  padding: EdgeInsets.all(12.w),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Story of Prophet Yusuf",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              "See all",
              style: TextStyle(fontSize: 12.sp, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class AzkarSection extends StatelessWidget {
  const AzkarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader("Azkar", () {}),
        SizedBox(
          height: 140.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final isMorning = index == 0;
              return Container(
                width: 180.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  color: isMorning
                      ? Colors.orange.shade100
                      : Colors.indigo.shade100, // Placeholder
                ),
                child: Stack(
                  children: [
                    // Should add Image here
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMorning ? "Morning Azkar" : "Evening Azkar",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                            Text(
                              "08:00 AM",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              "See all",
              style: TextStyle(fontSize: 12.sp, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
