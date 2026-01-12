import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:qurany/feature/home/widgets/home_header.dart';
import 'package:qurany/feature/home/widgets/weekly_streak_row.dart';
import 'package:qurany/feature/home/widgets/recent_reading_list.dart';
import 'package:qurany/feature/home/widgets/verse_of_day_card.dart';
import 'package:qurany/feature/home/widgets/feeling_widget.dart';
import 'package:qurany/feature/home/widgets/daily_goals_card.dart';
import 'package:qurany/feature/home/widgets/horizontal_sections.dart';
import 'package:qurany/feature/home/widgets/quran_tab_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Cream background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            const HomeHeader(),

            // Weekly Streak
            const WeeklyStreakRow(),

            // Recent Reading Cards
            const RecentReadingList(),

            // Verse of the Day
            const VerseOfDayCard(),

            const SizedBox(height: 16),

            // Personalized Recommendation
            const FeelingWidget(),

            // My Goals
            const DailyGoalsCard(),

            const SizedBox(height: 16),

            // Did You Know
            const DidYouKnowSection(),
            const SizedBox(height: 24),

            // Reciters
            const RecitersSection(),

            const SizedBox(height: 24),

            // Stories
            const StoriesSection(),
            const SizedBox(height: 24),

            // Azkar
            const AzkarSection(),
            const SizedBox(height: 24),

            // Quran Tabs & List
            const QuranTabSection(),

            // Extra padding for bottom nav bar
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
