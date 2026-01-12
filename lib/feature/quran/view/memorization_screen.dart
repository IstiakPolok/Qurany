import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/const/app_colors.dart';

class MemorizationController extends GetxController {
  // Mock Data
  final versesLearned = 45.obs;
  final avgAccuracy = 94.obs;

  // State 0: Dashboard, 1: Selection, 2: Practice Session
  final currentStep = 0.obs;

  final expandedSurahIndex = (-1).obs; // -1 means none expanded

  final progressList = [
    {
      "surah": "Al-Fatihah",
      "verses": "0/7 Aya",
      "progress": 0.95,
      "color": primaryColor,
    },
    {
      "surah": "Al-Baqarah",
      "verses": "200/286 Aya",
      "progress": 0.80,
      "color": primaryColor,
    },
    {
      "surah": "Al-Ikhlas",
      "verses": "4/4 Aya",
      "progress": 1.0,
      "color": primaryColor,
    },
    {
      "surah": "Al-An'am",
      "verses": "0/30 Aya",
      "progress": 0.0,
      "color": primaryColor,
    },
  ].obs;

  // Mock Surah Data for Selection
  final surahList = [
    {
      "id": 1,
      "name": "Al - Fatiah",
      "arabicName": "الفاتحة",
      "origin": "MECCA",
      "versesCount": "7 VERSES",
      "progress": "0 / 7 Aya",
      "verses": 7,
      "completed": true,
    },
    {
      "id": 2,
      "name": "Al-Baqarah",
      "arabicName": "البقرة",
      "origin": "MEDINIAN",
      "versesCount": "286 VERSES",
      "progress": "0 / 286 Aya",
      "verses": 20, // Mocking fewer verses for grid
      "completed": false,
    },
    {
      "id": 3,
      "name": "Al 'Imran",
      "arabicName": "آل عمران",
      "origin": "MEDINIAN",
      "versesCount": "200 VERSES",
      "progress": "0 / 200 Aya",
      "verses": 200,
      "completed": false,
    },
    {
      "id": 4,
      "name": "An-Nisa",
      "arabicName": "النساء",
      "origin": "MEDINIAN",
      "versesCount": "176 VERSES",
      "progress": "0 / 176 Aya",
      "verses": 176,
      "completed": false,
    },
    {
      "id": 5,
      "name": "Al-Ma'idah",
      "arabicName": "المائدة",
      "origin": "MEDINIAN",
      "versesCount": "120 VERSES",
      "progress": "0 / 120 Aya",
      "verses": 120,
      "completed": false,
    },
    {
      "id": 6,
      "name": "Al-An'am",
      "arabicName": "الأنعام",
      "origin": "MECCA",
      "versesCount": "165 VERSES",
      "progress": "0 / 165 Aya",
      "verses": 165,
      "completed": false,
    },
  ];

  // Practice Session Data
  final currentPracticeVerse = "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ".obs;
  final currentPracticeTranslation =
      "Alhamdu lillaahi Rabbil 'aalameen\n\nAll praise is due to Allah, the Lord of all the worlds."
          .obs;
  final repeatCount = 3.obs;

  void goToSelection() {
    currentStep.value = 1;
  }

  void startPracticeSession(int surahId, int verseId) {
    // Logic to load verse data would go here
    currentStep.value = 2;
  }

  void backToDashboard() {
    currentStep.value = 0;
  }

  void backToSelection() {
    currentStep.value = 1;
  }

  void toggleSurahExpansion(int index) {
    if (expandedSurahIndex.value == index) {
      expandedSurahIndex.value = -1;
    } else {
      expandedSurahIndex.value = index;
    }
  }

  void setRepeatCount(int count) {
    repeatCount.value = count;
  }

