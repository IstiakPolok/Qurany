import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/feature/quran/view/listen_mode_screen.dart';
import 'package:qurany/feature/quran/view/memorization_screen.dart';
import 'package:qurany/feature/quran/view/quran_read_mode_screen.dart';
import 'package:qurany/feature/ask_ai/view/ask_ai_intro_screen.dart';
import 'package:qurany/feature/home/services/quran_service.dart';
import 'package:qurany/feature/quran/model/verse_detail_model.dart';
import 'package:qurany/feature/quran/model/tafsir_model.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

import '../../../core/const/static_surah_data.dart';
import '../../../core/network_caller/endpoints.dart' as Urls;

// Controller
class SurahReadingController extends GetxController {
  final QuranService _quranService = QuranService();
  final int surahId;
  final String surahName;
  final String arabicName;
  final int totalAyaCount;
  final int? initialVerseId;

  final AudioPlayer _player1 = AudioPlayer();
  final AudioPlayer _player2 = AudioPlayer();
  final RxInt _activePlayerIndex = 1.obs;

  AudioPlayer get _activePlayer =>
      _activePlayerIndex.value == 1 ? _player1 : _player2;
  AudioPlayer get _inactivePlayer =>
      _activePlayerIndex.value == 1 ? _player2 : _player1;

  RxInt selectedViewTab =
      0.obs; // 0 = Translation, 1 = Transliteration, 2 = Tafsir
  RxBool isPlaying = false.obs;
  RxBool isAudioLoading = false.obs;
  RxInt currentPlayingVerse = (-1).obs;
  RxInt loadingVerseId = (-1).obs;
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
  RxString selectedScriptName = 'Imlaei'.obs;
  RxDouble fontSize = 22.0.obs;
  RxString selectedLanguage = 'English'.obs;
  RxString endOfSurahAction = 'play_next_surah'.obs;
  RxString selectedReciterName = 'Mishary Rashid Alafasy'.obs;

  // Reading time tracking
  Timer? _readingTimer;
  int _sessionSeconds = 0;

  SurahReadingController({
    required this.surahId,
    required this.surahName,
    required this.arabicName,
    required this.totalAyaCount,
    this.initialVerseId,
  });

  @override
  void onInit() {
    if (kDebugMode) {
      print('SurahReadingController init: surahId=$surahId, name=$surahName');
    }
    super.onInit();

    // Set initial playing verse if provided
    if (initialVerseId != null) {
      currentPlayingVerse.value = initialVerseId!;
    }
    _loadScriptPreference();
    _loadFontSizePreference();
    _loadReciterPreference();
    _loadLanguageAndFetch();
    _startReadingTimer();
    _setupPlayerListeners(_player1);
    _setupPlayerListeners(_player2);
    fetchTafsir();
  }

  Future<void> _loadScriptPreference() async {
    final script = await SharedPreferencesHelper.getArabicScript();
    selectedScriptName.value = script;
  }

  Future<void> _loadFontSizePreference() async {
    double size = await SharedPreferencesHelper.getFontSize();
    fontSize.value = size;
  }

  Future<void> _loadReciterPreference() async {
    String savedReciter = await SharedPreferencesHelper.getReciter();
    selectedReciterName.value = savedReciter;
  }

  Future<void> saveReciter(String name) async {
    selectedReciterName.value = name;
    await SharedPreferencesHelper.saveReciter(name);
    if (isPlaying.value) {
      playVerse(currentPlayingVerse.value);
    }
  }

  /// Maps the display language name saved in SharedPreferences to the
  /// lang code expected by the API.
  static String langCodeFromName(String name) {
    switch (name) {
      case 'English':
        return 'en';
      case 'العربية':
        return 'ar';
      case 'اردو':
        return 'ur';
      case 'Türkçe':
        return 'tr';
      case 'Bahasa':
        return 'in';
      case 'Français':
      case 'François': // handle typo variant stored by language_step
        return 'fr';
      default:
        return 'en';
    }
  }

  /// Loads the saved language, updates locale, then fetches surah data
  /// using the correct lang code.
  Future<void> _loadLanguageAndFetch() async {
    final lang = await SharedPreferencesHelper.getLanguage();
    selectedLanguage.value = lang;
    _updateLocale(lang);
    await fetchSurahDetails();
  }



  void _updateLocale(String lang) {
    Locale locale;
    switch (lang) {
      case 'English':
        locale = const Locale('en');
        break;
      case 'العربية':
        locale = const Locale('ar');
        break;
      case 'اردو':
        locale = const Locale('ur');
        break;
      case 'Türkçe':
        locale = const Locale('tr');
        break;
      case 'Bahasa':
        locale = const Locale('id');
        break;
      case 'Français':
      case 'François':
        locale = const Locale('fr');
        break;
      default:
        locale = const Locale('en');
    }
    Get.updateLocale(locale);
  }

