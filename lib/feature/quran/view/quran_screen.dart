import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/const/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../home/model/surah_model.dart';
import '../../home/services/quran_service.dart';
import 'surah_reading_screen.dart';
import 'listen_mode_screen.dart';
import 'memorization_screen.dart';

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
  final QuranService _quranService = QuranService();
  final TextEditingController searchTextController = TextEditingController();
  RxInt selectedTab = 0.obs;
  RxInt selectedMode = 0.obs; // 0 = Read Mode, 1 = Commuter, 2 = Memorization
  RxString searchQuery = ''.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;

  // Data
  var surahs = <SurahModel>[].obs;
  var isLoading = true.obs;

  List<SurahModel> get filteredSurahs {
    if (searchQuery.value.isEmpty) {
      return surahs;
    }
    return surahs
        .where(
          (surah) =>
              surah.englishName.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              surah.arabicName.contains(searchQuery.value) ||
              surah.number.toString().contains(searchQuery.value),
        )
        .toList();
  }

  final List<JuzModel> juzList = JuzModel.sampleJuz;

  List<JuzModel> get filteredJuzList {
    if (searchQuery.value.isEmpty) {
      return juzList;
    }
    return juzList
        .where(
          (juz) =>
              juz.number.toString().contains(searchQuery.value) ||
              juz.surahs.any(
                (s) =>
                    s.englishName.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ||
                    s.arabicName.contains(searchQuery.value),
              ),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(() {
      searchQuery.value = searchTextController.text;
    });
    fetchSurahs();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> fetchSurahs() async {
    try {
      isLoading(true);
      final response = await _quranService.fetchSurahs(page: 1, limit: 114);
      surahs.assignAll(response.surahs);
    } catch (e) {
      print("Error fetching surahs: $e");
    } finally {
      isLoading(false);
    }
  }

  // Date navigation methods
  void changeDate(int offset) {
    selectedDate.value = selectedDate.value.add(Duration(days: offset));
  }

  String getFormattedGregorianDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );

    if (selected == today) {
      return "Today, ${DateFormat('d MMMM').format(selectedDate.value)}";
    } else if (selected == today.add(const Duration(days: 1))) {
      return "Tomorrow, ${DateFormat('d MMMM').format(selectedDate.value)}";
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return "Yesterday, ${DateFormat('d MMMM').format(selectedDate.value)}";
    } else {
      return DateFormat('EEEE, d MMMM').format(selectedDate.value);
    }
  }

  String getFormattedHijriDate() {
    final hDate = HijriCalendar.fromDate(selectedDate.value);
    return "${hDate.hDay} ${hDate.longMonthName} ${hDate.hYear}";
  }

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

  List<FavoriteAyah> get filteredFavoriteAyahs {
    if (searchQuery.value.isEmpty) {
      return favoriteAyahs;
    }
    return favoriteAyahs
        .where(
          (a) =>
              a.surahName.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              a.translation.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }
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
                  _buildHeader(controller),
                  SizedBox(height: 60.h),
                  _buildLastReadCard(context, controller),

                  SizedBox(height: 16.h),

                  // Mode buttons
                  _buildModeButtons(controller),

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
                  _buildSearchBar(controller),

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
                        return _buildFavoritesList(context, controller);
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

  Widget _buildHeader(QuranController controller) {
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
              GestureDetector(
                onTap: () {
                  // Refresh location when tapped
                  try {
                    LocationService.instance.refreshLocation();
                  } catch (e) {
                    print('LocationService not initialized: $e');
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 16.sp),
                      SizedBox(width: 4.w),
                      Obx(() {
                        try {
                          return Text(
                            LocationService.instance.currentLocation.value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          );
                        } catch (e) {
                          return Text(
                            "Location unavailable",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          );
                        }
                      }),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ],
                  ),
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
          Obx(
            () => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => controller.changeDate(-1),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      controller.getFormattedGregorianDate(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => controller.changeDate(1),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  controller.getFormattedHijriDate(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastReadCard(BuildContext context, QuranController controller) {
    // Progress value for last read (0.0 - 1.0)
    final double progress = 0.05;
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
                GestureDetector(
                  onTap: () {
                    // Navigate based on selected mode
                    if (controller.selectedMode.value == 1) {
                      // Commuter / Listen Mode
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListenModeScreen(),
                        ),
                      );
                    } else if (controller.selectedMode.value == 2) {
                      // Memorization Mode
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MemorizationScreen(),
                        ),
                      );
                    } else {
                      // Default to Read Mode (SurahReadingScreen)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SurahReadingScreen(
                            surahId: 1,
                            surahName: "Al-Faatiha",
                            arabicName: "الفاتحة",
                            meaning: "Al-Faatiha",
                            origin: "MECCAN",
                            ayaCount: 7,
                            translation: "The Opener",
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
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
                ),
              ],
            ),
          ),
          // Progress circle
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2E7D32)),
                ),
                Text(
                  "${(progress * 100).round()}%",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButtons(QuranController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildModeButton(
                Icons.menu_book_outlined,
                "Read Mode",
                0,
                controller,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildModeButton(
                Icons.headphones_outlined,
                "Commuter",
                1,
                controller,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildModeButton(
                Icons.psychology_outlined,
                "Memorization",
                2,
                controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    IconData icon,
    String label,
    int index,
    QuranController controller,
  ) {
    final isSelected = controller.selectedMode.value == index;
    return GestureDetector(
      onTap: () => controller.selectedMode.value = index,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE2E9D8) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: const Color(0xFF2E7D32), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Hexagonal icon container
            ClipPath(
              clipper: HexagonClipper(),
              child: Container(
                width: 44.w,
                height: 44.w,
                color: const Color(0xFF2E7D32),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 22.sp),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Hexagon clipper for mode button icons

  Widget _buildSearchBar(QuranController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: controller.searchTextController,
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 20.sp,
            ),
            suffixIcon: Obx(
              () => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[500],
                        size: 20.sp,
                      ),
                      onPressed: () => controller.searchTextController.clear(),
                    )
                  : const SizedBox.shrink(),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 16.w,
            ),
          ),
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
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredSurahs.isEmpty) {
        return const Center(child: Text("No surahs found"));
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.filteredSurahs.length,
        itemBuilder: (context, index) {
          final surah = controller.filteredSurahs[index];
          return _buildSurahItem(surah, context, controller);
        },
      );
    });
  }

  Widget _buildSurahItem(
    SurahModel surah,
    BuildContext context,
    QuranController controller,
  ) {
    return GestureDetector(
      onTap: () {
        if (controller.selectedMode.value == 1) {
          // Commuter / Listen Mode
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListenModeScreen()),
          );
        } else if (controller.selectedMode.value == 2) {
          // Memorization Mode
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemorizationScreen()),
          );
        } else {
          // Default to Read Mode (SurahReadingScreen)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahReadingScreen(
                surahId: surah.number,
                surahName: surah.englishName,
                arabicName: surah.arabicName,
                meaning: surah.englishName,
                origin: surah.revelationType,
                ayaCount: surah.totalVerses,
                translation: surah.translation,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Surah number in hexagon
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: 45 * 3.1415926535 / 180,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 1.5),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                Text(
                  surah.number.toString(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),

            SizedBox(width: 12.w),
            // Surah info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        surah.revelationType,
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
                        "${surah.revealedVerses} / ${surah.totalVerses} Aya",
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
                    fontFamily: 'Arial',
                  ),
                ),
                Text(
                  "${surah.totalVerses} VERSES",
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                ),
              ],
            ),
            SizedBox(width: 8.w),
            // Menu button
            GestureDetector(
              onTap: () => _showSurahMenu(context, surah),
              child: Icon(
                Icons.more_vert,
                size: 20.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
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
    return Obx(() {
      final list = controller.filteredJuzList;
      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0.h),
            child: Text("No items found"),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final juz = list[index];
          return _buildJuzItem(juz, context, controller);
        },
      );
    });
  }

  Widget _buildJuzItem(
    JuzModel juz,
    BuildContext context,
    QuranController controller,
  ) {
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
                "Juz ${juz.number}",
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
          ...juz.surahs.map(
            (surah) => _buildJuzSurahItem(surah, context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildJuzSurahItem(
    JuzSurahModel surah,
    BuildContext context,
    QuranController controller,
  ) {
    return GestureDetector(
      onTap: () {
        if (controller.selectedMode.value == 1) {
          // Commuter / Listen Mode
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListenModeScreen()),
          );
        } else if (controller.selectedMode.value == 2) {
          // Memorization Mode
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemorizationScreen()),
          );
        } else {
          // Default to Read Mode (SurahReadingScreen)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahReadingScreen(
                surahId: surah.number,
                surahName: surah.englishName,
                arabicName: surah.arabicName,
                meaning: surah.englishName,
                origin: surah.revelationType,
                ayaCount: 0,
                translation: surah.translation,
              ),
            ),
          );
        }
      },
      child: Padding(
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
                  surah.number.toString(),
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
                    surah.englishName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        surah.revelationType,
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
                        "Progress", // Placeholder or just Text
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  surah.versesRange,
                  style: TextStyle(fontSize: 9.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, QuranController controller) {
    final favAyahs = controller.filteredFavoriteAyahs;
    final favSurahs = controller.filteredSurahs.take(3).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (favAyahs.isNotEmpty) ...[
            Text(
              "Favorite Ayah",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            // Favorite ayahs
            ...favAyahs.map((ayah) => _buildFavoriteAyahItem(ayah)),
            SizedBox(height: 24.h),
          ],
          if (favSurahs.isNotEmpty) ...[
            Text(
              "Favorite Surah",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            // Favorite surahs (first 3)
            ...favSurahs.map(
              (surah) => _buildFavoriteSurahItem(surah, context, controller),
            ),
          ],
          if (favAyahs.isEmpty && favSurahs.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text("No favorites found"),
              ),
            ),
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
                fontFamily: 'Arial',
                height: 1.8,
              ),
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

  Widget _buildFavoriteSurahItem(
    SurahModel surah,
    BuildContext context,
    QuranController controller,
  ) {
    return GestureDetector(
      onTap: () {
        if (controller.selectedMode.value == 1) {
          // Commuter / Listen Mode
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListenModeScreen()),
          );
        } else if (controller.selectedMode.value == 2) {
          // Memorization Mode
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemorizationScreen()),
          );
        } else {
          // Default to Read Mode (SurahReadingScreen)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahReadingScreen(
                surahId: surah.number,
                surahName: surah.englishName,
                arabicName: surah.arabicName,
                meaning: surah.englishName,
                origin: surah.revelationType,
                ayaCount: surah.totalVerses,
                translation: surah.translation,
              ),
            ),
          );
        }
      },
      child: Container(
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
                    surah.englishName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        surah.revelationType,
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
                        "${surah.revealedVerses} / ${surah.totalVerses} Aya",
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${surah.totalVerses} VERSES",
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey[500]),
                ),
              ],
            ),
            SizedBox(width: 8.w),
            Icon(Icons.bookmark, color: const Color(0xFF2E7D32), size: 18.sp),
          ],
        ),
      ),
    );
  }
}

// Hexagon clipper for mode button icons
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Draw hexagon
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
