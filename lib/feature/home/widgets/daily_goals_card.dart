import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/const/app_colors.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import 'package:get/get.dart';
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

  // Full catalog — titles must match AddGoalBottomSheet exactly
  static const List<Map<String, dynamic>> _goalCatalog = [
    {
      'title': 'goal_read_quran',
      'progress': 0.25,
      'current': 22,
      'total': 30,
      'unit': 'min_reading_today',
      'icon': 'assets/icons/navquranIcons.png',
    },
    {
      'title': 'goal_memorize',
      'progress': 0.6,
      'current': 3,
      'total': 5,
      'unit': 'verses_memorized',
      'icon': 'assets/icons/123.png',
    },
    {
      'title': 'goal_prayers',
      'progress': 0.8,
      'current': 4,
      'total': 5,
      'unit': 'prayers_completed',
      'icon': 'assets/icons/navquranIcons.png',
    },
    {
      'title': 'goal_dhikr',
      'progress': 0.5,
      'current': 50,
      'total': 100,
      'unit': 'dhikr_completed',
      'icon': 'assets/icons/123.png',
    },
  ];

  List<Map<String, dynamic>> _activeGoals = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadGoals();
    // Refresh reading progress every 30 seconds while the widget is active
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadGoals();
    });
  }

  Future<void> _loadGoals() async {
    final savedTitles = await SharedPreferencesHelper.getGoals();

    // Fetch real data for each goal
    final readingSeconds =
        await SharedPreferencesHelper.getDailyReadingSeconds();
    final readingMinutes = (readingSeconds / 60).floor();
    const int readingGoalMinutes = 30;

    final memorizedCount =
        await SharedPreferencesHelper.getDailyMemorizedCount();
    const int memorizeGoal = 5;

    final prayersCompleted =
        await SharedPreferencesHelper.getCompletedPrayersToday();
    const int prayerGoal = 5;

    final dhikrCount = await SharedPreferencesHelper.getDailyDhikrCount();
    const int dhikrGoal = 100;

    final matched = _goalCatalog
        .map((g) {
          switch (g['title']) {
            case 'goal_read_quran':
              final clamped = readingMinutes.clamp(0, readingGoalMinutes);
              return {
                ...g,
                'current': clamped,
                'total': readingGoalMinutes,
                'progress': (clamped / readingGoalMinutes).clamp(0.0, 1.0),
              };
            case 'goal_memorize':
              final clamped = memorizedCount.clamp(0, memorizeGoal);
              return {
                ...g,
                'current': clamped,
                'total': memorizeGoal,
                'progress': (clamped / memorizeGoal).clamp(0.0, 1.0),
              };
            case 'goal_prayers':
              final clamped = prayersCompleted.clamp(0, prayerGoal);
              return {
                ...g,
                'current': clamped,
                'total': prayerGoal,
                'progress': (clamped / prayerGoal).clamp(0.0, 1.0),
              };
            case 'goal_dhikr':
              final clamped = dhikrCount.clamp(0, dhikrGoal);
              return {
                ...g,
                'current': clamped,
                'total': dhikrGoal,
                'progress': (clamped / dhikrGoal).clamp(0.0, 1.0),
              };
            default:
              return Map<String, dynamic>.from(g);
          }
        })
        .where((g) => savedTitles.contains(g['title']))
        .toList();

    // Fall back to first goal so PageView is never empty
    final goals = matched.isNotEmpty
        ? matched
        : [
            {
              ..._goalCatalog.first,
              'current': readingMinutes.clamp(0, readingGoalMinutes),
              'total': readingGoalMinutes,
              'progress':
                  (readingMinutes.clamp(0, readingGoalMinutes) /
                          readingGoalMinutes)
                      .clamp(0.0, 1.0),
            },
          ];
    if (mounted) {
      setState(() {
        _activeGoals = goals;
        // Reset page if out of range
        if (_currentPage >= _activeGoals.length) _currentPage = 0;
      });
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (_activeGoals.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _activeGoals.length) {
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
  @override
  void dispose() {
    _refreshTimer?.cancel();
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showAddGoalsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddGoalBottomSheet(),
    ).then((_) => _loadGoals());
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
                "my_goals".tr,
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
                    "set_goal".tr,
                    style: TextStyle(fontSize: 12.sp, color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 100.h,
          child: _activeGoals.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _activeGoals.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    final goal = _activeGoals[index];
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
                                  goal['title'].toString().tr,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "${goal['current']} / ${goal['total']} ${goal['unit'].toString().tr}",
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
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
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
                              children: List.generate(_activeGoals.length, (
                                index,
                              ) {
                                return Container(
                                  width: 8.w,
                                  height: 8.w,
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? const Color(0xFF2E7D32)
                                        : const Color.fromARGB(
                                            181,
                                            217,
                                            217,
                                            217,
                                          ),
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
