import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/home/services/quran_service.dart';
import 'package:qurany/feature/quran/model/verse_detail_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/const/static_surah_data.dart';

/// Controller for Listen Mode (Commuter Mode) screen
class ListenModeController extends GetxController {
  final int surahId;
  ListenModeController({required this.surahId});

  final QuranService _quranService = QuranService();
  final AudioPlayer _player1 = AudioPlayer();
  final AudioPlayer _player2 = AudioPlayer();
  final RxInt _activePlayerIndex = 1.obs;

  AudioPlayer get _activePlayer =>
      _activePlayerIndex.value == 1 ? _player1 : _player2;
  AudioPlayer get _inactivePlayer =>
      _activePlayerIndex.value == 1 ? _player2 : _player1;

  final stt.SpeechToText _speech = stt.SpeechToText();

  RxInt currentVerseIndex = 0.obs;
  RxBool isPlaying = false.obs;
  RxString currentSurahName = 'AL-FATIHAH'.obs;
  RxInt totalVerses = 0.obs;
  RxBool isLoading = true.obs;
  RxBool isLoadingMore = false.obs;
  RxInt currentPage = 1.obs;
  RxBool hasMoreVerses = true.obs;

  // Voice Command State
  RxBool isListening = false.obs;
  RxString commandStatus = "Tap for Voice Command".obs;
  RxBool isSpeechAvailable = false.obs;

  var verses = <VerseDetailModel>[].obs;
  Rx<VerseDetailModel?> currentVerseModel = Rx<VerseDetailModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _setTotalVerses();
    _configureAudioSession();
    _initSpeech();
    fetchSurahDetails();

    _setupPlayerListeners(_player1);
    _setupPlayerListeners(_player2);

