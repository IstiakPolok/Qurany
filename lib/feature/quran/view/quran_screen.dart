import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/const/app_colors.dart';
import '../../../core/const/static_surah_data.dart';
import '../../../core/const/static_juz_data.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../../bottom_nav_bar/screen/bottom_nav_bar.dart';
import '../../home/model/surah_model.dart';
import '../../home/services/quran_service.dart';
import '../model/bookmarked_verse_model.dart';
import 'surah_reading_screen.dart';
import 'listen_mode_screen.dart';
import 'memorization_screen.dart';

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
  var juzList = <JuzModel>[].obs;
  var favoriteSurahs = <SurahModel>[].obs;
  var bookmarkedVerses = <BookmarkedVerseModel>[].obs;
  var recentReadingHistory = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isLoadingJuz = false.obs;
  var isLoadingFavorites = false.obs;
  var isLoadingBookmarkedVerses = false.obs;

  bool _isSurahsFetched = false;
  bool _isJuzFetched = false;
  bool _isFavoriteSurahsFetched = false;
  bool _isBookmarkedVersesFetched = false;

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

  List<SurahModel> get filteredFavoriteSurahs {
    if (searchQuery.value.isEmpty) {
      return favoriteSurahs;
    }
    return favoriteSurahs
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

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(() {
      searchQuery.value = searchTextController.text;
    });
    fetchSurahs();
    fetchJuz();

    // Initial fetch
    fetchFavoriteSurahs(forceRefresh: true);
    fetchBookmarkedVerses(forceRefresh: true);
    fetchRecentReadingHistory();

    // Listen to bottom navigation changes to reload when user comes back to this screen
    try {
      if (Get.isRegistered<BottomNavbarController>()) {
        ever(Get.find<BottomNavbarController>().currentIndex, (index) {
          if (index == 1) {
            // Quran tab selected
            fetchFavoriteSurahs(forceRefresh: true);
            fetchBookmarkedVerses(forceRefresh: true);
            fetchRecentReadingHistory();
          }
        });
      }
    } catch (e) {
      print("Error setting up BottomNavbar listener: $e");
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> fetchSurahs() async {
    if (_isSurahsFetched) return;
    try {
      isLoading(true);
      // Use static data instead of API call
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Simulate loading

      // Fetch progress from API
      final progressMap = await _quranService.fetchSurahProgress();

      // Update surahs with progress data
      final surahsWithProgress = StaticSurahData.getAllSurahs().map((surah) {
        if (progressMap.containsKey(surah.number)) {
          return surah.copyWith(revealedVerses: progressMap[surah.number]);
        }
        return surah;
      }).toList();

      surahs.assignAll(surahsWithProgress);
      _isSurahsFetched = true;
    } catch (e) {
      print("Error loading surahs: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchJuz() async {
    if (_isJuzFetched) return;
    try {
      isLoadingJuz(true);
      // Use static data instead of API call
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Simulate loading

      // Fetch progress from API
      final progressMap = await _quranService.fetchSurahProgress();

      // Update juz with progress data
      final juzWithProgress = StaticJuzData.getAllJuz().map((juz) {
        final updatedSurahs = juz.surahs.map((surah) {
          if (progressMap.containsKey(surah.number)) {
            return surah.copyWith(revealedVerses: progressMap[surah.number]);
          }
          return surah;
        }).toList();

        return JuzModel(number: juz.number, surahs: updatedSurahs);
      }).toList();

      juzList.assignAll(juzWithProgress);
      _isJuzFetched = true;
    } catch (e) {
      print("Error fetching juz: $e");
    } finally {
      isLoadingJuz(false);
    }
  }

  Future<void> fetchFavoriteSurahs({bool forceRefresh = false}) async {
    if (_isFavoriteSurahsFetched && !forceRefresh) return;
    try {
      isLoadingFavorites(true);
      print("📚 Fetching bookmarked surahs...");
      final response = await _quranService.fetchBookmarkedSurahs();
      print("✅ Received ${response.length} bookmarked surahs");
      response.forEach((surah) {
        print(
          "  - Surah ${surah.number}: ${surah.englishName} (${surah.arabicName})",
        );
        print(
          "    Type: ${surah.revelationType}, Verses: ${surah.totalVerses}",
        );
      });
      favoriteSurahs.assignAll(response);
      _isFavoriteSurahsFetched = true;
      print("💾 Assigned to favoriteSurahs observable");
    } catch (e) {
      print("❌ Error fetching favorite surahs: $e");
      print("Stack trace: ${StackTrace.current}");
    } finally {
      isLoadingFavorites(false);
    }
  }

  Future<void> removeFavoriteSurah(int surahId) async {
    try {
      final success = await _quranService.toggleBookmarkSurah(surahId);
      if (success) {
        await fetchFavoriteSurahs(forceRefresh: true);
        Get.snackbar(
          "Success",
          "Surah removed from favorites",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.black,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to remove surah from favorites",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.black,
        );
      }
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }

  Future<void> toggleFavorite(SurahModel surah) async {
    try {
      final success = await _quranService.toggleBookmarkSurah(surah.number);
      if (success) {
        await fetchFavoriteSurahs(forceRefresh: true);
        Get.snackbar(
          "Success",
          "Favorite list updated",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.black,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to update favorite",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.black,
        );
      }
    } catch (e) {
      print("Error toggling favorite: $e");
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

  Future<void> fetchBookmarkedVerses({bool forceRefresh = false}) async {
    if (_isBookmarkedVersesFetched && !forceRefresh) return;
    try {
      isLoadingBookmarkedVerses(true);
      print("📚 Fetching bookmarked verses...");
      final response = await _quranService.fetchBookmarkedVerses();
      print("✅ Received ${response.length} bookmarked verses");
      bookmarkedVerses.assignAll(response);
      _isBookmarkedVersesFetched = true;
      print("💾 Assigned to bookmarkedVerses observable");
    } catch (e) {
      print("❌ Error fetching bookmarked verses: $e");
      print("Stack trace: ${StackTrace.current}");
    } finally {
      isLoadingBookmarkedVerses(false);
    }
  }

  Future<void> removeBookmarkedVerse(
    int surahId,
    int verseId,
    String verseName,
  ) async {
    try {
      Get.dialog(
        AlertDialog(
          title: const Text("Remove Favorite"),
          content: Text(
            "Are you sure you want to remove verse $verseId of $verseName from your favorites?",
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                final success = await _quranService.deleteBookmarkedVerse(
                  surahId,
                  verseId,
                );
                if (success) {
                  await fetchBookmarkedVerses(forceRefresh: true);
                  Get.snackbar(
                    "Success",
                    "Verse removed from favorites",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    colorText: Colors.black,
                  );
                } else {
                  Get.snackbar(
                    "Error",
                    "Failed to remove verse from favorites",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.black,
                  );
                }
              },
              child: const Text("Remove", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error in removeBookmarkedVerse: $e");
    }
  }

  List<BookmarkedVerseModel> get filteredBookmarkedVerses {
    if (searchQuery.value.isEmpty) {
      return bookmarkedVerses;
    }
    return bookmarkedVerses
        .where(
          (v) =>
              v.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              v.translation.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  Future<void> fetchRecentReadingHistory() async {
    try {
      final history = await SharedPreferencesHelper.getRecentReadingHistory();
      recentReadingHistory.assignAll(history);
    } catch (e) {
      print("Error fetching recent reading history: $e");
    }
  }

  String getFormattedSavedDate(String createdAt) {
    try {
      final date = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return "Saved today";
      } else if (difference.inDays == 1) {
        return "Saved yesterday";
      } else if (difference.inDays < 7) {
        return "Saved ${difference.inDays} days ago";
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return "Saved $weeks ${weeks == 1 ? 'week' : 'weeks'} ago";
      } else {
        final months = (difference.inDays / 30).floor();
        return "Saved $months ${months == 1 ? 'month' : 'months'} ago";
      }
    } catch (e) {
      return "Saved recently";
    }
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
            Column(
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
    return Obx(() {
      // Default values
      String surahName = "Al-Faatiha";
      String arabicName = "الفاتحة";
      int surahId = 1;
      int lastVerseId = 1;
      int totalVerses = 7;
      double progress = 0.0;
      String origin = "MECCAN";
      String translation = "The Opener";

      // If we have reading history, use the most recent one
      if (controller.recentReadingHistory.isNotEmpty) {
        final lastRead = controller.recentReadingHistory.first;
        surahId = lastRead['surahId'] ?? 1;
        surahName = lastRead['surahName'] ?? "Al-Faatiha";
        arabicName = lastRead['arabicName'] ?? "الفاتحة";
        lastVerseId = lastRead['lastVerseId'] ?? 1;
        totalVerses = lastRead['totalVerses'] ?? 7;
        progress = ((lastVerseId / totalVerses) * 100).clamp(0.0, 100.0) / 100;

        // Find surah details from static data for navigation
        final surahDetails = StaticSurahData.getAllSurahs().firstWhere(
          (s) => s.number == surahId,
          orElse: () => StaticSurahData.getAllSurahs().first,
        );
        origin = surahDetails.revelationType;
        translation = surahDetails.translation;
      }

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
                      Flexible(
                        child: Text(
                          "$surahName : $lastVerseId",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                        Get.delete<ListenModeController>();
                        Get.to(
                          () => ListenModeScreen(
                            surahId: surahId,
                            surahName: surahName,
                            arabicName: arabicName,
                          ),
                        )?.then((_) {
                          controller.fetchFavoriteSurahs(forceRefresh: true);
                          controller.fetchBookmarkedVerses(forceRefresh: true);
                        });
                      } else if (controller.selectedMode.value == 2) {
                        // Memorization Mode
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MemorizationScreen(),
                          ),
                        ).then((_) {
                          controller.fetchFavoriteSurahs(forceRefresh: true);
                          controller.fetchBookmarkedVerses(forceRefresh: true);
                        });
                      } else {
                        // Default to Read Mode (SurahReadingScreen)
                        Get.delete<SurahReadingController>();
                        Get.to(
                          () => SurahReadingScreen(
                            surahId: surahId,
                            surahName: surahName,
                            arabicName: arabicName,
                            meaning: surahName,
                            origin: origin,
                            ayaCount: totalVerses,
                            translation: translation,
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
    });
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
          Get.delete<ListenModeController>();
          Get.to(
            () => ListenModeScreen(
              surahId: surah.number,
              surahName: surah.englishName,
              arabicName: surah.arabicName,
            ),
          )?.then((_) {
            controller.fetchFavoriteSurahs(forceRefresh: true);
            controller.fetchBookmarkedVerses(forceRefresh: true);
          });
        } else if (controller.selectedMode.value == 2) {
          // Memorization Mode
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemorizationScreen()),
          ).then((_) {
            controller.fetchFavoriteSurahs(forceRefresh: true);
            controller.fetchBookmarkedVerses(forceRefresh: true);
          });
        } else {
          // Default to Read Mode (SurahReadingScreen)
          Get.delete<SurahReadingController>();
          Get.to(
            () => SurahReadingScreen(
              surahId: surah.number,
              surahName: surah.englishName,
              arabicName: surah.arabicName,
              meaning: surah.englishName,
              origin: surah.revelationType,
              ayaCount: surah.totalVerses,
              translation: surah.translation,
            ),
          )?.then((_) {
            controller.fetchFavoriteSurahs(forceRefresh: true);
            controller.fetchBookmarkedVerses(forceRefresh: true);
          });
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
    final QuranController controller = Get.find<QuranController>();
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
            Obx(() {
              final isFav = controller.favoriteSurahs.any(
                (s) => s.number == surah.number,
              );
              return ListTile(
                leading: Icon(
                  isFav ? Icons.bookmark : Icons.bookmark_border,
                  color: const Color(0xFF2E7D32),
                ),
                title: Text(isFav ? "Unfavorite" : "Favorite"),
                onTap: () {
                  Navigator.pop(context);
                  controller.toggleFavorite(surah);
                },
              );
            }),
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
      if (controller.isLoadingJuz.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = controller.filteredJuzList;
      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0.h),
            child: Text("No Juz found"),
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
          Get.delete<ListenModeController>();
          Get.to(
            () => ListenModeScreen(
              surahId: surah.number,
              surahName: surah.englishName,
              arabicName: surah.arabicName,
            ),
          )?.then((_) {
            controller.fetchFavoriteSurahs(forceRefresh: true);
            controller.fetchBookmarkedVerses(forceRefresh: true);
          });
        } else if (controller.selectedMode.value == 2) {
          // Memorization Mode
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemorizationScreen()),
          ).then((_) {
            controller.fetchFavoriteSurahs(forceRefresh: true);
            controller.fetchBookmarkedVerses(forceRefresh: true);
          });
        } else {
          // Default to Read Mode (SurahReadingScreen)
          Get.delete<SurahReadingController>();
          Get.to(
            () => SurahReadingScreen(
              surahId: surah.number,
              surahName: surah.englishName,
              arabicName: surah.arabicName,
              meaning: surah.englishName,
              origin: surah.revelationType,
              ayaCount: surah.totalVerses,
              translation: surah.translation,
            ),
          )?.then((_) {
            controller.fetchFavoriteSurahs(forceRefresh: true);
            controller.fetchBookmarkedVerses(forceRefresh: true);
          });
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
    return Obx(() {
      final favVerses = controller.filteredBookmarkedVerses;
      final favSurahs = controller.filteredFavoriteSurahs;
      final isLoadingVerses = controller.isLoadingBookmarkedVerses.value;
      final isLoadingSurahs = controller.isLoadingFavorites.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (favVerses.isNotEmpty || isLoadingVerses) ...[
              Text(
                "Favorite Ayah",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              // Favorite verses
              if (isLoadingVerses)
                const Center(child: CircularProgressIndicator())
              else if (favVerses.isNotEmpty)
                ...favVerses.map(
                  (verse) => _buildFavoriteAyahItem(verse, controller),
                )
              else
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text("No favorite verses found"),
                  ),
                ),
              SizedBox(height: 24.h),
            ],
            Text(
              "Favorite Surah",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            if (isLoadingSurahs)
              const Center(child: CircularProgressIndicator())
            else if (favSurahs.isNotEmpty)
              ...favSurahs.map(
                (surah) => _buildFavoriteSurahItem(surah, context, controller),
              )
            else
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Text("No favorite surahs found"),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFavoriteAyahItem(
    BookmarkedVerseModel verse,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${verse.name} • Verse ${verse.verseId}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      controller.getFormattedSavedDate(verse.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.removeBookmarkedVerse(
                  verse.surahId,
                  verse.verseId,
                  verse.name,
                ),
                child: Icon(
                  Icons.bookmark,
                  color: const Color(0xFF2E7D32),
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              verse.text,
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'Arial',
                height: 1.8,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            verse.translation,
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
          Get.delete<ListenModeController>();
          Get.to(
            () => ListenModeScreen(
              surahId: surah.number,
              surahName: surah.englishName,
              arabicName: surah.arabicName,
            ),
          )?.then((_) {
            controller.fetchFavoriteSurahs(forceRefresh: true);
            controller.fetchBookmarkedVerses(forceRefresh: true);
          });
        } else if (controller.selectedMode.value == 2) {
          // Memorization Mode
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MemorizationScreen()),
          ).then((_) {
            controller.fetchFavoriteSurahs(forceRefresh: true);
            controller.fetchBookmarkedVerses(forceRefresh: true);
          });
        } else {
          // Default to Read Mode (SurahReadingScreen)
          Get.delete<SurahReadingController>();
          Get.to(
            () => SurahReadingScreen(
              surahId: surah.number,
              surahName: surah.englishName,
              arabicName: surah.arabicName,
              meaning: surah.englishName,
              origin: surah.revelationType,
              ayaCount: surah.totalVerses,
              translation: surah.translation,
            ),
          )?.then((_) {
            controller.fetchFavoriteSurahs(forceRefresh: true);
            controller.fetchBookmarkedVerses(forceRefresh: true);
          });
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
            GestureDetector(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text("Remove Favorite"),
                    content: Text(
                      "Are you sure you want to remove ${surah.englishName} from your favorites?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.removeFavoriteSurah(surah.number);
                        },
                        child: const Text(
                          "Remove",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Icon(
                Icons.bookmark,
                color: const Color(0xFF2E7D32),
                size: 18.sp,
              ),
            ),
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