  void startRecording() {
    // Show results dialog mockup
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 24.sp, color: Colors.grey),
                ),
              ),
              Text(
                "Recitation Results",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24.h),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100.w,
                    height: 100.w,
                    child: CircularProgressIndicator(
                      value: 0.94,
                      strokeWidth: 8,
                      color: primaryColor,
                      backgroundColor: bgColor,
                    ),
                  ),
                  Text(
                    "94%",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                "Excellent Progress!",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Keep practicing to improve your accuracy",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        "Try Again",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // Logic for next verse
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text(
                        "Next Verse",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MemorizationScreen extends StatelessWidget {
  const MemorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MemorizationController controller = Get.put(MemorizationController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.currentStep.value == 0) {
            return _buildDashboard(context, controller);
          } else if (controller.currentStep.value == 1) {
            return _buildSelectionScreen(context, controller);
          } else {
            return _buildPracticeSession(context, controller);
          }
        }),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    MemorizationController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          _buildHeader(context, "Memorization"),
          SizedBox(height: 24.h),
          _buildStatsCards(controller),
          SizedBox(height: 24.h),
          _buildStartPracticeButton(controller),
          SizedBox(height: 32.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Your Progress",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(child: _buildProgressList(controller)),
        ],
      ),
    );
  }

  Widget _buildSelectionScreen(
    BuildContext context,
    MemorizationController controller,
  ) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _buildHeader(
            context,
            "Practice Session",
            isPractice: true,
            onBack: controller.backToDashboard,
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: controller.surahList.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              final surah = controller.surahList[index];
              return Obx(
                () => _buildExpandableSurahCard(controller, surah, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSurahCard(
    MemorizationController controller,
    Map<String, dynamic> surah,
    int index,
  ) {
    final isExpanded = controller.expandedSurahIndex.value == index;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => controller.toggleSurahExpansion(index),
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    // Simple shape or image for star badge
                    color: Colors.white,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Star Icon Mockup
                      Icon(
                        Icons.star_border_purple500_outlined,
                        size: 44.sp,
                        color: primaryColor,
                      ),
                      Text(
                        "${surah['id']}",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            surah['name'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            surah['arabicName'],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Amiri",
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            surah['origin'],
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: subheading,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            surah['versesCount'],
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: subheading,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "✓ ${surah['progress']}",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: subheading,
                  size: 24.sp,
                ),
              ],
            ),
          ),

          if (isExpanded) ...[
            SizedBox(height: 16.h),
            Divider(color: Colors.grey.withOpacity(0.1)),
            SizedBox(height: 16.h),
            _buildVerseGrid(controller, surah['id'], surah['verses']),
          ],
        ],
      ),
    );
  }

  Widget _buildVerseGrid(
    MemorizationController controller,
    int surahId,
    int totalVerses,
  ) {
    // Determine how many verses to show (limiting for UI demo)
    int displayLimit = 15;

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      alignment: WrapAlignment.start,
      children: List.generate(
        totalVerses > displayLimit ? displayLimit : totalVerses,
        (index) {
          final verseNum = index + 1;
          final isSelected = verseNum == 5; // Mock selection

          return GestureDetector(
            onTap: () => controller.startPracticeSession(surahId, verseNum),
            child: Container(
              width: 50.w,
              height: 50.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : bgColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.r),
                // Could use a custom clipper for hexagon shape if strict adherence is needed
              ),
              child: Text(
                "$verseNum",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPracticeSession(
    BuildContext context,
    MemorizationController controller,
  ) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _buildHeader(
            context,
            "Practice Session",
            isPractice: true,
            onBack: controller.backToSelection,
          ),
        ),
        SizedBox(height: 24.h),

        // Verse Card
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.access_time,
                    size: 20.sp,
                    color: subheading,
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  controller.currentPracticeVerse.value,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontFamily: "Amiri",
                    fontWeight: FontWeight.bold,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                Text(
                  controller.currentPracticeTranslation.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                Spacer(),

                // Player Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back_ios, size: 18.sp, color: Colors.grey),
                    SizedBox(width: 24.w),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18.sp,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Repeat Count
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  "Repeat Count",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Spacer(),
              _buildRepeatToggle(controller, 1),
              _buildRepeatToggle(controller, 3),
              _buildRepeatToggle(controller, 5),
              _buildRepeatToggle(controller, 7),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        // AI Voice Recognition
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.mic_none, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "AI Voice Recognition",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                "Tap the button and recite the verse to check your accuracy.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 24.h),

              GestureDetector(
                onTap: controller.startRecording,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic, color: Colors.black87, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        "Start Recording",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildRepeatToggle(MemorizationController controller, int count) {
    return GestureDetector(
      onTap: () => controller.setRepeatCount(count),
      child: Obx(
        () => Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: controller.repeatCount.value == count
                ? primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            "${count}x",
            style: TextStyle(
              color: controller.repeatCount.value == count
                  ? Colors.white
                  : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String title, {
    bool isPractice = false,
    VoidCallback? onBack,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onBack ?? () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 16.sp,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        isPractice
            ? SizedBox(width: 40.w)
            : // Placeholder for centering
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.chat_bubble_outline,
                  size: 20.sp,
                  color: Colors.black87,
                ),
              ),
      ],
    );
  }

  Widget _buildStatsCards(MemorizationController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "Verses Learned",
            value: "${controller.versesLearned.value}",
            icon: Icons.check_circle_outline,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildStatCard(
            title: "Avg Accuracy",
            value: "${controller.avgAccuracy.value}%",
            icon: Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color.fromARGB(34, 47, 125, 51), // Light green background
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: subheading),
          ),
        ],
      ),
    );
  }

  Widget _buildStartPracticeButton(MemorizationController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.goToSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, color: Colors.white, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              "Start New Practice Session",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressList(MemorizationController controller) {
    return Obx(
      () => ListView.separated(
        itemCount: controller.progressList.length,
        separatorBuilder: (context, index) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final item = controller.progressList[index];
          return _buildProgressItem(item);
        },
      ),
    );
  }

  Widget _buildProgressItem(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.menu_book, color: primaryColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["surah"],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item["verses"],
                  style: TextStyle(fontSize: 12.sp, color: subheading),
                ),
                SizedBox(height: 12.h),
                // Custom Button/Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Circular Progress
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50.w,
                height: 50.w,
                child: CircularProgressIndicator(
                  value: item["progress"],
                  backgroundColor: bgColor,
                  color: primaryColor,
                  strokeWidth: 5,
                ),
              ),
              Text(
                "${(item["progress"] * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