  Future<void> saveFontSize(double value) async {
    fontSize.value = value;
    await SharedPreferencesHelper.saveFontSize(value);
  }

  Future<void> saveArabicScript(String script) async {
    selectedScriptName.value = script;
    await SharedPreferencesHelper.saveArabicScript(script);
  }

  Future<void> _startReadingTimer() async {
    // Load already-accumulated seconds for today
    _sessionSeconds = await SharedPreferencesHelper.getDailyReadingSeconds();
    if (kDebugMode) {
      print('Reading timer started. Initial seconds: $_sessionSeconds');
    }
    _readingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      _sessionSeconds++;
      // Save every 30 seconds to avoid too many writes
      if (_sessionSeconds % 30 == 0) {
        await SharedPreferencesHelper.saveDailyReadingSeconds(_sessionSeconds);
      }
    });
  }

  void _setupPlayerListeners(AudioPlayer player) {
    player.onPlayerStateChanged.listen((state) {
      if (player == _activePlayer) {
        isPlaying.value = state == PlayerState.playing;
        if (state == PlayerState.playing) {
          _clearAudioLoading();
        }
        if (state == PlayerState.completed) {
          _clearAudioLoading();
          _playNextVerse();
        }
      }
    });
  }

  void _setAudioLoading(int verseId) {
    isAudioLoading.value = true;
    loadingVerseId.value = verseId;
  }

  void _clearAudioLoading() {
    isAudioLoading.value = false;
    loadingVerseId.value = -1;
  }

  // Save reading progress whenever a verse is played
  Future<void> _saveReadingProgress(int verseId) async {
    await SharedPreferencesHelper.saveRecentReading(
      surahId: surahId,
      surahName: surahName,
      arabicName: arabicName,
      lastVerseId: verseId,
      totalVerses: totalAyaCount,
    );
  }

  Future<void> _toggleVerseProgress(int verseId) async {
    final success = await _quranService.toggleVerseProgress(surahId, verseId);
    if (!success) {
      if (kDebugMode) {
        print('Failed to toggle progress for surah $surahId verse $verseId');
      }
    }
  }

  void _markVerseRead(int verseId) {
    final index = verses.indexWhere((v) => v.verseId == verseId);
    if (index == -1) return;
    final verse = verses[index];
    if (verse.isVerseRead) return;
    verses[index] = verse.copyWith(isVerseRead: true);
  }

  void _playNextVerse() async {
    if (currentPlayingVerse.value == -1) return;

    int currentIndex = verses.indexWhere(
      (v) => v.verseId == currentPlayingVerse.value,
    );
    if (currentIndex != -1 && currentIndex < verses.length - 1) {
      final nextVerse = verses[currentIndex + 1];

      if (kDebugMode) {
        print('Switching to next verse: ${nextVerse.verseId}');
      }
      // The inactive player should already have preloaded the next verse
      _activePlayerIndex.value = _activePlayerIndex.value == 1 ? 2 : 1;
      currentPlayingVerse.value = nextVerse.verseId;

      await _activePlayer.setPlaybackRate(playbackSpeed.value);
      await _activePlayer.resume();

      _markVerseRead(nextVerse.verseId);
      await _toggleVerseProgress(nextVerse.verseId);

      // Preload the following verse
      _preloadNextVerse(currentIndex + 1);
    } else {
      if (kDebugMode) {
        print('Surah completed or no more verses to play');
      }
      _clearAudioLoading();
      isPlaying.value = false;
      currentPlayingVerse.value = -1;
    }
  }

  Future<void> _preloadNextVerse(int currentIndex) async {
    if (currentIndex < verses.length - 1) {
      final followingVerse = verses[currentIndex + 1];
      if (kDebugMode) {
        print('Preloading verse: ${followingVerse.verseId}');
      }
      String? nextUrl = await _getAudioUrlForVerse(followingVerse.verseId);
      if (nextUrl != null) {
        // Set source on the player that is NOT currently playing
        await _inactivePlayer.setSourceUrl(nextUrl);
      }
    }
  }

  Future<String?> _getAudioUrlForVerse(int verseId) async {
    try {
      final verse = verses.firstWhere((v) => v.verseId == verseId);
      // String preferredReciterName = await SharedPreferencesHelper.getReciter();
      String preferredReciterName = selectedReciterName.value;
      String audioKey = _mapReciterNameToKey(preferredReciterName);

      if (verse.audio.containsKey(audioKey)) {
        return verse.audio[audioKey]?.url;
      } else if (verse.audio.isNotEmpty) {
        return verse.audio.values.first.url;
      }
    } catch (e) {
      print("Error getting audio URL: $e");
    }
    return null;
  }

  void playNextVerse() => _playNextVerse();

  void playPreviousVerse() async {
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

    // Apply speed immediately to active player
    if (currentPlayingVerse.value != -1) {
      try {
        await _activePlayer.setPlaybackRate(nextSpeed);
      } catch (e) {
        print("Error setting playback speed: $e");
      }
    }
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print('SurahReadingController closing. Saving seconds: $_sessionSeconds');
    }
    // Save final reading seconds before closing
    SharedPreferencesHelper.saveDailyReadingSeconds(_sessionSeconds);
    _readingTimer?.cancel();
    _player1.dispose();
    _player2.dispose();
    super.onClose();
  }

  Future<void> toggleBookmark(int verseId) async {
    try {
      final result = await _quranService.toggleBookmarkVerseAction(
        surahId,
        verseId,
      );
      if (result.success) {
        Get.snackbar(
          "success".tr,
          "bookmark_updated".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.black,
        );
      } else {
        Get.snackbar(
          "error".tr,
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.black,
        );
      }
    } catch (e) {
      print("Error toggling bookmark: $e");
    }
  }

  Future<void> fetchSurahDetails() async {
    try {
      isLoading(true);
      currentPage.value = 1;
      final langCode = langCodeFromName(selectedLanguage.value);
      if (kDebugMode) {
        print('Fetching surah: $surahId, page: ${currentPage.value}, lang: $langCode');
      }
      final response = await _quranService.fetchSurahById(
        surahId,
        page: currentPage.value,
        limit: 10,
        lang: langCode,
      );
      if (kDebugMode) {
        print('Surah details fetched: ${response.verses.length} verses');
      }
      verses.assignAll(response.verses);
      audio.value = response.audio;
      hasMoreVerses.value = response.verses.length >= 10;

      // Save reading progress with the last verse fetched
      if (response.verses.isNotEmpty) {
        final lastVerse = response.verses.last;
        await _saveReadingProgress(lastVerse.verseId);
      }
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
      if (kDebugMode) {
        print('Fetching tafsir for surah: $surahId');
      }
      final response = await _quranService.fetchTafsir(
        surahId,
        page: tafsirPage.value,
        limit: 10,
      );
      if (kDebugMode) {
        print('Tafsir fetched: ${response.tafsirs.length} items');
      }
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
      if (kDebugMode) {
        print('Loading more tafsir: page ${tafsirPage.value}');
      }
      final response = await _quranService.fetchTafsir(
        surahId,
        page: tafsirPage.value,
        limit: 10,
      );
      if (kDebugMode) {
        print('More tafsir loaded: ${response.tafsirs.length} items');
      }

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
      final langCode = langCodeFromName(selectedLanguage.value);
      if (kDebugMode) {
        print('Loading more verses: page ${currentPage.value}, lang: $langCode');
      }
      final response = await _quranService.fetchSurahById(
        surahId,
        page: currentPage.value,
        limit: 10,
        lang: langCode,
      );
      if (kDebugMode) {
        print('More verses loaded: ${response.verses.length} items');
      }

      if (response.verses.isEmpty) {
        hasMoreVerses.value = false;
      } else {
        verses.addAll(response.verses);
        hasMoreVerses.value = response.verses.length >= 10;

        // Save reading progress with the last verse fetched
        final lastVerse = response.verses.last;
        await _saveReadingProgress(lastVerse.verseId);
      }
    } catch (e) {
      print("Error loading more verses: $e");
      currentPage.value--; // Revert page on error
    } finally {
      isLoadingMore(false);
    }
  }

  void togglePlayPause() async {
    if (isAudioLoading.value) return;

    if (isPlaying.value) {
      await _activePlayer.pause();
    } else {
      if (currentPlayingVerse.value != -1) {
        // Resume
        _setAudioLoading(currentPlayingVerse.value);
        try {
          await _activePlayer.setPlaybackRate(playbackSpeed.value);
          await _activePlayer.resume();
        } catch (e) {
          _clearAudioLoading();
          print("Error resuming verse: $e");
          Get.snackbar("error".tr, "failed_play_audio".tr);
        }
      } else if (verses.isNotEmpty) {
        // Start from first verse if nothing is playing
        playVerse(verses.first.verseId);
      }
    }
  }

  Future<void> playVerse(int verseId) async {
    if (isAudioLoading.value) return;

    // If tapping the same verse that is playing/paused
    if (currentPlayingVerse.value == verseId) {
      togglePlayPause();
      return;
    }

    try {
      _setAudioLoading(verseId);

      // Stop all players before starting fresh
      await _player1.stop();
      await _player2.stop();

      currentPlayingVerse.value = verseId;
      String? audioUrl = await _getAudioUrlForVerse(verseId);

      if (audioUrl != null) {
        if (kDebugMode) {
          print('Playing verse $verseId with URL: $audioUrl');
        }
        await _activePlayer.setSourceUrl(audioUrl);
        await _activePlayer.setPlaybackRate(playbackSpeed.value);
        await _activePlayer.resume();

        _markVerseRead(verseId);
        await _toggleVerseProgress(verseId);

        // Find index and preload next
        int index = verses.indexWhere((v) => v.verseId == verseId);
        _preloadNextVerse(index);
      } else {
        _clearAudioLoading();
        Get.snackbar("error".tr, "audio_not_available".tr);
      }
    } catch (e) {
      _clearAudioLoading();
      print("Error playing verse: $e");
      Get.snackbar("error".tr, "failed_play_audio".tr);
    }
  }

  void updateVerseNotes(int verseId, List<NoteModel> notes) {
    final index = verses.indexWhere((v) => v.verseId == verseId);
    if (index == -1) return;
    verses[index] = verses[index].copyWith(notes: notes);
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
  final int? initialVerseId;

  const SurahReadingScreen({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.arabicName,
    required this.meaning,
    required this.origin,
    required this.ayaCount,
    required this.translation,
    this.initialVerseId,
  });

  Future<void> _copyVerseInfo(VerseDetailModel verse) async {
    final String transliteration = verse.transliteration.trim();
    final String verseInfo = [
      '$surahName - ${'aya'.tr} ${verse.verseId}',
      'Arabic: ${verse.text}',
      if (transliteration.isNotEmpty)
        '${'transliteration'.tr}: $transliteration',
      '${'translation'.tr}: ${verse.translation}',
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: verseInfo));
    Get.snackbar(
      'copied'.tr,
      'verse_copied_msg'.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SurahReadingController controller = Get.put(
      SurahReadingController(
        surahId: surahId,
        surahName: surahName,
        arabicName: arabicName,
        totalAyaCount: ayaCount,
        initialVerseId: initialVerseId,
      ),
      tag: surahId.toString(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: Stack(
        children: [
          Column(
            children: [
              // App Bar
              _buildAppBar(context, controller),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Surah Header Card
                      _buildSurahHeader(),

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

  Widget _buildAppBar(BuildContext context, SurahReadingController controller) {
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
            onTap: () => _showSurahSelector(context, controller),
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
          GestureDetector(
            onTap: () => _showSettingsPanel(context, controller),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(
                Icons.info_outline,
                size: 18.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsPanel(
    BuildContext context,
    SurahReadingController controller,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSettingsPanel(context, controller),
    );
    await controller.fetchSurahDetails();
  }

  Widget _buildSettingsPanel(
    BuildContext context,
    SurahReadingController controller,
  ) {
    return StatefulBuilder(
      builder: (ctx, setSheetState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 32.w),
                    Text(
                      'settings'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[200]),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text Size
                      Text(
                        'text_size'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Obx(() {
                        return Row(
                          children: [
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black54,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: const Color(0xFF2E7D32),
                                  inactiveTrackColor: Colors.grey[300],
                                  thumbColor: const Color(0xFF2E7D32),
                                  overlayColor: const Color(
                                    0xFF2E7D32,
                                  ).withOpacity(0.2),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: controller.fontSize.value,
                                  min: 14,
                                  max: 40,
                                  onChanged: (v) async {
                                    await controller.saveFontSize(v);
                                    setSheetState(() {});
                                  },
                                ),
                              ),
                            ),
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 20.h),
                      // Select Your Reciter
                      Text(
                        'select_reciter'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildReciterSelector(setSheetState, controller),
                      SizedBox(height: 20.h),
                      // Choose your language
                      Text(
                        'language'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Obx(() {
                        final languages = [
                          'English',
                          'العربية',
                          'اردو',
                          'Türkçe',
                          'Bahasa',
                          'Français',
                        ];
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: const Color(0xFFFFF9F0),
                              value: controller.selectedLanguage.value,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                              items: languages
                                  .map(
                                    (lang) => DropdownMenuItem(
                                      value: lang,
                                      child: Text(lang),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) async {
                                if (v != null) {
                                  controller.selectedLanguage.value = v;
                                  setSheetState(() {});
                                  await SharedPreferencesHelper.saveLanguage(v);
                                  controller._updateLocale(v);
                                }
                              },
                            ),
                          ),
                        );
                      }),
                      SizedBox(height: 20.h),
                      // At the end of Surah
                      Text(
                        'at_end_of_surah'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: const Color(0xFFFFF9F0),
                            value: controller.endOfSurahAction.value,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                            items:
                                [
                                      {
                                        'key': 'play_next_surah',
                                        'label': 'play_next_surah'.tr,
                                      },
                                      {'key': 'stop', 'label': 'stop'.tr},
                                      {'key': 'repeat', 'label': 'repeat'.tr},
                                    ]
                                    .map(
                                      (opt) => DropdownMenuItem(
                                        value: opt['key'] as String,
                                        child: Text(opt['label'] as String),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                controller.endOfSurahAction.value = v;
                                setSheetState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // Select your Arabic script
                      Text(
                        'select_arabic_script'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildArabicScriptSelector(setSheetState, controller),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReciterSelector(
    StateSetter setSheetState,
    SurahReadingController controller,
  ) {
    // We can adapt the reciter selector from QuranReadModeScreen
    // For now, let's just use a simplified version or reuse the existing logic if possible.
    final reciters = [
      {
        'name': 'Mishary Rashid Alafasy',
        'image': 'assets/image/MisharyRashidAIAlfasy.jpg',
      },
      {
        'name': 'Abu Bakr al-Shatri',
        'image': 'assets/image/abu_bakr_shatri.jpg',
      },
      {
        'name': 'Nasser Al-Qatami',
        'image': 'assets/image/NasserAlQatami.jpg',
      },
      {
        'name': 'Yasser Al-Dossary',
        'image': 'assets/image/YasserAlDosari.jpg',
      },
    ];

    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reciters.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected =
                controller.selectedReciterName.value == reciters[index]['name'];
            return GestureDetector(
              onTap: () async {
                await controller.saveReciter(reciters[index]['name']!);
                setSheetState(() {});
              },
              child: Container(
                width: 100.w,
                margin: EdgeInsets.only(right: 12.w),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF2E7D32),
                                    width: 2,
                                  )
                                : null,
                            image: DecorationImage(
                              image: AssetImage(reciters[index]['image']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4.w,
                            right: 4.w,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      reciters[index]['name']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildArabicScriptSelector(
    StateSetter setSheetState,
    SurahReadingController controller,
  ) {
    final arabicScripts = [
      {'name': 'IndoPak', 'sample': 'بِسْمِ اللّٰهِ'},
      {'name': 'Uthmani', 'sample': 'بِسْمِ اللّٰهِ'},
      {'name': 'No symbol', 'sample': 'بِسْمِ اللّٰهِ'},
      {'name': 'Compatible', 'sample': 'بِسْمِ اللّٰهِ'},
    ];

    return Obx(() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: const Color(0xFFDAE2D0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/icons/Layer_1.png',
                  width: 32.w,
                  height: 32.h,
                ),
                Text(
                  "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: controller.selectedScriptName.value == 'IndoPak'
                        ? 'IndoPak'
                        : 'Arial',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'arabic'.tr,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Row(
              children: List.generate(arabicScripts.length, (index) {
                final isSelected =
                    controller.selectedScriptName.value ==
                    arabicScripts[index]['name'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await controller.saveArabicScript(
                        arabicScripts[index]['name']!,
                      );
                      setSheetState(() {});
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 8.w : 0),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (isSelected)
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E7D32),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 10.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Text(
                            arabicScripts[index]['sample']!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontFamily:
                                  arabicScripts[index]['name'] == 'IndoPak'
                                  ? 'IndoPak'
                                  : 'Arial',
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            arabicScripts[index]['name']!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  void _showSurahSelector(
    BuildContext context,
    SurahReadingController controller,
  ) {
    final List<Map<String, dynamic>> surahs = StaticSurahData.getAllSurahs()
        .map(
          (s) => {
            "number": s.number,
            "name": s.englishName,
            "arabicName": s.arabicName,
            "ayaCount": s.totalVerses,
            "origin": s.revelationType,
            "translation": s.translation,
          },
        )
        .toList();
    String searchQuery = '';

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
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchQuery.trim().toLowerCase();
            final filteredSurahs = surahs.where((surah) {
              if (query.isEmpty) return true;
              final number = (surah['number'] ?? '').toString().toLowerCase();
              final name = (surah['name'] ?? '').toString().toLowerCase();
              final arabicName = (surah['arabicName'] ?? '')
                  .toString()
                  .toLowerCase();
              final translation = (surah['translation'] ?? '')
                  .toString()
                  .toLowerCase();

              return number.contains(query) ||
                  name.contains(query) ||
                  arabicName.contains(query) ||
                  translation.contains(query);
            }).toList();

            return Column(
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
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.grey[500],
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setModalState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'search_surah'.tr,
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14.sp,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Surah list
                Expanded(
                  child: filteredSurahs.isEmpty
                      ? Center(
                          child: Text(
                            'no_surahs_found'.tr,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: filteredSurahs.length,
                          itemBuilder: (context, index) {
                            final surah = filteredSurahs[index];
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
                                          surah['number'].toString(),
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
                                      surah['name'],
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
            );
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchSurahDetails(int surahId) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final url = Uri.parse('${Urls.quranSurahInfoEndpoint}$surahId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${token ?? ''}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[DEBUG] fetchSurahDetails error: $e');
    }
    return null;
  }

  void _showSurahInfoSheet(BuildContext context, Map<String, dynamic> surah) {
    final int surahNumber = surah['number'] ?? 1;
    final String arabicName = surah['arabicName'] ?? '';
    final int ayaCount = surah['ayaCount'] ?? 0;

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
        builder: (context, scrollController) => FutureBuilder<Map<String, dynamic>?>(
          future: _fetchSurahDetails(surahNumber),
          builder: (context, snapshot) {
            final details = snapshot.data;
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;

            return Column(
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
                if (isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
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
                              Expanded(
                                child: Text(
                                  (details?['name'] ?? surah['name'])
                                      .toString()
                                      .toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              FutureBuilder<String>(
                                future:
                                    SharedPreferencesHelper.getArabicScript(),
                                builder: (context, fontSnap) {
                                  final scriptFont = fontSnap.data ?? 'Imlaei';
                                  return Text(
                                    arabicName,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontFamily: scriptFont == 'IndoPak'
                                          ? 'IndoPak'
                                          : 'Arial',
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          // Info row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoColumn(
                                'meaning'.tr,
                                details?['meaning'] ??
                                    surah['translation'] ??
                                    '-',
                              ),
                              SizedBox(width: 24.w),
                              _buildInfoColumn(
                                'revelation'.tr,
                                details?['revelation'] ??
                                    surah['origin'] ??
                                    '-',
                              ),
                              SizedBox(width: 24.w),
                              _buildInfoColumn(
                                'aya'.tr,
                                '${details?['totalVerses'] ?? ayaCount} ${'aya'.tr}',
                              ),
                            ],
                          ),

                          SizedBox(height: 24.h),
                          Divider(color: Colors.grey[200]),
                          SizedBox(height: 16.h),

                          // Short Description
                          if ((details?['shortDescription'] ?? '').isNotEmpty)
                            Text(
                              details!['shortDescription'],
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                                height: 1.6,
                              ),
                            ),

                          if ((details?['shortDescription'] ?? '').isNotEmpty)
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
                                  'period_of_revelation'.tr,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  details?['periodOfRevelation'] ?? '-',
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

                          // Long Description / Theme
                          if ((details?['longDescription'] ?? '').isNotEmpty)
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
                                    'theme'.tr,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    details!['longDescription'],
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
            );
          },
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
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: AssetImage('assets/image/readmodecardBG.png'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
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
                "$ayaCount ${'aya'.tr}",
                style: TextStyle(fontSize: 11.sp, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Bismillah
          Image.asset(
            'assets/image/bismillah.png',
            width: 200.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 90.h),
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
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildViewTab("translation".tr, 0, controller),
              SizedBox(width: 12.w),
              _buildViewTab("transliteration".tr, 1, controller),
              SizedBox(width: 12.w),
              _buildViewTab("tafsir".tr, 2, controller),
            ],
          ),
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
            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text("no_verses_found".tr),
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
          return _buildVerseCard(verse, controller, context);
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text("no_verses_found".tr),
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
          return _buildTransliterationCard(verse, controller, context);
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
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text("no_tafsir_found".tr),
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
              "no_more_tafsir".tr,
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
              "load_more_tafsir".tr,
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
              "no_more_verses".tr,
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
              "load_more_verses".tr,
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
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchSurahDetails(surahId),
      builder: (context, snapshot) {
        final details = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        final name = details?['name'] ?? surahName;
        final revelation = details?['revelation'] ?? origin;
        final shortDescription = details?['shortDescription'] ?? '';
        final periodOfRevelation = details?['periodOfRevelation'] ?? '';
        final longDescription = details?['longDescription'] ?? '';

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "tafsir".tr,
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
                      "${'intro_to'.tr} ${name.toUpperCase()}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    if (revelation.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        "${'revealed_in'.tr} $revelation",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                    if (shortDescription.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        shortDescription,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                    if (periodOfRevelation.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        "${'period_of_revelation'.tr}: $periodOfRevelation",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (longDescription.isNotEmpty) ...[
                      SizedBox(height: 8.h),
                      Text(
                        longDescription,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  Widget _buildVerseCard(
    VerseDetailModel verse,
    SurahReadingController controller,
    BuildContext context,
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
                final isLoading =
                    controller.isAudioLoading.value &&
                    controller.loadingVerseId.value == verse.verseId;
                return GestureDetector(
                  onTap: isLoading
                      ? null
                      : () => controller.playVerse(verse.verseId),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF2E7D32),
                              ),
                            ),
                          )
                        : Icon(
                            isCurrent && isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: const Color(0xFF2E7D32),
                            size: 20.sp,
                          ),
                  ),
                );
              }),
              SizedBox(width: 12.w),
              // Arabic text with verse number
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.to(
                      () => QuranReadModeScreen(
                        surahName: surahName,
                        arabicName: arabicName,
                        meaning: meaning,
                        origin: origin,
                        ayaCount: ayaCount,
                        translation: translation,
                        verses: controller.verses,
                        controller: controller,
                      ),
                    );
                  },
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
                            child: Obx(() {
                              return Text(
                                verse.text,
                                style: TextStyle(
                                  fontSize: controller.fontSize.value.sp,
                                  fontFamily:
                                      controller.selectedScriptName.value ==
                                          'IndoPak'
                                      ? 'IndoPak'
                                      : 'Arial',
                                  height: 1.8,
                                ),
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
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
              GestureDetector(
                onTap: () => _showVerseOptionsMenu(context, verse, controller),
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.grey[500],
                  size: 20.sp,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _copyVerseInfo(verse),
                    child: Image.asset(
                      'assets/icons/1.solar_notes-outline.png',
                      width: 18.sp,
                      height: 18.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () => _showAddNoteDialog(
                      context,
                      verse.id,
                      verse.verseId,
                      verse.notes,
                      controller,
                    ),
                    child: Image.asset(
                      'assets/icons/2.solar_document-add-broken.png',
                      width: 18.sp,
                      height: 18.sp,
                      color: verse.notes.isNotEmpty
                          ? const Color(0xFF2E7D32)
                          : null,
                    ),
                  ),

                  SizedBox(width: 16.w),
                  Image.asset(
                    'assets/icons/3.iconoir_double-check.png',
                    width: 18.sp,
                    height: 18.sp,
                    color: verse.isVerseRead ? Colors.green : null,
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () => controller.toggleBookmark(verse.verseId),
                    child: Image.asset(
                      'assets/icons/4.material-symbols_bookmark-outline-rounded.png',
                      width: 18.sp,
                      height: 18.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showVerseOptionsMenu(
    BuildContext context,
    VerseDetailModel verse,
    SurahReadingController controller,
  ) {
    final TextEditingController askController = TextEditingController();

    void sendToAI() {
      final query = askController.text.trim();
      if (query.isEmpty) return;
      Navigator.pop(context);
      if (Get.isRegistered<AskAIController>()) {
        Get.delete<AskAIController>();
      }
      final aiController = Get.put(AskAIController());
      final contextMessage =
          'About $surahName, ${'aya'.tr} ${verse.verseId}: $query';
      aiController.messageController.text = contextMessage;
      aiController.showChat.value = true;
      Get.to(() => const AskAIScreen());
      Future.delayed(const Duration(milliseconds: 400), () {
        aiController.sendMessage();
      });
    }

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                ),
              ),
              SizedBox(height: 8.h),

              // Ask about this aya field
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: askController,
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                        onSubmitted: (_) => sendToAI(),
                        decoration: InputDecoration(
                          hintText: 'ask_about_aya'.tr,
                          hintStyle: TextStyle(
                            color: Colors.white70,
                            fontSize: 13.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        cursorColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: sendToAI,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Action buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildVerseOptionButton(
                    ctx,
                    icon: Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                    label: 'share'.tr,
                    onTap: () {
                      Navigator.pop(ctx);
                      // Share verse text
                    },
                  ),
                  _buildVerseOptionButton(
                    ctx,
                    icon: Image.asset(
                      'assets/icons/fi_15961848.png',
                      width: 26.sp,
                      height: 26.sp,
                      color: Colors.white,
                    ),
                    label: 'memorize'.tr,
                    onTap: () {
                      Navigator.pop(ctx);
                      if (Get.isRegistered<MemorizationController>()) {
                        Get.delete<MemorizationController>();
                      }
                      final memoController = Get.put(MemorizationController());
                      Get.to(() => const MemorizationScreen());
                      memoController.startPracticeSession(
                        surahId,
                        verse.verseId,
                      );
                    },
                  ),
                  _buildVerseOptionButton(
                    ctx,
                    icon: Icon(Icons.repeat, color: Colors.white, size: 26.sp),
                    label: 'repeat_verse'.tr,
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.playVerse(verse.verseId);
                    },
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseOptionButton(
    BuildContext context, {
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(
    BuildContext context,
    int id,
    int verseId,
    List<NoteModel> notes,
    SurahReadingController controller,
  ) {
    final bool hasNote = notes.isNotEmpty;
    final NoteModel? existingNote = hasNote ? notes.first : null;
    final TextEditingController noteController = TextEditingController(
      text: existingNote?.description ?? '',
    );
    final QuranService noteService = QuranService();
    bool isSaving = false;
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF2F7D33),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  children: [
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          'surah_aya'.trParams({
                            'surah': surahName,
                            'aya': verseId.toString(),
                          }),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          hasNote ? 'view_edit_note'.tr : 'add_note'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Text field
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white54, width: 1.2),
                  ),
                  child: TextField(
                    controller: noteController,
                    maxLines: 5,
                    minLines: 5,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'type_here'.tr,
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final text = noteController.text.trim();
                            if (text.isEmpty) return;
                            setState(() => isSaving = true);
                            final msg = await noteService.createNote(
                              description: text,
                              surahId: surahId,
                              verseId: verseId,
                              id: id,
                            );
                            setState(() => isSaving = false);
                            if (context.mounted) Navigator.pop(context);
                            if (msg != null) {
                              // Update verse notes in-memory so the UI refreshes
                              final updatedNote = NoteModel(
                                id: existingNote?.id ?? '',
                                title: 'surah_aya'.trParams({
                                  'surah': surahName,
                                  'aya': verseId.toString(),
                                }),
                                description: text,
                                surahId: surahId,
                                verseId: verseId,
                              );
                              controller.updateVerseNotes(verseId, [
                                updatedNote,
                              ]);
                              Get.snackbar(
                                'note_saved'.tr,
                                msg,
                                backgroundColor: const Color(0xFF2E7D32),
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } else {
                              Get.snackbar(
                                'error'.tr,
                                'failed_save_note'.tr,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      disabledBackgroundColor: Colors.white60,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2E7D32),
                            ),
                          )
                        : Text(
                            'save_note'.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                // Delete button — only shown when a note exists
                if (hasNote) ...[
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isDeleting
                          ? null
                          : () async {
                              setState(() => isDeleting = true);
                              final ok = await noteService.deleteNote(
                                existingNote!.id,
                              );
                              setState(() => isDeleting = false);
                              if (context.mounted) Navigator.pop(context);
                              if (ok) {
                                controller.updateVerseNotes(verseId, []);
                                Get.snackbar(
                                  'note_deleted'.tr,
                                  'note_removed_msg'.tr,
                                  backgroundColor: Colors.grey[800],
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else {
                                Get.snackbar(
                                  'error'.tr,
                                  'failed_delete_note'.tr,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.red.shade200,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 0,
                      ),
                      child: isDeleting
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'delete_note'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransliterationCard(
    VerseDetailModel verse,
    SurahReadingController controller,
    BuildContext context,
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
                final isLoading =
                    controller.isAudioLoading.value &&
                    controller.loadingVerseId.value == verse.verseId;
                return GestureDetector(
                  onTap: isLoading
                      ? null
                      : () => controller.playVerse(verse.verseId),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(50.r),
                      border: Border.all(color: Colors.grey[100]!),
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 24.sp,
                            height: 24.sp,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black87,
                              ),
                            ),
                          )
                        : Icon(
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
                      child: Obx(() {
                        return Text(
                          verse.text,
                          style: TextStyle(
                            fontSize: controller.fontSize.value.sp,
                            fontFamily:
                                controller.selectedScriptName.value == 'IndoPak'
                                ? 'IndoPak'
                                : 'Arial',
                            height: 1.8,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        );
                      }),
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
                  GestureDetector(
                    onTap: () => _copyVerseInfo(verse),
                    child: Image.asset(
                      'assets/icons/1.solar_notes-outline.png',
                      width: 18.sp,
                      height: 18.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () => _showAddNoteDialog(
                      context,
                      verse.id,
                      verse.verseId,
                      verse.notes,
                      controller,
                    ),
                    child: Image.asset(
                      'assets/icons/2.solar_document-add-broken.png',
                      width: 18.sp,
                      height: 18.sp,
                      color: verse.notes.isNotEmpty
                          ? const Color(0xFF2E7D32)
                          : null,
                    ),
                  ),

                  SizedBox(width: 16.w),
                  Image.asset(
                    'assets/icons/3.iconoir_double-check.png',
                    width: 18.sp,
                    height: 18.sp,
                    color: verse.isVerseRead ? Colors.green : null,
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () => controller.toggleBookmark(verse.verseId),
                    child: Image.asset(
                      'assets/icons/4.material-symbols_bookmark-outline-rounded.png',
                      width: 18.sp,
                      height: 18.sp,
                    ),
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
                child: Obx(() {
                  return Text(
                    tafsir.verse,
                    style: TextStyle(
                      fontSize: controller.fontSize.value.sp,
                      fontFamily:
                          controller.selectedScriptName.value == 'IndoPak'
                          ? 'IndoPak'
                          : 'Arial',
                      height: 1.8,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                  );
                }),
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
                "${'tafsir'.tr} - ${'aya'.tr} ${tafsir.verseId}",
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
                    onTap: controller.isAudioLoading.value
                        ? null
                        : () => controller.togglePlayPause(),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: controller.isAudioLoading.value
                          ? SizedBox(
                              width: 24.sp,
                              height: 24.sp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
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
              onTap: () {
                Get.delete<ListenModeController>();
                Get.to(
                  () => ListenModeScreen(
                    surahId: surahId,
                    surahName: surahName,
                    arabicName: arabicName,
                  ),
                );
              },
              child: Icon(
                Icons.more_horiz,
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