    // Update currentVerseModel when index or verses change
    ever(currentVerseIndex, (_) => _updateCurrentVerse());
    ever(verses, (_) => _updateCurrentVerse());
  }

  void _setupPlayerListeners(AudioPlayer player) {
    player.onPlayerStateChanged.listen((state) {
      if (player == _activePlayer) {
        isPlaying.value = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          nextVerse();
        }
      }
    });
  }

  void _setTotalVerses() {
    try {
      final surah = StaticSurahData.getAllSurahs().firstWhere(
        (s) => s.number == surahId,
      );
      totalVerses.value = surah.totalVerses;
      currentSurahName.value = surah.englishName.toUpperCase();
    } catch (e) {
      print("Error setting total verses: $e");
    }
  }

  Future<void> _configureAudioSession() async {
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playAndRecord,
        options: const {
          AVAudioSessionOptions.defaultToSpeaker,
          AVAudioSessionOptions.mixWithOthers,
          AVAudioSessionOptions.allowBluetooth,
          AVAudioSessionOptions.allowBluetoothA2DP,
          AVAudioSessionOptions.allowAirPlay,
        },
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
    );
    await _player1.setAudioContext(audioContext);
    await _player2.setAudioContext(audioContext);
  }

  Future<void> _initSpeech() async {
    try {
      // Check microphone permission first
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        await Permission.microphone.request();
      }

      isSpeechAvailable.value = await _speech.initialize(
        onStatus: (status) {
          if (status == 'listening') {
            isListening.value = true;
            commandStatus.value = "Listening...";
          } else if (status == 'notListening') {
            isListening.value = false;
            if (commandStatus.value == "Listening...") {
              commandStatus.value = "Tap for Voice Command";
            }
          }
        },
        onError: (errorNotification) {
          isListening.value = false;
          commandStatus.value = "Error: ${errorNotification.errorMsg}";
          print("Speech Error: ${errorNotification.errorMsg}");
        },
      );
    } catch (e) {
      print("Speech initialization error: $e");
    }
  }

  void listenForCommand() async {
    if (!isSpeechAvailable.value) {
      await _initSpeech();
      if (!isSpeechAvailable.value) {
        commandStatus.value = "Speech recognition not available";
        return;
      }
    }

    if (isListening.value) {
      _speech.stop();
      isListening.value = false;
      commandStatus.value = "Tap for Voice Command";
    } else {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _processCommand(result.recognizedWords);
          }
        },
      );
    }
  }

  void _processCommand(String command) {
    String lowerCommand = command.toLowerCase();
    commandStatus.value = "Command: $command";

    if (lowerCommand.contains("next") || lowerCommand.contains("skip")) {
      nextVerse();
    } else if (lowerCommand.contains("previous") ||
        lowerCommand.contains("back")) {
      previousVerse();
    } else if (lowerCommand.contains("pause") ||
        lowerCommand.contains("stop")) {
      if (isPlaying.value) togglePlayPause();
    } else if (lowerCommand.contains("play") ||
        lowerCommand.contains("resume") ||
        lowerCommand.contains("start")) {
      if (!isPlaying.value) togglePlayPause();
    } else if (lowerCommand.contains("repeat") ||
        lowerCommand.contains("again")) {
      _playCurrentVerse();
    }

    // Reset status after a delay
    Future.delayed(const Duration(seconds: 2), () {
      commandStatus.value = "Tap for Voice Command";
    });
  }

  void _updateCurrentVerse() {
    if (verses.isNotEmpty &&
        currentVerseIndex.value >= 0 &&
        currentVerseIndex.value < verses.length) {
      currentVerseModel.value = verses[currentVerseIndex.value];
    } else {
      currentVerseModel.value = null;
    }
  }

  @override
  void onClose() {
    _player1.dispose();
    _player2.dispose();
    super.onClose();
  }

  Future<void> fetchSurahDetails() async {
    try {
      isLoading(true);
      currentPage.value = 1;
      final response = await _quranService.fetchSurahById(
        surahId,
        page: currentPage.value,
        limit: 50,
      );
      verses.assignAll(response.verses);
      hasMoreVerses.value = verses.length < totalVerses.value;
    } catch (e) {
      print("Error fetching surah for listen mode: $e");
    } finally {
      isLoading(false);
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
        limit: 50,
      );

      if (response.verses.isNotEmpty) {
        verses.addAll(response.verses);
        hasMoreVerses.value = verses.length < totalVerses.value;
      } else {
        hasMoreVerses.value = false;
      }
    } catch (e) {
      print("Error loading more verses: $e");
      currentPage.value--;
    } finally {
      isLoadingMore(false);
    }
  }

  Future<void> togglePlayPause() async {
    if (verses.isEmpty) return;

    if (isPlaying.value) {
      await _activePlayer.pause();
    } else {
      // If nothing is playing, play current index
      await _playCurrentVerse();
    }
  }

  Future<void> nextVerse() async {
    if (currentVerseIndex.value < verses.length - 1) {
      currentVerseIndex.value++;
      // Pre-fetch if we're near the end of current list
      if (currentVerseIndex.value >= verses.length - 5) {
        loadMoreVerses();
      }

      // If the inactive player has preloaded the next verse, switch and play
      _activePlayerIndex.value = _activePlayerIndex.value == 1 ? 2 : 1;
      await _activePlayer.resume();

      // Preload the following one
      _preloadNextVerse(currentVerseIndex.value);
    } else if (hasMoreVerses.value) {
      // Reached the end but more are available, load and then play
      await loadMoreVerses();
      if (currentVerseIndex.value < verses.length - 1) {
        currentVerseIndex.value++;
        await _playCurrentVerse();
      }
    } else {
      // Loop or stop? Stop for now.
      isPlaying.value = false;
    }
  }

  Future<void> previousVerse() async {
    if (currentVerseIndex.value > 0) {
      currentVerseIndex.value--;
      await _playCurrentVerse();
    }
  }

  Future<void> _playCurrentVerse() async {
    if (verses.isEmpty) return;

    try {
      // Stop all players before starting fresh point
      await _player1.stop();
      await _player2.stop();

      String? audioUrl = await _getAudioUrlForVerse(currentVerseIndex.value);

      if (audioUrl != null) {
        await _activePlayer.setSourceUrl(audioUrl);
        await _activePlayer.resume();

        // Preload next
        _preloadNextVerse(currentVerseIndex.value);
      }
    } catch (e) {
      print("Error playing verse in listen mode: $e");
    }
  }

  Future<void> _preloadNextVerse(int index) async {
    if (index < verses.length - 1) {
      String? nextUrl = await _getAudioUrlForVerse(index + 1);
      if (nextUrl != null) {
        await _inactivePlayer.setSourceUrl(nextUrl);
      }
    }
  }

  Future<String?> _getAudioUrlForVerse(int index) async {
    if (index < 0 || index >= verses.length) return null;
    final verse = verses[index];

    try {
      String preferredReciterName = await SharedPreferencesHelper.getReciter();
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

  String _mapReciterNameToKey(String name) {
    if (name.contains("Mishary")) return "mishary";
    if (name.contains("Abu Bakr")) return "abuBakar";
    if (name.contains("Nasser")) return "nasser";
    if (name.contains("Yasser")) return "yasser";
    return "mishary";
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
  final int surahId;
  final String surahName;
  final String arabicName;

  const ListenModeScreen({
    super.key,
    required this.surahId,
    required this.surahName,
    required this.arabicName,
  });

  @override
  Widget build(BuildContext context) {
    final ListenModeController controller = Get.put(
      ListenModeController(surahId: surahId),
    );

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
            surahName, // Use widget parameter or controller.currentSurahName
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
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      final verse = controller.currentVerseModel.value;
      if (verse == null) {
        return const Center(
          child: Text("No verses found", style: TextStyle(color: Colors.white)),
        );
      }

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
                child: Text(
                  verse.ayate,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      verse.text,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontFamily: 'Arial',
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
                        verse.transliteration,
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
                        verse.translation,
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
    return Obx(
      () => GestureDetector(
        onTap: () => controller.listenForCommand(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 40.w),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: controller.isListening.value
                ? Colors.redAccent
                : Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              if (controller.isListening.value)
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.isListening.value ? Icons.mic : Icons.mic_none,
                color: controller.isListening.value
                    ? Colors.white
                    : Colors.black87,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  controller.commandStatus.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: controller.isListening.value
                        ? Colors.white
                        : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
