import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/feature/quran/view/listen_mode_screen.dart';
import 'package:qurany/feature/home/services/quran_service.dart';
import 'package:qurany/feature/quran/model/verse_detail_model.dart';
import 'package:qurany/feature/quran/model/tafsir_model.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

// Controller
class SurahReadingController extends GetxController {
  final QuranService _quranService = QuranService();
  final int surahId;
  final AudioPlayer _audioPlayer = AudioPlayer();

  RxInt selectedViewTab =
      0.obs; // 0 = Translation, 1 = Transliteration, 2 = Tafsir
  RxBool isPlaying = false.obs;
  RxInt currentPlayingVerse = (-1).obs;
  RxDouble playbackSpeed = 1.0.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs;
  RxInt currentPage = 1.obs;
  RxInt totalVerses = 0.obs;
  RxBool hasMoreVerses = true.obs;

  var verses = <VerseDetailModel>[].obs;
  Rx<AudioDetailModel?> audio = Rx<AudioDetailModel?>(null);

  // Tafsir state
  RxList<TafsirModel> tafsirs = <TafsirModel>[].obs;
  RxBool isLoadingTafsir = false.obs;
  RxInt tafsirPage = 1.obs;
  RxBool hasMoreTafsir = true.obs;

  SurahReadingController({required this.surahId});

