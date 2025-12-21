import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qurany/core/const/app_colors.dart';

class QuranTabSection extends StatelessWidget {
  const QuranTabSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quran",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                "View all",
                style: TextStyle(fontSize: 12.sp, color: Colors.green),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14.sp,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              suffixIcon: Icon(Icons.mic, color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16.w,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Tabs
          Row(
            children: [
              _buildTab("Surah", true),
              SizedBox(width: 8.w),
              _buildTab("Juzz", false),
            ],
          ),
          SizedBox(height: 16.h),

          // List
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 4,
            separatorBuilder: (_, __) => Divider(height: 24.h, thickness: 0.5),
            itemBuilder: (context, index) {
              return _buildSurahItem(index);
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? primaryColor : Colors.grey.shade300,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildSurahItem(int index) {
    final surahs = [
      {
        "no": "1",
        "nameEn": "Al-Fatihah",
        "nameAr": "الفاتحة",
        "place": "MECCAN",
        "verses": "7 Verses",
      },
      {
        "no": "2",
        "nameEn": "Al-Baqarah",
        "nameAr": "البقرة",
        "place": "MEDINAN",
        "verses": "286 Verses",
      },
      {
        "no": "3",
        "nameEn": "Ali 'Imran",
        "nameAr": "آل عمران",
        "place": "MEDINAN",
        "verses": "200 Verses",
      },
      {
        "no": "4",
        "nameEn": "An-Nisa",
        "nameAr": "النساء",
        "place": "MEDINAN",
        "verses": "176 Verses",
      },
    ];

    final item = surahs[index];

    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.star_border,
              color: primaryColor,
              size: 36.sp,
            ), // Placeholder for star shape
            Text(
              item["no"]!,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item["nameEn"]!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            Row(
              children: [
                Text(
                  item["place"]!,
                  style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                ),
                SizedBox(width: 4.w),
                Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  item["verses"]!,
                  style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                ),
              ],
            ),
          ],
        ),
        Spacer(),
        Text(
          item["nameAr"]!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            fontFamily: 'Amiri',
          ),
        ), // Use Arabic font
      ],
    );
  }
}
