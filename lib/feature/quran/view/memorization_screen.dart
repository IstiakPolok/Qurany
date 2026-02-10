import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/core/const/static_surah_data.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/home/services/quran_service.dart';
import 'package:qurany/feature/quran/model/verse_detail_model.dart';
import 'package:qurany/feature/quran/services/memorization_service.dart';
import 'package:record/record.dart';

class MemorizationController extends GetxController {
  final MemorizationService _memorizationService = MemorizationService();

  // Stats Data
  final versesLearned = 0.obs;
  final avgAccuracy = 0.obs;
  final isLoading = false.obs;

  // Completed counts map: surahId -> totalCompleted
  final completedCounts = <int, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize surahList with all surahs
    _initializeSurahList();
    fetchStats();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    _player1.onPlayerComplete.listen((_) => _handlePlaybackComplete());
    _player2.onPlayerComplete.listen((_) => _handlePlaybackComplete());
  }

  void _handlePlaybackComplete() {
    _currentRepeatCount.value++;
    if (_currentRepeatCount.value < repeatCount.value) {
      _playCurrentVerse(isRepeat: true);
    } else {
      isPlayingAudio.value = false;
      _currentRepeatCount.value = 0;
    }
  }

  void _initializeSurahList() {
    final allSurahs = StaticSurahData.getAllSurahs();
    surahList.assignAll(
      allSurahs.map((surah) {
        return {
          "id": surah.number,
          "name": surah.englishName,
          "arabicName": surah.arabicName,
          "origin": surah.revelationType,
          "versesCount": "${surah.totalVerses} VERSES",
          "progress": "0 / ${surah.totalVerses} Aya",
          "verses": surah.totalVerses,
          "completed": false,
        };
      }).toList(),
    );
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      final accuracy = await _memorizationService.getAverageAccuracy();
      final verses = await _memorizationService.getCompletedVerses();
      final progressData = await _memorizationService.getCompletedSurahs();

      if (accuracy != null) {
        avgAccuracy.value = accuracy;
      }
      if (verses != null) {
        versesLearned.value = verses;
      }

      if (progressData != null) {
        final allSurahs = StaticSurahData.getAllSurahs();
        final List<Map<String, dynamic>> updatedProgress = [];

        for (var data in progressData) {
          final int surahId = int.tryParse(data['surahId'].toString()) ?? 0;
          final int totalCompleted =
              int.tryParse(data['totalCompleted'].toString()) ?? 0;

          completedCounts[surahId] = totalCompleted;

          try {
            final surah = allSurahs.firstWhere((s) => s.number == surahId);
            final double progress = totalCompleted / surah.totalVerses;

            updatedProgress.add({
              "surah": surah.englishName,
              "verses": "$totalCompleted/${surah.totalVerses} Aya",
              "progress": progress,
              "color": primaryColor,
            });

            // Update surahList entry as well
            final surahIndex = surahList.indexWhere((s) => s['id'] == surahId);
            if (surahIndex != -1) {
              final updatedSurah = Map<String, dynamic>.from(
                surahList[surahIndex],
              );
              updatedSurah["progress"] =
                  "$totalCompleted / ${surah.totalVerses} Aya";
              // Mark as completed if all verses are done
              updatedSurah["completed"] = totalCompleted >= surah.totalVerses;
              surahList[surahIndex] = updatedSurah;
            }
          } catch (e) {
            print('Surah not found for id: $surahId');
          }
        }
        progressList.assignAll(updatedProgress);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // State 0: Dashboard, 1: Selection, 2: Practice Session
  final currentStep = 0.obs;

  final expandedSurahIndex = (-1).obs; // -1 means none expanded

  final progressList = <Map<String, dynamic>>[].obs;

  // Surah Data for Selection
  final surahList = <Map<String, dynamic>>[].obs;

  // Practice Session Data
  final QuranService _quranService = QuranService();
  final AudioPlayer _player1 = AudioPlayer();
  final AudioPlayer _player2 = AudioPlayer();
  final RxInt _activePlayerIndex = 1.obs;

  AudioPlayer get _activePlayer =>
      _activePlayerIndex.value == 1 ? _player1 : _player2;
  AudioPlayer get _inactivePlayer =>
      _activePlayerIndex.value == 1 ? _player2 : _player1;

  final RxInt currentPracticeSurahId = 0.obs;
  final RxInt currentPracticeVerseIndex = 0.obs;
  final RxList<VerseDetailModel> practiceVerses = <VerseDetailModel>[].obs;
  final Rx<VerseDetailModel?> currentVerseModel = Rx<VerseDetailModel?>(null);
  final RxBool isPlayingAudio = false.obs;
  final RxBool isLoadingVerse = false.obs;
  final repeatCount = 3.obs;
  final RxInt _currentRepeatCount = 0.obs;

  // Recording Data
  final AudioRecorder _recorder = AudioRecorder();
  final RxBool isRecording = false.obs;
  final RxBool isAIProcessing = false.obs;
  String? _lastRecordingPath;

  @override
  void onClose() {
    _player1.dispose();
    _player2.dispose();
    _recorder.dispose();
    super.onClose();
  }

  void goToSelection() {
    currentStep.value = 1;
  }

  Future<void> startPracticeSession(int surahId, int verseId) async {
    currentPracticeSurahId.value = surahId;
    currentStep.value = 2;
    await _loadVerseForPractice(surahId, verseId);
  }

  Future<void> _loadVerseForPractice(int surahId, int verseNumber) async {
    try {
      isLoadingVerse.value = true;

      // Calculate which page this verse might be on (assuming 50 verses per page)
      int page = ((verseNumber - 1) ~/ 50) + 1;

      final response = await _quranService.fetchSurahById(
        surahId,
        page: page,
        limit: 50,
      );

      practiceVerses.assignAll(response.verses);

      // Find the index of the requested verse
      final index = practiceVerses.indexWhere((v) => v.verseId == verseNumber);
      if (index != -1) {
        currentPracticeVerseIndex.value = index;
        currentVerseModel.value = practiceVerses[index];
      } else if (practiceVerses.isNotEmpty) {
        currentPracticeVerseIndex.value = 0;
        currentVerseModel.value = practiceVerses[0];
      }
    } catch (e) {
      print("Error loading verse for practice: $e");
    } finally {
      isLoadingVerse.value = false;
    }
  }

  Future<void> togglePlayPause() async {
    if (practiceVerses.isEmpty) return;

    if (isPlayingAudio.value) {
      await _activePlayer.pause();
      isPlayingAudio.value = false;
    } else {
      await _playCurrentVerse();
    }
  }

  Future<void> _playCurrentVerse({bool isRepeat = false}) async {
    if (practiceVerses.isEmpty || currentVerseModel.value == null) return;

    if (!isRepeat) {
      _currentRepeatCount.value = 0;
    }

    try {
      if (!isRepeat) {
        await _player1.stop();
        await _player2.stop();
      }

      String? audioUrl = await _getAudioUrlForCurrentVerse();

      if (audioUrl != null) {
        await _activePlayer.setSourceUrl(audioUrl);
        await _activePlayer.resume();
        isPlayingAudio.value = true;
      }
    } catch (e) {
      print("Error playing verse: $e");
      isPlayingAudio.value = false;
    }
  }

  Future<void> nextVerse() async {
    if (currentPracticeVerseIndex.value < practiceVerses.length - 1) {
      currentPracticeVerseIndex.value++;
      currentVerseModel.value = practiceVerses[currentPracticeVerseIndex.value];

      if (isPlayingAudio.value) {
        await _playCurrentVerse();
      }
    }
  }

  Future<void> previousVerse() async {
    if (currentPracticeVerseIndex.value > 0) {
      currentPracticeVerseIndex.value--;
      currentVerseModel.value = practiceVerses[currentPracticeVerseIndex.value];

      if (isPlayingAudio.value) {
        await _playCurrentVerse();
      }
    }
  }

  Future<String?> _getAudioUrlForCurrentVerse() async {
    final verse = currentVerseModel.value;
    if (verse == null) return null;

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

  void stopAudio() {
    _player1.stop();
    _player2.stop();
    isPlayingAudio.value = false;
    _currentRepeatCount.value = 0;
  }

  void backToDashboard() {
    stopAudio();
    currentStep.value = 0;
  }

  void backToSelection() {
    stopAudio();
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

  Future<void> handleRecording() async {
    if (isRecording.value) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/recitation_${DateTime.now().millisecondsSinceEpoch}.wav';

        const config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          bitRate: 128000,
        );

        await _recorder.start(config, path: path);
        isRecording.value = true;
        _lastRecordingPath = path;
      } else {
        Get.snackbar("Permission Denied", "Microphone permission is required");
      }
    } catch (e) {
      print("Error starting record: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _recorder.stop();
      isRecording.value = false;

      if (path != null) {
        await _sendAudioToAI(path);
      }
    } catch (e) {
      print("Error stopping record: $e");
    }
  }

  Future<void> _sendAudioToAI(String path) async {
    if (currentVerseModel.value == null) return;

    isAIProcessing.value = true;
    try {
      final result = await _memorizationService.checkPronunciation(
        surahId: currentPracticeSurahId.value,
        verseId: currentVerseModel.value!.verseId,
        audioPath: path,
      );

      if (result != null) {
        _showResultsDialog(result);
        // Refresh stats to include new points
        fetchStats();
      } else {
        Get.snackbar("Error", "Failed to process pronunciation");
      }
    } finally {
      isAIProcessing.value = false;
    }
  }

  void _showResultsDialog(Map<String, dynamic> result) {
    final int accuracy = result['accuracy'] ?? 0;
    final int fluency = result['fluency'] ?? 0;
    final int completeness = result['completeness'] ?? 0;
    final String textSpoken = result['text_spoken'] ?? "";
    final List<dynamic> wordsDetails = result['words_details'] ?? [];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SingleChildScrollView(
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
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildResultScore("Accuracy", accuracy, primaryColor),
                  _buildResultScore("Fluency", fluency, Colors.blue),
                  _buildResultScore("Comp", completeness, Colors.redAccent),
                ],
              ),
              SizedBox(height: 32.h),
              Text(
                accuracy > 80 ? "Excellent Progress!" : "Keep Practicing!",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: accuracy > 80 ? primaryColor : Colors.redAccent,
                ),
              ),
              SizedBox(height: 16.h),
              if (wordsDetails.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Word-by-Word Analysis:",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  alignment: WrapAlignment.center,
                  children: wordsDetails.map((wordData) {
                    final String word = wordData['word'] ?? "";
                    final String errorType = wordData['error_type'] ?? "None";

                    Color wordColor;
                    if (errorType == "None") {
                      wordColor = primaryColor;
                    } else if (errorType == "Omission") {
                      wordColor = Colors.red;
                    } else {
                      wordColor = Colors.orange;
                    }

                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: wordColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: wordColor.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            word,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontFamily: "Amiri",
                              fontWeight: FontWeight.bold,
                              color: wordColor,
                            ),
                          ),
                          if (errorType != "None")
                            Text(
                              errorType,
                              style: TextStyle(
                                fontSize: 8.sp,
                                color: wordColor,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
              ],
              Text(
                "Full Transcription:",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                textSpoken,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: "Amiri",
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
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
                        nextVerse();
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

  Widget _buildResultScore(String label, int score, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60.w,
              height: 60.w,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 5,
                color: color,
                backgroundColor: CupertinoColors.inactiveGray,
              ),
            ),
            Text(
              "$score%",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
        ),
      ],
    );
  }
}

