import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/const/app_colors.dart';
import 'package:qurany/feature/home/widgets/add_goal_bottom_sheet.dart';

class DailyGoalsCard extends StatefulWidget {
  const DailyGoalsCard({super.key});
  @override
  State<DailyGoalsCard> createState() => _DailyGoalsCardState();
}

class _DailyGoalsCardState extends State<DailyGoalsCard> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= goals.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> goals = const [
    {
      'title': 'Read Quran Daily',
      'progress': 0.25,
      'current': 22,
      'total': 30,
      'unit': 'min reading Today',
      'icon': "assets/icons/navquranIcons.png",
    },
    {
      'title': 'Memorize Verses',
      'progress': 0.6,
      'current': 3,
      'total': 5,
      'unit': 'verses memorized',
      'icon': "assets/icons/123.png",
    },
    {
      'title': 'Reflect on Ayah',
      'progress': 0.8,
      'current': 8,
      'total': 10,
      'unit': 'ayahs reflected',
      'icon': "assets/icons/navquranIcons.png",
    },
  ];

  void _showAddGoalsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddGoalBottomSheet(),
    );
  }

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
              GestureDetector(
                onTap: _showAddGoalsSheet,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "+ See All",
                    style: TextStyle(fontSize: 12.sp, color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 95.h,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: goals.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final goal = goals[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E9D8),
                    borderRadius: BorderRadius.circular(9.r),
                    border: Border.all(
                      color: const Color(0xFF2F7D33),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          goal['icon'],
                          width: 24.w,
                          height: 24.h,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal['title'],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "${goal['current']} / ${goal['total']} ${goal['unit']}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: subheading,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      SizedBox(
                        width: 40.w,
                        height: 40.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: goal['progress'],
                              backgroundColor: Color(0xFF2E7D32),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFD9D9D9),
                              ),
                              strokeWidth: 4,
                            ),
                            Text(
                              "${(goal['progress'] * 100).round()}",
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.h),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(goals.length, (index) {
                          return Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? const Color(0xFF2E7D32)
                                  : const Color.fromARGB(181, 217, 217, 217),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
