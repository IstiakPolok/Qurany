import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/const/app_colors.dart';

/// Controller for Listen Mode (Commuter Mode) screen
class ListenModeController extends GetxController {
  RxInt currentVerseIndex = 0.obs;
  RxBool isPlaying = false.obs;
  RxString currentSurahName = 'AL-FATIHAH'.obs;
  RxInt totalVerses = 7.obs;

  // Sample verse data for Al-Fatihah
  final List<Map<String, String>> verses = [
    {
      'arabic': 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      'transliteration': 'Bismillahir Rahmanir Raheem',
      'translation':
          'In the Name of Allah—the Most Compassionate, Most Merciful.',
    },
    {
      'arabic': 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
      'transliteration': 'Alhamdu lillaahi Rabbil \'aalameen',
      'translation': 'All praise is due to Allah, the Lord of all the worlds.',
    },
    {
      'arabic': 'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
      'transliteration': 'Ar-Rahmaanir-Raheem',
      'translation': 'The Most Compassionate, Most Merciful.',
    },
    {
      'arabic': 'مَٰلِكِ يَوْمِ ٱلدِّينِ',
      'transliteration': 'Maaliki Yawmid-Deen',
      'translation': 'Master of the Day of Judgment.',
    },
    {
      'arabic': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      'transliteration': 'Iyyaaka na\'budu wa lyyaaka nasta\'een',
      'translation': 'You alone we worship, and You alone we ask for help.',
    },
    {
      'arabic': 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
      'transliteration': 'Ihdinas-Siraatal-Mustaqeem',
      'translation': 'Guide us on the Straight Path.',
    },
    {
      'arabic':
          'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
      'transliteration':
          'Siraatal-lazeena an\'amta \'alaihim ghayril-maghdoobi \'alaihim wa lad-daaalleen',
      'translation':
          'The path of those who have received Your grace; not the path of those who have brought down wrath upon themselves, nor of those who have gone astray.',
    },
  ];

  Map<String, String> get currentVerse => verses[currentVerseIndex.value];

  void togglePlayPause() {
    isPlaying.value = !isPlaying.value;
  }

  void nextVerse() {
    if (currentVerseIndex.value < verses.length - 1) {
      currentVerseIndex.value++;
    }
  }

  void previousVerse() {
    if (currentVerseIndex.value > 0) {
      currentVerseIndex.value--;
    }
  }

  void showVoiceCommand() {
    // TODO: Implement voice command functionality
    Get.snackbar(
      'Voice Command',
      'Voice command feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black87,
    );
  }
}

/// Listen Mode (Commuter Mode) Screen
/// A simplified audio-focused interface for listening to Quran while commuting
class ListenModeScreen extends StatelessWidget {
  final String surahName;
  final String arabicName;

  const ListenModeScreen({
    super.key,
    this.surahName = 'Al-Fatihah',
    this.arabicName = 'الفاتحة',
  });

  @override
  Widget build(BuildContext context) {
    final ListenModeController controller = Get.put(ListenModeController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: listenModeBackground,
          image: DecorationImage(
            image: const AssetImage('assets/image/quarnBG.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              listenModeBackground.withOpacity(0.85),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Safe Driving Banner
              _buildSafetyBanner(),

              // Header with back button and title
              _buildHeader(context),

              // Surah name and progress
              _buildSurahInfo(controller),

              SizedBox(height: 24.h),

              // Verse Card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildVerseCard(controller),
                ),
              ),

              // Player Controls
              _buildPlayerControls(controller),

              SizedBox(height: 16.h),

              // Voice Command Button
              _buildVoiceCommandButton(controller),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: safetyBannerOrange,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Safe driving reminder: Use voice commands only.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18.sp,
                color: Colors.white,
              ),
            ),
          ),

          // Title
          Text(
            'Commuter Mode',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          // Placeholder for symmetry
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildSurahInfo(ListenModeController controller) {
    return Obx(
      () => Column(
        children: [
          Text(
            controller.currentSurahName.value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${controller.currentVerseIndex.value + 1}/${controller.totalVerses.value} Aya',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(ListenModeController controller) {
    return Obx(() {
      final verse = controller.currentVerse;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: listenModeCardBg,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Verse number badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Verse ${controller.currentVerseIndex.value + 1}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Arabic text
              Text(
                verse['arabic'] ?? '',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontFamily: 'Amiri',
                  height: 1.8,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.h),

              // Transliteration
              Text(
                verse['transliteration'] ?? '',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: listenModeAccent,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              // Translation
              Text(
                verse['translation'] ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPlayerControls(ListenModeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous button
          GestureDetector(
            onTap: () => controller.previousVerse(),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
          ),

          // Play/Pause button
          Obx(
            () => GestureDetector(
              onTap: () => controller.togglePlayPause(),
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  color: primaryColor,
                  size: 36.sp,
                ),
              ),
            ),
          ),

          // Next button
          GestureDetector(
            onTap: () => controller.nextVerse(),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(Icons.skip_next, color: Colors.white, size: 28.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceCommandButton(ListenModeController controller) {
    return GestureDetector(
      onTap: () => controller.showVoiceCommand(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40.w),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic, color: primaryColor, size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              'Tap for Voice Command',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