class MemorizationScreen extends StatelessWidget {
  const MemorizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MemorizationController controller = Get.put(MemorizationController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (controller.currentStep.value == 2) {
          controller.backToSelection();
        } else if (controller.currentStep.value == 1) {
          controller.backToDashboard();
        } else {
          // If we are at dashboard, we allow the pop
          controller.stopAudio();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
          Obx(
            () => controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : _buildStatsCards(controller),
          ),
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
          child: Obx(
            () => ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: controller.surahList.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final surah = controller.surahList[index];
                return _buildExpandableSurahCard(controller, surah, index);
              },
            ),
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
    return Obx(() {
      final isExpanded = controller.expandedSurahIndex.value == index;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
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
    });
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
          final isSelected =
              verseNum <= (controller.completedCounts[surahId] ?? 0);

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
          child: Obx(() {
            if (controller.isLoadingVerse.value) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }

            final verse = controller.currentVerseModel.value;
            if (verse == null) {
              return const Center(child: Text("No verse loaded"));
            }

            return Container(
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
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${verse.verseId}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            verse.text, // arabic text
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
                            verse.transliteration,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            verse.translation,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Player Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => controller.previousVerse(),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 18.sp,
                          color: controller.currentPracticeVerseIndex.value > 0
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 24.w),
                      GestureDetector(
                        onTap: () => controller.togglePlayPause(),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            controller.isPlayingAudio.value
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 32.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 24.w),
                      GestureDetector(
                        onTap: () => controller.nextVerse(),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 18.sp,
                          color:
                              controller.currentPracticeVerseIndex.value <
                                  controller.practiceVerses.length - 1
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
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
              Obx(
                () => GestureDetector(
                  onTap: controller.isAIProcessing.value
                      ? null
                      : controller.handleRecording,
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
                        if (controller.isAIProcessing.value)
                          SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black87,
                            ),
                          )
                        else ...[
                          Icon(
                            controller.isRecording.value
                                ? Icons.stop
                                : Icons.mic,
                            color: controller.isRecording.value
                                ? Colors.red
                                : Colors.black87,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            controller.isRecording.value
                                ? "Stop Recording"
                                : "Start Recording",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: controller.isRecording.value
                                  ? Colors.red
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
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
