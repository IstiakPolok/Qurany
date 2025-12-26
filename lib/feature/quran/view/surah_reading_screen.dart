import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/const/app_colors.dart';

// Verse model
class VerseModel {
  final int verseNumber;
  final String arabicText;
  final String translation;
  final bool isBookmarked;

  VerseModel({
    required this.verseNumber,
    required this.arabicText,
    required this.translation,
    this.isBookmarked = false,
  });
}

// Controller
class SurahReadingController extends GetxController {
  RxInt selectedViewTab =
      0.obs; // 0 = Translation, 1 = Transliteration, 2 = Tafsir
  RxBool isPlaying = false.obs;
  RxInt currentPlayingVerse = (-1).obs;
  RxDouble playbackSpeed = 1.0.obs;

  // Sample verses for Al-Fatihah
  final List<VerseModel> verses = [
    VerseModel(
      verseNumber: 1,
      arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
      translation:
          "In the Name of Allah—the Most Compassionate, Most Merciful.",
    ),
    VerseModel(
      verseNumber: 2,
      arabicText: "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ",
      translation: "All praise is due to Allah, the Lord of all the worlds.",
    ),
    VerseModel(
      verseNumber: 3,
      arabicText: "ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
      translation: "The Most Compassionate, Most Merciful.",
    ),
    VerseModel(
      verseNumber: 4,
      arabicText: "مَٰلِكِ يَوْمِ ٱلدِّينِ",
      translation: "Master of the Day of Judgment.",
    ),
    VerseModel(
      verseNumber: 5,
      arabicText: "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
      translation: "You alone we worship, and You alone we ask for help.",
    ),
    VerseModel(
      verseNumber: 6,
      arabicText: "ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ",
      translation: "Guide us on the Straight Path.",
    ),
    VerseModel(
      verseNumber: 7,
      arabicText:
          "صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ",
      translation:
          "The path of those who have received Your grace; not the path of those who have brought down wrath upon themselves, nor of those who have gone astray.",
    ),
  ];

  void togglePlayPause() {
    isPlaying.value = !isPlaying.value;
  }

  void playVerse(int verseNumber) {
    currentPlayingVerse.value = verseNumber;
    isPlaying.value = true;
  }
}

class SurahReadingScreen extends StatelessWidget {
  final String surahName;
  final String arabicName;
  final String meaning;
  final String origin;
  final int ayaCount;

  const SurahReadingScreen({
    super.key,
    this.surahName = "Al-Faatiha",
    this.arabicName = "الفاتحة",
    this.meaning = "Al-Faatiha",
    this.origin = "MECCAN",
    this.ayaCount = 7,
  });

