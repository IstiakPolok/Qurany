import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/core/const/static_surah_data.dart';
import 'package:qurany/core/services/notification_service.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/home/services/quran_service.dart';
import 'package:qurany/feature/quran/model/verse_detail_model.dart';
import 'package:qurany/feature/quran/services/memorization_service.dart';
import 'package:record/record.dart';
import 'package:qurany/core/services/purchase_api.dart';
import 'package:qurany/core/services/usage_service.dart';

class MemorizationController extends GetxController {
  final MemorizationService _memorizationService = MemorizationService();

  static const String _logTag = 'MEMO';
  void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('$_logTag: $message');
  }

  void _logError(String message, Object error, StackTrace stackTrace) {
    if (!kDebugMode) return;
    debugPrint('$_logTag ERROR: $message -> $error');
    debugPrint(stackTrace.toString());
  }

  // Stats Data
  final versesLearned = 0.obs;
  final avgAccuracy = 0.obs;
  final isLoading = false.obs;

  // Completed counts map: surahId -> totalCompleted
  final completedCounts = <int, int>{}.obs;

  final RxInt practiceUsageCount = 0.obs;
  final RxInt practiceCap = 3.obs;

  Future<void> refreshUsageCount() async {
    final userId = UsageService.getActiveUserId();
    practiceUsageCount.value = await UsageService.getUsageCount(userId, 'practice_session');
    final caps = await UsageService.getCaps();
    practiceCap.value = caps['practice_session'] ?? 3;
  }

  @override
  void onInit() {
    super.onInit();
    _log('onInit');
    // Initialize surahList with all surahs
    _initializeSurahList();
    _log('Initialized surahList: ${surahList.length}');
    fetchStats();
    _setupAudioListeners();
    refreshUsageCount();
  }

  void _setupAudioListeners() {
    _log('Setting up audio listeners');
    _player1.onPlayerComplete.listen((_) => _handlePlaybackComplete());
    _player2.onPlayerComplete.listen((_) => _handlePlaybackComplete());
  }

  void _handlePlaybackComplete() {
    _currentRepeatCount.value++;
    _log(
      'Playback complete. repeat=${_currentRepeatCount.value}/${repeatCount.value}',
    );
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
          "versesCount": "${surah.totalVerses} ${'verses'.tr}",
          "progress": "0 / ${surah.totalVerses} ${'aya'.tr}",
          "verses": surah.totalVerses,
          "completed": false,
        };
      }).toList(),
    );
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    _log('fetchStats: start');
    try {
      final accuracy = await _memorizationService.getAverageAccuracy();
      final verses = await _memorizationService.getCompletedVerses();
      final progressData = await _memorizationService.getCompletedSurahs();

      _log(
        'fetchStats: raw values accuracy=$accuracy versesLearned=$verses progressData=${progressData?.length ?? 0}',
      );

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
              "verses": "$totalCompleted/${surah.totalVerses} ${'aya'.tr}",
              "progress": progress,
              "color": primaryColor,
              "surahId": surahId,
              "totalCompleted": totalCompleted,
            });

            // Update surahList entry as well
            final surahIndex = surahList.indexWhere((s) => s['id'] == surahId);
            if (surahIndex != -1) {
              final updatedSurah = Map<String, dynamic>.from(
                surahList[surahIndex],
              );
              updatedSurah["progress"] =
                  "$totalCompleted / ${surah.totalVerses} ${'aya'.tr}";
              // Mark as completed if all verses are done
              updatedSurah["completed"] = totalCompleted >= surah.totalVerses;
              surahList[surahIndex] = updatedSurah;
            }
          } catch (e) {
            _log('Surah not found for id: $surahId');
          }
        }
        progressList.assignAll(updatedProgress);
      }
    } catch (e, st) {
      _logError('fetchStats failed', e, st);
    } finally {
      isLoading.value = false;
      _log(
        'fetchStats: done avgAccuracy=${avgAccuracy.value} versesLearned=${versesLearned.value} progressItems=${progressList.length}',
      );
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
  final Rx<Map<String, dynamic>?> aiResult = Rx<Map<String, dynamic>?>(null);

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
    final isPremium = PurchaseApi.isUserPremium();
      if (!isPremium) {
        final userId = UsageService.getActiveUserId();
        final count = await UsageService.getUsageCount(userId, 'practice_session');
      final caps = await UsageService.getCaps();
      final cap = caps['practice_session'] ?? 3;

      if (count >= cap) {
        // Present paywall
        await PurchaseApi.presentPaywallIfNeededForPlacement('practice_session');
        // Update status
        await PurchaseApi.updatePremiumStatus();
        if (!PurchaseApi.isUserPremium()) {
          // block start
          Get.snackbar(
            'Premium Required',
            'You have reached your weekly limit of free practice sessions.',
            backgroundColor: Colors.orange[800],
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }
    }

    // Increment usage on session start (only if not premium)
    if (!PurchaseApi.isUserPremium()) {
      final userId = UsageService.getActiveUserId();
      UsageService.incrementUsage(userId, 'practice_session').then((_) {
        refreshUsageCount();
      }).catchError((e) {
        debugPrint('[Memorization] Error incrementing usage: $e');
      });
    }

    _log('startPracticeSession: surahId=$surahId verseId=$verseId');
    currentPracticeSurahId.value = surahId;
    currentStep.value = 2;
    await _loadVerseForPractice(surahId, verseId);
  }

  Future<void> _loadVerseForPractice(int surahId, int verseNumber) async {
    try {
      isLoadingVerse.value = true;

      // Calculate which page this verse might be on (assuming 50 verses per page)
      int page = ((verseNumber - 1) ~/ 50) + 1;

      _log('loadVerse: surahId=$surahId verse=$verseNumber page=$page');

      final response = await _quranService.fetchSurahById(
        surahId,
        page: page,
        limit: 50,
      );

      practiceVerses.assignAll(response.verses);

      _log('loadVerse: fetched verses=${practiceVerses.length} (limit=50)');

      // Find the index of the requested verse
      final index = practiceVerses.indexWhere((v) => v.verseId == verseNumber);
      if (index != -1) {
        currentPracticeVerseIndex.value = index;
        currentVerseModel.value = practiceVerses[index];
        _log('loadVerse: set current index=$index verseId=$verseNumber');
      } else if (practiceVerses.isNotEmpty) {
        currentPracticeVerseIndex.value = 0;
        currentVerseModel.value = practiceVerses[0];
        _log(
          'loadVerse: verseId=$verseNumber not found in page=$page, defaulting to first verseId=${practiceVerses[0].verseId}',
        );
      } else {
        _log('loadVerse: response had no verses');
      }
    } catch (e, st) {
      _logError('Error loading verse for practice', e, st);
    } finally {
      isLoadingVerse.value = false;
    }
  }

  Future<void> togglePlayPause() async {
    if (practiceVerses.isEmpty) return;

    if (isPlayingAudio.value) {
      _log('togglePlayPause: pausing');
      await _activePlayer.pause();
      isPlayingAudio.value = false;
    } else {
      _log('togglePlayPause: playing current verse');
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
      } else {
        await _activePlayer.stop();
      }

      String? audioUrl = await _getAudioUrlForCurrentVerse();

      _log(
        'playVerse: verseId=${currentVerseModel.value?.verseId} isRepeat=$isRepeat url=${audioUrl == null ? 'null' : 'ok'}',
      );

      if (audioUrl != null) {
        await _activePlayer.play(UrlSource(audioUrl));
        isPlayingAudio.value = true;
      }
    } catch (e, st) {
      _logError('Error playing verse', e, st);
      isPlayingAudio.value = false;
    }
  }

  Future<void> nextVerse() async {
    if (currentPracticeVerseIndex.value < practiceVerses.length - 1) {
      currentPracticeVerseIndex.value++;
      currentVerseModel.value = practiceVerses[currentPracticeVerseIndex.value];

      _log(
        'nextVerse: index=${currentPracticeVerseIndex.value} verseId=${currentVerseModel.value?.verseId}',
      );

      if (isPlayingAudio.value) {
        await _playCurrentVerse();
      }
    }
  }

  Future<void> previousVerse() async {
    if (currentPracticeVerseIndex.value > 0) {
      currentPracticeVerseIndex.value--;
      currentVerseModel.value = practiceVerses[currentPracticeVerseIndex.value];

      _log(
        'previousVerse: index=${currentPracticeVerseIndex.value} verseId=${currentVerseModel.value?.verseId}',
      );

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

      _log('audio: preferredReciter="$preferredReciterName" key=$audioKey');

      if (verse.audio.containsKey(audioKey)) {
        _log('audio: using preferred key=$audioKey');
        return verse.audio[audioKey]?.url;
      } else if (verse.audio.isNotEmpty) {
        _log('audio: preferred key missing, using first available');
        return verse.audio.values.first.url;
      }
    } catch (e, st) {
      _logError('Error getting audio URL', e, st);
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
    _log('stopAudio');
    _player1.stop();
    _player2.stop();
    isPlayingAudio.value = false;
    _currentRepeatCount.value = 0;
  }

  void backToDashboard() {
    _log('backToDashboard');
    stopAudio();
    currentStep.value = 0;
    refreshUsageCount();
  }

  void backToSelection() {
    _log('backToSelection');
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
    _log('setRepeatCount: $count');
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

        _log('startRecording: path=$path');

        const config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          bitRate: 128000,
        );

        await _recorder.start(config, path: path);
        isRecording.value = true;
      } else {
        _log('startRecording: permission denied');
        Get.snackbar("memo_perm_denied".tr, "memo_mic_perm_required".tr);
      }
    } catch (e, st) {
      _logError('Error starting record', e, st);
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await _recorder.stop();
      isRecording.value = false;

      _log('stopRecording: path=${path ?? 'null'}');

      if (path != null) {
        await _sendAudioToAI(path);
      }
    } catch (e, st) {
      _logError('Error stopping record', e, st);
    }
  }

  Future<void> _sendAudioToAI(String path) async {
    if (currentVerseModel.value == null) return;

    isAIProcessing.value = true;
    try {
      _log(
        'sendAudioToAI: surahId=${currentPracticeSurahId.value} verseId=${currentVerseModel.value?.verseId} path=$path',
      );
      final result = await _memorizationService.checkPronunciation(
        surahId: currentPracticeSurahId.value,
        verseId: currentVerseModel.value!.verseId,
        audioPath: path,
      );

      if (result != null) {
        _log(
          'AI result: accuracy=${result['accuracy']} fluency=${result['fluency']} completeness=${result['completeness']}',
        );
        aiResult.value = result;
        currentStep.value = 3;
        // Refresh stats to include new points
        fetchStats();
        // Track daily memorized verse
        SharedPreferencesHelper.incrementDailyMemorized();
      } else {
        _log('AI result: null');
        Get.snackbar("error".tr, "memo_fail_pronunciation".tr);
      }
    } catch (e, st) {
      _logError('sendAudioToAI failed', e, st);
      Get.snackbar("error".tr, "memo_fail_pronunciation".tr);
    } finally {
      isAIProcessing.value = false;
    }
  }

  void _showResultsDialog(Map<String, dynamic> result) {
    // Deprecated for the new review screen feature
  }
}

