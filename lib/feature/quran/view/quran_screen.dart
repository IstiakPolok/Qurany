import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Sample Surah data
class SurahModel {
  final int number;
  final String name;
  final String arabicName;
  final String origin;
  final int verseCount;
  final int totalAya;
  final bool isFavorite;

  SurahModel({
    required this.number,
    required this.name,
    required this.arabicName,
    required this.origin,
    required this.verseCount,
    required this.totalAya,
    this.isFavorite = false,
  });
}

// Sample Juz data
class JuzModel {
  final int juzNumber;
  final List<JuzSurah> surahs;

  JuzModel({required this.juzNumber, required this.surahs});
}

class JuzSurah {
  final int surahNumber;
  final String name;
  final String arabicName;
  final String origin;
  final int totalAya;
  final String verseRange;

  JuzSurah({
    required this.surahNumber,
    required this.name,
    required this.arabicName,
    required this.origin,
    required this.totalAya,
    required this.verseRange,
  });
}

// Sample Favorite Ayah
class FavoriteAyah {
  final String surahName;
  final int verseNumber;
  final String arabicText;
  final String translation;
  final String savedDate;

  FavoriteAyah({
    required this.surahName,
    required this.verseNumber,
    required this.arabicText,
    required this.translation,
    required this.savedDate,
  });
}

// Controller
class QuranController extends GetxController {
  RxInt selectedTab = 0.obs;
  RxString searchQuery = ''.obs;

  // Sample data
  final List<SurahModel> surahs = [
    SurahModel(
      number: 1,
      name: "Al-Fatiah",
      arabicName: "الفاتحة",
      origin: "MECCAN",
      verseCount: 7,
      totalAya: 7,
    ),
    SurahModel(
      number: 2,
      name: "Al-Baqarah",
      arabicName: "البقرة",
      origin: "MEDINIAN",
      verseCount: 286,
      totalAya: 286,
    ),
    SurahModel(
      number: 3,
      name: "Al 'Imran",
      arabicName: "آل عمران",
      origin: "MEDINIAN",
      verseCount: 200,
      totalAya: 200,
    ),
    SurahModel(
      number: 4,
      name: "An-Nisa",
      arabicName: "النساء",
      origin: "MEDINIAN",
      verseCount: 176,
      totalAya: 176,
    ),
    SurahModel(
      number: 5,
      name: "Al-Ma'idah",
      arabicName: "المائدة",
      origin: "MEDINIAN",
      verseCount: 120,
      totalAya: 120,
    ),
    SurahModel(
      number: 6,
      name: "Al-An'am",
      arabicName: "الأنعام",
      origin: "MECCAN",
      verseCount: 165,
      totalAya: 165,
    ),
    SurahModel(
      number: 7,
      name: "Al-A'raf",
      arabicName: "الأعراف",
      origin: "MECCAN",
      verseCount: 206,
      totalAya: 206,
    ),
    SurahModel(
      number: 8,
      name: "Al-Anfaal",
      arabicName: "الأنفال",
      origin: "MECCAN",
      verseCount: 75,
      totalAya: 75,
    ),
    SurahModel(
      number: 9,
      name: "At-Tawba",
      arabicName: "التوبه",
      origin: "MECCAN",
      verseCount: 129,
      totalAya: 129,
    ),
    SurahModel(
      number: 10,
      name: "Yunus",
      arabicName: "يونس",
      origin: "MECCAN",
      verseCount: 109,
      totalAya: 109,
    ),
  ];