  @override
  Widget build(BuildContext context) {
    final SurahReadingController controller = Get.put(SurahReadingController());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: Stack(
        children: [
          Column(
            children: [
              // App Bar
              _buildAppBar(context),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Surah Header Card
                      _buildSurahHeader(),

                      SizedBox(height: 16.h),

                      // View tabs (Translation, Transliteration, Tafsir)
                      _buildViewTabs(controller),

                      SizedBox(height: 16.h),

                      // Verses list
                      _buildVersesList(controller),

                      // Bottom padding for audio player
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Audio Player
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildAudioPlayer(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 16.w,
        right: 16.w,
        bottom: 12.h,
      ),
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
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),

          // Surah name dropdown
          GestureDetector(
            onTap: () => _showSurahSelector(context),
            child: Row(
              children: [
                Text(
                  surahName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.keyboard_arrow_up, size: 20.sp),
              ],
            ),
          ),

          // Info button
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(Icons.info_outline, size: 18.sp, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _showSurahSelector(BuildContext context) {
    final List<Map<String, dynamic>> surahs = [
      {"number": 1, "name": "Al-Fatiah"},
      {"number": 2, "name": "Al-Baqarah"},
      {"number": 3, "name": "Aali Imran"},
      {"number": 4, "name": "An-Nisa"},
      {"number": 5, "name": "Al-Ma'idah"},
      {"number": 6, "name": "Al-An'am"},
      {"number": 7, "name": "Al-A'raf"},
      {"number": 8, "name": "Al-Anfal"},
      {"number": 9, "name": "At-Tawbah"},
      {"number": 10, "name": "Yunus"},
      {"number": 11, "name": "Hud"},
      {"number": 12, "name": "Yusuf"},
      {"number": 13, "name": "Ar-Ra'd"},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Search",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.grey[500], size: 20.sp),
                  ],
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // Surah list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _showSurahInfoSheet(context, surah);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Surah number in hexagon
                          ClipPath(
                            clipper: HexagonClipper(),
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              color: const Color(0xFF2E7D32),
                              child: Center(
                                child: Text(
                                  surah["number"].toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          // Surah name
                          Text(
                            surah["name"],
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSurahInfoSheet(BuildContext context, Map<String, dynamic> surah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Surah name and Arabic name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          surah["name"].toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "الفاتحة",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontFamily: 'Amiri',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Info row
                    Row(
                      children: [
                        _buildInfoColumn("Meaning", "The opener"),
                        SizedBox(width: 40.w),
                        _buildInfoColumn("Revelation Place", "Meccan"),
                        SizedBox(width: 40.w),
                        _buildInfoColumn("Ayahs", "7 Aya"),
                      ],
                    ),

                    SizedBox(height: 24.h),
                    Divider(color: Colors.grey[200]),
                    SizedBox(height: 16.h),

                    // Description
                    Text(
                      "This Surah is named Al-Fatihah because of its subject matter. Fatihah is that which opens a subject or a book or any other thing. In other words, Al-Fatihah is a sort of preface.",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Period of Revelation
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Period of Revelation",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "Surah Al-Fatihah is one of the very earliest Revelations to the Holy Prophet. As a matter of fact, we learn from authentic traditions that it was the first complete Surah that was revealed to Muhammad (Allah's peace be upon him). Before this, only a few miscellaneous verses were revealed which form parts of Alaq, Muzzammil, Muddaththir, etc.",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Theme
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Theme",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "This Surah is in fact a prayer that Allah has taught to all those who want to make a study of His book. It has been placed at the very beginning of the Quran to teach this lesson to the reader: if you sincerely want to benefit from the Quran, you should offer this prayer to the Lord of the Universe.\n\nThis preface is meant to create a strong desire in the heart of the reader to seek guidance from the Lord of the Universe Who alone can grant it. Thus Al-Fatihah indirectly teaches that the best thing for a man is to pray for guidance to the straight path, to study the Quran with the mental attitude of a seeker searching for the truth, and to recognize the fact that the Lord of the Universe is the source of all knowledge.",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey[700],
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSurahHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: AssetImage('assets/image/readmodecardBG.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            meaning,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "THE OPENER",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              _buildDot(),
              Text(
                origin,
                style: TextStyle(fontSize: 11.sp, color: Colors.black),
              ),
              _buildDot(),
              Text(
                "$ayaCount Aya",
                style: TextStyle(fontSize: 11.sp, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Bismillah
          Text(
            "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
            style: TextStyle(
              fontSize: 28.sp,
              color: primaryColor,
              fontFamily: 'Amiri',
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Container(
        width: 4.w,
        height: 4.w,
        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildViewTabs(SurahReadingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Row(
          children: [
            _buildViewTab("Translation", 0, controller),
            SizedBox(width: 12.w),
            _buildViewTab("Transliteration", 1, controller),
            SizedBox(width: 12.w),
            _buildViewTab("Tafsir", 2, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildViewTab(
    String label,
    int index,
    SurahReadingController controller,
  ) {
    final isSelected = controller.selectedViewTab.value == index;
    return GestureDetector(
      onTap: () => controller.selectedViewTab.value = index,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildVersesList(SurahReadingController controller) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: controller.verses.length,
      itemBuilder: (context, index) {
        final verse = controller.verses[index];
        return _buildVerseCard(verse, controller);
      },
    );
  }

  Widget _buildVerseCard(VerseModel verse, SurahReadingController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Play button and Arabic text row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Play button
              GestureDetector(
                onTap: () => controller.playVerse(verse.verseNumber),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: const Color(0xFF2E7D32),
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Arabic text with verse number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            verse.arabicText,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontFamily: 'Amiri',
                              height: 1.8,
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // Verse number in hexagon
                        ClipPath(
                          clipper: HexagonClipper(),
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            color: const Color(0xFF2E7D32),
                            child: Center(
                              child: Text(
                                verse.verseNumber.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Translation
          Text(
            verse.translation,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          SizedBox(height: 12.h),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // More options
              Icon(Icons.more_horiz, color: Colors.grey[500], size: 20.sp),
              Row(
                children: [
                  Image.asset(
                    'assets/icons/1.solar_notes-outline.png',
                    width: 18.sp,
                    height: 18.sp,
                  ),
                  SizedBox(width: 16.w),
                  Image.asset(
                    'assets/icons/2.solar_document-add-broken.png',
                    width: 18.sp,
                    height: 18.sp,
                  ),
                  SizedBox(width: 16.w),
                  Image.asset(
                    'assets/icons/3.iconoir_double-check.png',
                    width: 18.sp,
                    height: 18.sp,
                  ),
                  SizedBox(width: 16.w),
                  Image.asset(
                    'assets/icons/4.material-symbols_bookmark-outline-rounded.png',
                    width: 18.sp,
                    height: 18.sp,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(SurahReadingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Speed button
            Obx(
              () => Text(
                "${controller.playbackSpeed.value}x",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Playback controls
            Row(
              children: [
                Icon(Icons.skip_previous, color: Colors.grey[700], size: 28.sp),
                SizedBox(width: 16.w),
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.togglePlayPause(),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.skip_next, color: Colors.grey[700], size: 28.sp),
              ],
            ),

            // More options
            Icon(Icons.more_horiz, color: Colors.grey[600], size: 24.sp),
          ],
        ),
      ),
    );
  }
}

// Hexagon clipper
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
