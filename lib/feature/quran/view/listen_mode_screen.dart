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
    // Show available commands
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available Commands:",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, color: Colors.grey, size: 24.sp),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildCommandItem("Next", "Skip To Next Verse"),
            _buildCommandItem("Previous", "To Go Back"),
            _buildCommandItem("Pause", "To Stop Playback"),
            _buildCommandItem("Play", "To Resume"),
            _buildCommandItem("Repeat", "To Replay Current Verse"),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandItem(String command, String action) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          text: "- Say \"$command\" ",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: action,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
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
      backgroundColor: listenModeBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: listenModeBackground,
          image: DecorationImage(
            image: const AssetImage('assets/image/quarnBG.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              listenModeBackground.withOpacity(0.9),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button and title, and safety banner
              _buildTopSection(context),

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

              SizedBox(height: 32.h),

              // Player Controls
              _buildPlayerControls(controller),

              SizedBox(height: 48.h),

              // Voice Command Button
              _buildVoiceCommandButton(controller),

              SizedBox(height: 10.h),

              GestureDetector(
                onTap: () => controller.showVoiceCommand(),
                child: Text(
                  "Show Voice Command",
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'Commuter Mode',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              // Dummy icon for symmetry or actual notification
              Icon(Icons.more_horiz, color: Colors.transparent),
            ],
          ),
        ),
        // Safety Banner if needed, usually shown as a toast or top banner.
        // Based on UI provided design, it might not be permanent.
        // But requested to "Update Commuter Mode UI" so I will keep the important parts.
        // If specific design has orange banner:
        // _buildSafetyBanner(),
      ],
    );
  }

  Widget _buildSurahInfo(ListenModeController controller) {
    return Obx(
      () => Column(
        children: [
          Text(
            controller.currentSurahName.value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${controller.currentVerseIndex.value + 1}/${controller.totalVerses.value} Aya',
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
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
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          children: [
            // Verse end symbol
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryColor),
                ),
                child: Icon(
                  Icons.mosque,
                  size: 14.sp,
                  color: primaryColor,
                ), // Placeholder for ayah end symbol
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),
                    // Arabic text
                    Text(
                      verse['arabic'] ?? '',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontFamily: 'Amiri',
                        height: 1.8,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),

                    // Transliteration
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        verse['transliteration'] ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: listenModeAccent,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Translation
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        verse['translation'] ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPlayerControls(ListenModeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 60.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          GestureDetector(
            onTap: () => controller.previousVerse(),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),

          // Play/Pause button
          Obx(
            () => GestureDetector(
              onTap: () => controller.togglePlayPause(),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Icon(
                  controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                  color: primaryColor,
                  size: 32.sp,
                ),
              ),
            ),
          ),

          // Next button
          GestureDetector(
            onTap: () => controller.nextVerse(),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: Icon(Icons.skip_next, color: Colors.white, size: 24.sp),
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
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic_none, color: Colors.black87, size: 20.sp),
            SizedBox(width: 8.w),
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