  final List<JuzModel> juzList = [
    JuzModel(
      juzNumber: 1,
      surahs: [
        JuzSurah(
          surahNumber: 1,
          name: "Al-Fatiah",
          arabicName: "الفاتحة",
          origin: "MECCAN",
          totalAya: 7,
          verseRange: "7 VERSES",
        ),
        JuzSurah(
          surahNumber: 2,
          name: "Al-Baqarah",
          arabicName: "البقرة",
          origin: "MEDINIAN",
          totalAya: 286,
          verseRange: "1 - 141 VERSES",
        ),
      ],
    ),
    JuzModel(
      juzNumber: 2,
      surahs: [
        JuzSurah(
          surahNumber: 2,
          name: "Al-Baqarah",
          arabicName: "البقرة",
          origin: "MEDINIAN",
          totalAya: 286,
          verseRange: "142 - 252 VERSES",
        ),
      ],
    ),
    JuzModel(
      juzNumber: 3,
      surahs: [
        JuzSurah(
          surahNumber: 2,
          name: "Al-Baqarah",
          arabicName: "البقرة",
          origin: "MEDINIAN",
          totalAya: 286,
          verseRange: "253 - 286 VERSES",
        ),
        JuzSurah(
          surahNumber: 3,
          name: "Al 'Imran",
          arabicName: "آل عمران",
          origin: "MEDINIAN",
          totalAya: 200,
          verseRange: "1 - 92 VERSES",
        ),
      ],
    ),
    JuzModel(
      juzNumber: 4,
      surahs: [
        JuzSurah(
          surahNumber: 3,
          name: "Al 'Imran",
          arabicName: "آل عمران",
          origin: "MEDINIAN",
          totalAya: 200,
          verseRange: "93 - 200 VERSES",
        ),
        JuzSurah(
          surahNumber: 4,
          name: "An-Nisa",
          arabicName: "النساء",
          origin: "MEDINIAN",
          totalAya: 176,
          verseRange: "1 - 23 VERSES",
        ),
      ],
    ),
  ];