class MemorizationScreen extends StatelessWidget {
  const MemorizationScreen({super.key});

  void _showDailyPracticeReminderDialog(BuildContext context) {
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final timeText = selectedTime == null
                ? 'memo_select_time'.tr
                : selectedTime!.format(context);

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3EEE4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none,
                        size: 28.sp,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'daily_practice_reminder'.tr,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'memo_set_daily_time'.tr,
                      style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });

                          await NotificationService()
                              .requestNotificationPermission();
                          await NotificationService()
                              .scheduleDailyMemorizationReminder(
                                hour: picked.hour,
                                minute: picked.minute,
                              );
                          await SharedPreferencesHelper.saveDailyPracticeReminderTime(
                            picked.format(context),
                          );

                          if (context.mounted) {
                            Get.snackbar(
                              'memo_reminder_set'.tr,
                              'memo_reminder_desc'.trParams({
                                'time': picked.format(context),
                              }),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                timeText,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: selectedTime == null
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.access_time,
                              color: Colors.grey.shade600,
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MemorizationController controller = Get.put(MemorizationController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (controller.currentStep.value == 3) {
          controller.currentStep.value = 2; // Back to practice
        } else if (controller.currentStep.value == 2) {
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
        backgroundColor: const Color(0xFFFFFAF3),
        body: SafeArea(
          child: Obx(() {
            if (controller.currentStep.value == 0) {
              return _buildDashboard(context, controller);
            } else if (controller.currentStep.value == 1) {
              return _buildSelectionScreen(context, controller);
            } else if (controller.currentStep.value == 2) {
              return _buildPracticeSession(context, controller);
            } else {
              return _buildReviewSession(context, controller);
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
          _buildHeader(context, "memorization".tr),
          SizedBox(height: 24.h),
          Obx(
            () => controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : _buildStatsCards(controller),
          ),
          SizedBox(height: 24.h),
          Obx(() {
            final isPremium = PurchaseApi.isUserPremium();
            if (!isPremium && controller.practiceUsageCount.value == controller.practiceCap.value - 1) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  "1 free session left this week",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          _buildStartPracticeButton(controller),
          SizedBox(height: 32.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "memo_your_progress".tr,
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
            "memo_practice_session".tr,
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
                            fontSize: 10.sp,
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
    if (totalVerses <= 15) {
      // For 15 or fewer verses, show them in a static grid (5 columns = up to 3 rows)
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalVerses,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12.w,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final verseNum = index + 1;
          return _buildVerseItem(controller, surahId, verseNum);
        },
      );
    }

    // For more than 15 verses, show horizontal scrolling with 3 fixed rows
    return SizedBox(
      height: 180.w, // Approx 60.w per row
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalVerses,
        padding: EdgeInsets.symmetric(vertical: 4.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12.w,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final verseNum = index + 1;
          return _buildVerseItem(controller, surahId, verseNum);
        },
      ),
    );
  }

  Widget _buildVerseItem(
    MemorizationController controller,
    int surahId,
    int verseNum,
  ) {
    final isSelected = verseNum <= (controller.completedCounts[surahId] ?? 0);

    return GestureDetector(
      onTap: () => controller.startPracticeSession(surahId, verseNum),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : bgColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
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
  }

  Widget _buildStepIndicator(MemorizationController controller) {
    return Obx(() {
      final isReview = controller.currentStep.value == 3;
      final isPracticing =
          controller.isRecording.value || controller.isAIProcessing.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStepItem(
              icon: Icons.volume_up,
              label: "Listen",
              active: !isPracticing && !isReview,
              completed: isPracticing || isReview,
            ),
            _buildStepConnector(active: isPracticing || isReview),
            _buildStepItem(
              icon: Icons.mic_none,
              label: "Practice",
              active: isPracticing && !isReview,
              completed: isReview,
            ),
            _buildStepConnector(active: isReview),
            _buildStepItem(
              icon: Icons.check,
              label: "Review",
              active: isReview,
              completed:
                  false, // Maybe completing review later? Or active is enough.
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStepItem({
    required IconData icon,
    required String label,
    required bool active,
    required bool completed,
  }) {
    Color color = active || completed ? const Color(0xFF2E7D32) : Colors.grey;
    return Column(
      children: [
        ClipPath(
          clipper: HexagonClipper(),
          child: Container(
            width: 44.sp,
            height: 48.sp,
            decoration: BoxDecoration(
              color: active || completed ? color : Colors.white,
            ),
            child: Icon(
              completed ? icon : icon,
              color: active || completed ? Colors.white : color,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: color,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 16.h),
        color: active ? const Color(0xFF2E7D32) : Colors.grey.withOpacity(0.3),
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
            "Listen",
            isPractice: true,
            onBack: controller.backToSelection,
          ),
        ),
        SizedBox(height: 16.h),
        _buildStepIndicator(controller),
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
              return Center(child: Text("memo_no_verse_loaded".tr));
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
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "${verse.verseId}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                          SizedBox(height: 16.h),
                          Text(
                            verse.transliteration,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
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
                  // Player Controls
                  Obx(() {
                    if (controller.isRecording.value ||
                        controller.isAIProcessing.value) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 16.h),
                        Center(
                          child: GestureDetector(
                            onTap: () => controller.togglePlayPause(),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
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
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          }),
        ),

        // Repeat Count
        Obx(() {
          if (controller.isRecording.value || controller.isAIProcessing.value) {
            return SizedBox(height: 24.h);
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 24.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5EE),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Text(
                      "Repeat Count",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    _buildRepeatToggle(controller, 1),
                    _buildRepeatToggle(controller, 3),
                    _buildRepeatToggle(controller, 5),
                    _buildRepeatToggle(controller, 7),
                  ],
                ),
              ),
            ],
          );
        }),

        SizedBox(height: 16.h),

        // AI Voice Recognition
        Obx(() {
          final isRecording = controller.isRecording.value;
          final isProcessing = controller.isAIProcessing.value;

          return GestureDetector(
            onTap: (isRecording || isProcessing)
                ? controller.handleRecording
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(
                vertical: isRecording || isProcessing ? 40.h : 20.h,
                horizontal: 20.w,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                ),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isProcessing
                        ? "Processing..."
                        : (isRecording
                              ? "Recording Now"
                              : "Are you ready to practice?"),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isRecording || isProcessing ? 20.sp : 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isProcessing
                        ? "Checking your recitation..."
                        : (isRecording
                              ? "Recite the verse clearly"
                              : "Begin your recitation by tapping below and grow\nwith every verse"),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isRecording || isProcessing ? 14.sp : 11.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (isRecording || isProcessing) ...[
                    SizedBox(height: 32.h),
                    if (isProcessing)
                      SizedBox(
                        height: 40.h,
                        width: 40.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    else ...[
                      const WaveformAnimation(),
                    ],
                    SizedBox(height: 16.h),
                    Text(
                      "Tap to Stop",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10.sp,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: controller.isAIProcessing.value
                          ? null
                          : controller.handleRecording,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic_none,
                              color: Colors.black87,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Start Practicing",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildReviewSession(
    BuildContext context,
    MemorizationController controller,
  ) {
    return Obx(() {
      final result = controller.aiResult.value;
      if (result == null) {
        return const Center(
          child: CircularProgressIndicator(color: primaryColor),
        );
      }

      final int accuracy = result['accuracy'] ?? 0;
      final int fluency = result['fluency'] ?? 0;
      final int completeness = result['completeness'] ?? 0;
      final List<dynamic> wordsDetails = result['words_details'] ?? [];

      int wordsToReview = 0;
      int extraWords = 0;

      for (var word in wordsDetails) {
        final String errorType = word['error_type'] ?? "None";
        if (errorType != "None" && errorType != "Insertion") {
          wordsToReview++;
        } else if (errorType == "Insertion") {
          extraWords++;
        }
      }

      final isExcellent = accuracy > 80;

      return Column(
        children: [
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildHeader(
              context,
              "Your Recitation Journey",
              isPractice: true,
              onBack: () {
                controller.currentStep.value =
                    2; // Go back to practice manually
              },
            ),
          ),
          SizedBox(height: 16.h),
          _buildStepIndicator(controller),
          SizedBox(height: 24.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Text(
                    isExcellent ? "Excellent Progress!" : "Keep practicing!",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Keep practicing to improve your accuracy.",
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 24.h),

                  // Stats overview (accuracy, fluency)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildResultScore(
                        "memo_accuracy".tr,
                        accuracy,
                        primaryColor,
                      ),
                      _buildResultScore(
                        "memo_fluency".tr,
                        fluency,
                        Colors.blue,
                      ),
                      _buildResultScore(
                        "memo_completeness".tr,
                        completeness,
                        Colors.orange,
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Areas for Growth Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                            horizontal: 16.w,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF388E3C), // Dark green header
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              topRight: Radius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            "Areas for Growth",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 20.h,
                            horizontal: 16.w,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$wordsToReview",
                                      style: TextStyle(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(
                                          0xFFD84315,
                                        ), // Deep orange/red
                                      ),
                                    ),
                                    Text(
                                      "Words to Review",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: 40.h,
                                width: 1,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 24.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "$extraWords",
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2E7D32),
                                        ),
                                      ),
                                      Text(
                                        "Extra Words",
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Mispronounced Words Cards
                  if (wordsToReview > 0) ...[
                    ...wordsDetails
                        .where(
                          (w) =>
                              w['error_type'] != null &&
                              w['error_type'] != 'None' &&
                              w['error_type'] != 'Insertion',
                        )
                        .map((wordData) {
                          final String word = wordData['word'] ?? "";
                          return Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            word,
                                            style: TextStyle(
                                              fontSize: 24.sp,
                                              fontFamily: "Amiri",
                                              color: const Color(0xFFD84315),
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "You said ",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(4.w),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE8F5E9),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.volume_up,
                                                  size: 14.sp,
                                                  color: const Color(
                                                    0xFF2E7D32,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 60.h,
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            word,
                                            style: TextStyle(
                                              fontSize: 24.sp,
                                              fontFamily: "Amiri",
                                              color: const Color(0xFF2E7D32),
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Listen to the correct ",
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(4.w),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE8F5E9),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.volume_up,
                                                  size: 14.sp,
                                                  color: const Color(
                                                    0xFF2E7D32,
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
                                SizedBox(height: 16.h),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE8F5E9,
                                    ).withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    "Make sure to pronounce it correctly and practice more.", // Generic tip for the word
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                        .toList(),
                  ],

                  SizedBox(height: 16.h),

                  // Tips for Next Time
                  if (wordsToReview > 0 || extraWords > 0) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: const Color(0xFF2E7D32),
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "Tips for Next Time",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTipBullet(
                            "It looks like some words are a bit tricky today.",
                          ),
                          SizedBox(height: 6.h),
                          _buildTipBullet(
                            "Try listening to the verse a few more times before practicing again.",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  Text(
                    "memo_full_transcription".tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    result['text_spoken'] ?? "",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: "Amiri",
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            controller.currentStep.value = 2; // Try Again
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: Text(
                            "Try Again",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.currentStep.value = 2;
                            controller.nextVerse();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Next Verse",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      );
    });
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

  Widget _buildTipBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h, right: 8.w, left: 4.w),
          child: Container(
            width: 4.w,
            height: 4.w,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressItem(
    Map<String, dynamic> item,
    MemorizationController controller,
  ) {
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
                GestureDetector(
                  onTap: () {
                    final int surahId = item['surahId'] as int? ?? 1;
                    final int totalCompleted =
                        item['totalCompleted'] as int? ?? 0;
                    final int nextVerse = totalCompleted > 0
                        ? totalCompleted
                        : 1;
                    controller.startPracticeSession(surahId, nextVerse);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      "continue".tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildRepeatToggle(MemorizationController controller, int count) {
    return GestureDetector(
      onTap: () => controller.setRepeatCount(count),
      child: Obx(
        () => Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: controller.repeatCount.value == count
                ? const Color(0xFF2E7D32)
                : Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            "${count}x",
            style: TextStyle(
              fontSize: 12.sp,
              color: controller.repeatCount.value == count
                  ? Colors.white
                  : Colors.grey[700],
              fontWeight: controller.repeatCount.value == count
                  ? FontWeight.bold
                  : FontWeight.normal,
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
              GestureDetector(
                onTap: () => _showDailyPracticeReminderDialog(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Icon(
                    Icons.notifications_none,
                    size: 20.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildStatsCards(MemorizationController controller) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => PurchaseApi.presentPaywallIfNeededForPlacement('premium_feature'),
            child: _buildStatCard(
              title: "memo_verses_learned".tr,
              value: "${controller.versesLearned.value}",
              icon: Icons.check_circle_outline,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: GestureDetector(
            onTap: () => PurchaseApi.presentPaywallIfNeededForPlacement('premium_feature'),
            child: _buildStatCard(
              title: "memo_avg_accuracy".tr,
              value: "${controller.avgAccuracy.value}%",
              icon: Icons.trending_up,
            ),
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
              "memo_start_practice".tr,
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
          return _buildProgressItem(item, controller);
        },
      ),
    );
  }
}

// Reusable Hexagon clipper if not already imported
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

class WaveformAnimation extends StatefulWidget {
  const WaveformAnimation({super.key});

  @override
  State<WaveformAnimation> createState() => _WaveformAnimationState();
}

class _WaveformAnimationState extends State<WaveformAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(20, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Using different phases for each bar to create a wave effect
            final double t = _controller.value;
            final double phase = index * 0.4;
            // Height between 10 and 40 based on sine wave
            final double height =
                10 + 30 * math.sin((t * math.pi * 2) + phase).abs();

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: 5.w,
              height: height.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(3.r),
              ),
            );
          },
        );
      }),
    );
  }
}