  @override
  void onInit() {
    super.onInit();
    fetchSurahDetails();
    fetchTafsir();

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
      if (state == PlayerState.completed) {
        _playNextVerse();
      }
    });
  }

  void _playNextVerse() {
    if (currentPlayingVerse.value == -1) return;

    int currentIndex = verses.indexWhere(
      (v) => v.verseId == currentPlayingVerse.value,
    );
    if (currentIndex != -1 && currentIndex < verses.length - 1) {
      playVerse(verses[currentIndex + 1].verseId);
    } else {
      isPlaying.value = false;
      currentPlayingVerse.value = -1;
    }
  }

  void playNextVerse() => _playNextVerse();

  void playPreviousVerse() {
    if (currentPlayingVerse.value == -1) return;

    int currentIndex = verses.indexWhere(
      (v) => v.verseId == currentPlayingVerse.value,
    );
    if (currentIndex != -1 && currentIndex > 0) {
      playVerse(verses[currentIndex - 1].verseId);
    }
  }

  Future<void> changePlaybackSpeed() async {
    List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    int currentIndex = speeds.indexOf(playbackSpeed.value);
    if (currentIndex == -1) currentIndex = 2; // Default to 1.0 if not found
    double nextSpeed = speeds[(currentIndex + 1) % speeds.length];
    playbackSpeed.value = nextSpeed;

    // Apply speed immediately if player is active (playing or paused with source)
    if (currentPlayingVerse.value != -1) {
      try {
        await _audioPlayer.setPlaybackRate(nextSpeed);
      } catch (e) {
        print("Error setting playback speed: $e");
      }
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> fetchSurahDetails() async {
    try {
      isLoading(true);
      currentPage.value = 1;
      final response = await _quranService.fetchSurahById(
        surahId,
        page: currentPage.value,
        limit: 10,
      );
      verses.assignAll(response.verses);
      audio.value = response.audio;
      hasMoreVerses.value = response.verses.length >= 10;
    } catch (e) {
      print("Error fetching surah details: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchTafsir() async {
    try {
      isLoadingTafsir(true);
      tafsirPage.value = 1;
      final response = await _quranService.fetchTafsir(
        surahId,
        page: tafsirPage.value,
        limit: 10,
      );
      tafsirs.assignAll(response.tafsirs);
      hasMoreTafsir.value = response.tafsirs.length >= 10;
    } catch (e) {
      print("Error fetching tafsir: $e");
    } finally {
      isLoadingTafsir(false);
    }
  }

  Future<void> loadMoreTafsir() async {
    if (isLoadingMore.value || !hasMoreTafsir.value) return;

    try {
      isLoadingMore(true);
      tafsirPage.value++;
      final response = await _quranService.fetchTafsir(
        surahId,
        page: tafsirPage.value,
        limit: 10,
      );

      if (response.tafsirs.isEmpty) {
        hasMoreTafsir.value = false;
      } else {
        tafsirs.addAll(response.tafsirs);
        hasMoreTafsir.value = response.tafsirs.length >= 10;
      }
    } catch (e) {
      print("Error loading more tafsir: $e");
      tafsirPage.value--; // Revert page on error
    } finally {
      isLoadingMore(false);
    }
  }

  Future<void> loadMoreVerses() async {
    if (isLoadingMore.value || !hasMoreVerses.value) return;

    try {
      isLoadingMore(true);
      currentPage.value++;
      final response = await _quranService.fetchSurahById(
        surahId,
        page: currentPage.value,
        limit: 10,
      );

      if (response.verses.isEmpty) {
        hasMoreVerses.value = false;
      } else {
        verses.addAll(response.verses);
        hasMoreVerses.value = response.verses.length >= 10;
      }
    } catch (e) {
      print("Error loading more verses: $e");
      currentPage.value--; // Revert page on error
    } finally {
      isLoadingMore(false);
    }
  }

  void togglePlayPause() async {
    if (isPlaying.value) {
      await _audioPlayer.pause();
    } else {
      if (currentPlayingVerse.value != -1) {
        // Resume
        await _audioPlayer.resume();
      } else {
        // Start from beginning or handle logic
      }
    }
  }

  Future<void> playVerse(int verseId) async {
    // If tapping the same verse that is playing/paused
    if (currentPlayingVerse.value == verseId) {
      togglePlayPause();
      return;
    }

    try {
      currentPlayingVerse.value = verseId;

      // Find the verse object
      final verse = verses.firstWhere((v) => v.verseId == verseId);

      // Get preferred reciter
      String preferredReciterName = await SharedPreferencesHelper.getReciter();
      String audioKey = _mapReciterNameToKey(preferredReciterName);

      String? audioUrl;

      if (verse.audio.containsKey(audioKey)) {
        audioUrl = verse.audio[audioKey]?.url;
      } else if (verse.audio.isNotEmpty) {
        // Fallback to first available
        audioUrl = verse.audio.values.first.url;
      }

      if (audioUrl != null) {
        await _audioPlayer.stop();
        await _audioPlayer.setSourceUrl(audioUrl);
        await _audioPlayer.setPlaybackRate(playbackSpeed.value);
        await _audioPlayer.resume();
      } else {
        Get.snackbar("Error", "Audio not available for this verse");
      }
    } catch (e) {
      print("Error playing verse: $e");
      Get.snackbar("Error", "Failed to play audio");
    }
  }

  String _mapReciterNameToKey(String name) {
    // Determine key based on stored name
    // Keys based on API response: mishary, abuBakar, nasser, yasser
    if (name.contains("Mishary")) return "mishary";
    if (name.contains("Abu Bakr")) return "abuBakar";
    if (name.contains("Nasser")) return "nasser";
    if (name.contains("Yasser")) return "yasser";
    // Fallback default
    return "mishary";
  }
}

class SurahReadingScreen extends StatelessWidget {
  final int surahId;
  final String surahName;
  final String arabicName;
  final String meaning;
  final String origin;
  final int ayaCount;
  final String translation;

  const SurahReadingScreen({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.arabicName,
    required this.meaning,
    required this.origin,
    required this.ayaCount,
    required this.translation,
  });

  @override
  Widget build(BuildContext context) {
    final SurahReadingController controller = Get.put(
      SurahReadingController(surahId: surahId),
      tag: surahId.toString(),
    );

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
                          // Surah number in image
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/Layer_1.png',
                                width: 32.w,
                                height: 32.w,
                              ),
                              Text(
                                surah["number"].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                            fontFamily: 'Arial',
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
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: AssetImage('assets/image/readmodecardBG.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20.h),
            Text(
              meaning,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translation.toUpperCase(),
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
                fontFamily: 'Arial',
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 40.h),
          ],
        ),
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
    return Obx(() {
      switch (controller.selectedViewTab.value) {
        case 1:
          return _buildTransliterationList(controller);
        case 2:
          return _buildTafsirList(controller);
        case 0:
        default:
          return _buildTranslationList(controller);
      }
    });
  }

  Widget _buildTranslationList(SurahReadingController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (controller.verses.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text("No verses found"),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.verses.length + 1,
        itemBuilder: (context, index) {
          if (index == controller.verses.length) {
            // Load More button
            return _buildLoadMoreButton(controller);
          }
          final verse = controller.verses[index];
          return _buildVerseCard(verse, controller);
        },
      );
    });
  }

  Widget _buildTransliterationList(SurahReadingController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (controller.verses.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text("No verses found"),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.verses.length + 1,
        itemBuilder: (context, index) {
          if (index == controller.verses.length) {
            // Load More button
            return _buildLoadMoreButton(controller);
          }
          final verse = controller.verses[index];
          return _buildTransliterationCard(verse, controller);
        },
      );
    });
  }

  Widget _buildTafsirList(SurahReadingController controller) {
    return Obx(() {
      if (controller.isLoadingTafsir.value && controller.tafsirs.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }
      if (controller.tafsirs.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text("No tafsir found"),
          ),
        );
      }
      return Column(
        children: [
          _buildTafsirDetailedHeader(),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: controller.tafsirs.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.tafsirs.length) {
                // Load More button
                return _buildLoadMoreTafsirButton(controller);
              }
              final tafsir = controller.tafsirs[index];
              return _buildTafsirCard(tafsir, controller);
            },
          ),
        ],
      );
    });
  }

  Widget _buildLoadMoreTafsirButton(SurahReadingController controller) {
    return Obx(() {
      if (!controller.hasMoreTafsir.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Center(
            child: Text(
              "No more tafsir",
              style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            ),
          ),
        );
      }

      if (controller.isLoadingMore.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Center(
          child: ElevatedButton(
            onPressed: () => controller.loadMoreTafsir(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              "Load More Tafsir",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLoadMoreButton(SurahReadingController controller) {
    return Obx(() {
      if (!controller.hasMoreVerses.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Center(
            child: Text(
              "No more verses",
              style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
            ),
          ),
        );
      }

      if (controller.isLoadingMore.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Center(
          child: ElevatedButton(
            onPressed: () => controller.loadMoreVerses(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              "Load More Verses",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTafsirDetailedHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tafsir",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black87,
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "INTRODUCTION TO FATIHAH",
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Which was revealed in Makkah?",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "The Meaning of Al-Fatihah and its Various Names",
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "This Surah is called\n- Al-Fatihah, that is, the Opener of the Book, the Surah with which prayers are begun.\n- It is also called, Umm Al-Kitab (the Mother of the Book), according to the majority of the scholars. In an authentic Hadith recorded by At-Tirmidhi, who graded it Sahih, Abu Hurayrah said that the Messenger of Allah ﷺ said,",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          // Add more static content here as needed or make it expandable
        ],
      ),
    );
  }

  Widget _buildVerseCard(
    VerseDetailModel verse,
    SurahReadingController controller,
  ) {
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
              Obx(() {
                final isCurrent =
                    controller.currentPlayingVerse.value == verse.verseId;
                final isPlaying = controller.isPlaying.value;
                return GestureDetector(
                  onTap: () => controller.playVerse(verse.verseId),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      isCurrent && isPlaying ? Icons.pause : Icons.play_arrow,
                      color: const Color(0xFF2E7D32),
                      size: 20.sp,
                    ),
                  ),
                );
              }),
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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/Layer_1.png',

                              height: 35.w,
                            ),
                            Text(
                              verse.ayate,
                              style: TextStyle(
                                color: const Color(0xFF2E7D32),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        Expanded(
                          child: Text(
                            verse.text,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontFamily: 'Arial',
                              height: 1.8,
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
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

  Widget _buildTransliterationCard(
    VerseDetailModel verse,
    SurahReadingController controller,
  ) {
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
          // Play button and Arabic text row (Standard)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final isCurrent =
                    controller.currentPlayingVerse.value == verse.verseId;
                final isPlaying = controller.isPlaying.value;
                return GestureDetector(
                  onTap: () => controller.playVerse(verse.verseId),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(50.r),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: Icon(
                      isCurrent && isPlaying
                          ? Icons.pause
                          : Icons.play_arrow_rounded,
                      color: Colors.black87,
                      size: 24.sp,
                    ),
                  ),
                );
              }),
              SizedBox(width: 12.w),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        verse.text,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontFamily: 'Arial',
                          height: 1.8,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Verse number in image
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/Layer_1.png',
                          width: 28.w,
                          height: 28.w,
                        ),
                        Text(
                          verse.ayate,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Transliteration
          Text(
            verse.transliteration,
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8.h),

          // Translation
          Text(
            verse.translation,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          SizedBox(height: 16.h),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.more_horiz, color: Colors.grey[500], size: 20.sp),
              Row(
                children: [
                  Icon(
                    Icons.message_outlined,
                    color: Colors.grey[400],
                    size: 20.sp,
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.edit_outlined,
                    color: Colors.grey[400],
                    size: 20.sp,
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.check, color: Colors.grey[400], size: 20.sp),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.bookmark_border,
                    color: Colors.grey[400],
                    size: 20.sp,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTafsirCard(
    TafsirModel tafsir,
    SurahReadingController controller,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F6), // Light background for Tafsir
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFBE9E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  tafsir.verse,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'Arial',
                    height: 1.8,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(width: 8.w),
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/icons/Layer_1.png',
                    width: 24.w,
                    height: 24.w,
                  ),
                  Text(
                    tafsir.ayate,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey[200]),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tafsir - Verse ${tafsir.verseId}",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.keyboard_arrow_up, color: Colors.black87, size: 20.sp),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            tafsir.text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[800],
              height: 1.5,
            ),
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
            GestureDetector(
              onTap: () => controller.changePlaybackSpeed(),
              child: Obx(
                () => Text(
                  "${controller.playbackSpeed.value}x",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Playback controls
            Row(
              children: [
                GestureDetector(
                  onTap: () => controller.playPreviousVerse(),
                  child: Icon(
                    Icons.skip_previous,
                    color: Colors.grey[700],
                    size: 28.sp,
                  ),
                ),
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
                GestureDetector(
                  onTap: () => controller.playNextVerse(),
                  child: Icon(
                    Icons.skip_next,
                    color: Colors.grey[700],
                    size: 28.sp,
                  ),
                ),
              ],
            ),

            // Listen Mode button
            GestureDetector(
              onTap: () => Get.to(
                () => ListenModeScreen(
                  surahId: surahId,
                  surahName: surahName,
                  arabicName: arabicName,
                ),
              ),
              child: Icon(
                Icons.headphones,
                color: Colors.grey[600],
                size: 24.sp,
              ),
            ),
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