  final List<FavoriteAyah> favoriteAyahs = [
    FavoriteAyah(
      surahName: "Al-Fatiha",
      verseNumber: 255,
      arabicText: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
      translation:
          "In the Name of Allah—the Most Compassionate, Most Merciful.",
      savedDate: "Saved 2 days ago",
    ),
    FavoriteAyah(
      surahName: "Al-Imran",
      verseNumber: 19,
      arabicText: "إِنَّ الدِّينَ عِندَ اللَّهِ الْإِسْلَامُ",
      translation: "Indeed, the religion in the sight of Allah is Islam.",
      savedDate: "Saved 2 days ago",
    ),
    FavoriteAyah(
      surahName: "An-Nisa",
      verseNumber: 36,
      arabicText: "وَاعْبُدُوا اللَّهَ وَلَا تُشْرِكُوا بِهِ شَيْئًا",
      translation: "And worship Allah and do not associate anything with Him.",
      savedDate: "Saved 3 days ago",
    ),
  ];
}

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuranController controller = Get.put(QuranController());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background image - extends from top to half of Last Read card
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 280.h, // Covers header + half of Last Read card
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/image/quarnBG.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 60.h),
                  _buildLastReadCard(),

                  SizedBox(height: 16.h),

                  // Mode buttons
                  _buildModeButtons(),

                  SizedBox(height: 24.h),

                  // Quran section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      "Quran",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Search bar
                  _buildSearchBar(),

                  SizedBox(height: 16.h),

                  // Tab bar
                  _buildTabBar(controller),

                  SizedBox(height: 16.h),

                  // Content based on selected tab
                  Obx(() {
                    switch (controller.selectedTab.value) {
                      case 0:
                        return _buildSurahList(controller);
                      case 1:
                        return _buildJuzList(controller);
                      case 2:
                        return _buildFavoritesList(controller);
                      default:
                        return _buildSurahList(controller);
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: 50.h,
        left: 16.w,
        right: 16.w,
        bottom: 16.h,
      ),
      // Transparent - background image shows through
      child: Column(
        children: [
          // Location row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      "Abu Dhabi, Dubai",
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Date
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chevron_left, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "Today, 3 December",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.chevron_right, color: Colors.white, size: 20.sp),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                "20 Rabi' al-Awal 1446",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLastReadCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Last Read",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 16.sp,
                      color: const Color(0xFF2E7D32),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Al-Faatiha : 1 - 3",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Progress circle
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: 0.05,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2E7D32)),
                ),
                Center(
                  child: Text(
                    "5%",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildModeButton(Icons.menu_book_outlined, "Read Mode", true),
          _buildModeButton(Icons.headphones_outlined, "Commuter", false),
          _buildModeButton(Icons.psychology_outlined, "Memorization", false),
        ],
      ),
    );
  }

  Widget _buildModeButton(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F5E9) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16.r),
            border: isSelected
                ? Border.all(color: const Color(0xFF2E7D32), width: 2)
                : null,
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
            size: 24.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Search",
                style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
              ),
            ),
            Icon(Icons.search, color: Colors.grey[500], size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(QuranController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Row(
          children: [
            _buildTabButton("Surah", 0, controller),
            SizedBox(width: 8.w),
            _buildTabButton("Juz", 1, controller),
            SizedBox(width: 8.w),
            _buildTabButton("Favorites", 2, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, QuranController controller) {
    final isSelected = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.selectedTab.value = index,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList(QuranController controller) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: controller.surahs.length,
      itemBuilder: (context, index) {
        final surah = controller.surahs[index];
        return _buildSurahItem(surah, context);
      },
    );
  }

  Widget _buildSurahItem(SurahModel surah, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Surah number in hexagon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                surah.number.toString(),
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Surah info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      surah.origin,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.check_circle,
                      size: 12.sp,
                      color: const Color(0xFF2E7D32),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "0 / ${surah.totalAya} Aya",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Arabic name and verse count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                surah.arabicName,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Amiri',
                ),
              ),
              Text(
                "${surah.verseCount} VERSES",
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          // Menu button
          GestureDetector(
            onTap: () => _showSurahMenu(context, surah),
            child: Icon(Icons.more_vert, size: 20.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showSurahMenu(BuildContext context, SurahModel surah) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.bookmark_border,
                color: const Color(0xFF2E7D32),
              ),
              title: const Text("Favorite"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.share_outlined, color: Colors.grey[600]),
              title: const Text("Share"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.grey[600]),
              title: const Text("Info"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJuzList(QuranController controller) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: controller.juzList.length,
      itemBuilder: (context, index) {
        final juz = controller.juzList[index];
        return _buildJuzItem(juz);
      },
    );
  }

  Widget _buildJuzItem(JuzModel juz) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Juz header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Juz ${juz.juzNumber}",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                "Read Juz",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Surahs in this juz
          ...juz.surahs.map((surah) => _buildJuzSurahItem(surah)),
        ],
      ),
    );
  }

  Widget _buildJuzSurahItem(JuzSurah surah) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: Text(
                surah.surahNumber.toString(),
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      surah.origin,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.check_circle,
                      size: 10.sp,
                      color: const Color(0xFF2E7D32),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "0 / ${surah.totalAya} Aya",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                surah.arabicName,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                surah.verseRange,
                style: TextStyle(fontSize: 9.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(QuranController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Favorite Ayah",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          // Favorite ayahs
          ...controller.favoriteAyahs.map(
            (ayah) => _buildFavoriteAyahItem(ayah),
          ),

          SizedBox(height: 24.h),

          Text(
            "Favorite Surah",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          // Favorite surahs (first 3)
          ...controller.surahs
              .take(3)
              .map((surah) => _buildFavoriteSurahItem(surah)),
        ],
      ),
    );
  }

  Widget _buildFavoriteAyahItem(FavoriteAyah ayah) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${ayah.surahName} • Verse ${ayah.verseNumber}",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    ayah.savedDate,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
              Icon(Icons.bookmark, color: const Color(0xFF2E7D32), size: 20.sp),
            ],
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              ayah.arabicText,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'Amiri',
                height: 1.8,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            ayah.translation,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteSurahItem(SurahModel surah) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                surah.number.toString(),
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      surah.origin,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.check_circle,
                      size: 10.sp,
                      color: const Color(0xFF2E7D32),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "0 / ${surah.totalAya} Aya",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                surah.arabicName,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                "${surah.verseCount} VERSES",
                style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          Icon(Icons.bookmark, color: const Color(0xFF2E7D32), size: 18.sp),
        ],
      ),
    );
  }
}
