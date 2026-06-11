import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:qurany/core/network_caller/network_error_handler.dart';
import 'package:qurany/core/services/notification_service.dart';
import 'package:qurany/feature/home/model/random_verse_model.dart';
import 'package:qurany/feature/home/services/quran_service.dart';

class VerseOfDayController extends GetxController {
  final QuranService _quranService = QuranService();
  final AudioPlayer audioPlayer = AudioPlayer();
  final NotificationService _notificationService = NotificationService();

  final Rx<RandomVerseResponse?> randomVerse = Rx<RandomVerseResponse?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxnString aiReflection = RxnString();
  final RxBool isAiReflectionLoading = false.obs;
  final RxString aiReflectionErrorMessage = ''.obs;

  final RxnString currentlyPlayingUrl = RxnString();

  // List of random background images
  final List<String> _bgImages = [
    'assets/image/Verse of the Day 2.png',
    'assets/image/Verse of the Day 3.png',
    'assets/image/Verse of the Day 4.png',
    'assets/image/Verse of the Day 5.png',
    'assets/image/Verse of the Day 6.png',
    'assets/image/Verse of the Day 7.png',
    'assets/image/VerseOfDayCard.png',
  ];

  // Selected background image
  final RxString backgroundImage = ''.obs;

  void _setRandomBackgroundImage() {
    final List<String> shuffled = List.from(_bgImages)..shuffle();
    backgroundImage.value = shuffled.first;
  }

  @override
  void onInit() {
    super.onInit();
    _setRandomBackgroundImage();
    fetchRandomVerse();

    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
      currentlyPlayingUrl.value = null;
    }
    });
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }

  Future<void> toggleAudio(String url) async {
    if (currentlyPlayingUrl.value == url) {
      await audioPlayer.pause();
      currentlyPlayingUrl.value = null;
    } else {
      await audioPlayer.stop(); // Stop any previous audio
      await audioPlayer.setUrl(url);
          await audioPlayer.play();
      currentlyPlayingUrl.value = url;
    }
  }

  Future<void> fetchRandomVerse() async {
    try {
      isLoading(true);
      errorMessage('');
      aiReflection.value = null;
      aiReflectionErrorMessage('');
      final response = await _quranService.fetchRandomVerse();
      randomVerse.value = response;

      // Show notification for verse of the day
      _notificationService.showInstantNotification(
        id: 100, // Unique ID for Verse
        title: 'Verse of the Day',
        body:
            '"${response.data.verse.ayate}" [${response.data.verse.transliteration} ${response.data.verse.verseId}]',
      );

      await _fetchAiReflectionForVerse(
        surahId: response.data.verse.surahId,
        verseId: response.data.verse.verseId,
      );
    } on NoInternetException {
      errorMessage('No internet connection');
    } on MaintenanceException {
      errorMessage('App is under maintenance');
    } catch (e) {
      if (NetworkErrorHandler.isNoInternetError(e)) {
        errorMessage('No internet connection');
      } else {
        errorMessage('Failed to load verse: $e');
      }
      print('Error in VerseOfDayController: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _fetchAiReflectionForVerse({
    required int surahId,
    required int verseId,
  }) async {
    try {
      isAiReflectionLoading(true);
      aiReflectionErrorMessage('');
      final reflection = await _quranService.fetchAiVerseReflection(
        surahId: surahId,
        verseId: verseId,
      );
      aiReflection.value = reflection;
    } catch (e) {
      aiReflectionErrorMessage('Failed to load reflection: $e');
      print('Error fetching AI reflection: $e');
    } finally {
      isAiReflectionLoading(false);
    }
  }

  // Helper method to get surah name
  String getSurahName() {
    if (randomVerse.value == null) return 'Unknown';
    return randomVerse.value!.data.verse.transliteration;
  }

  // Helper method to get verse reference
  String getVerseReference() {
    if (randomVerse.value == null) return '';
    final surahName = getSurahName();
    final verseId = randomVerse.value!.data.verse.verseId;
    return '$surahName ($verseId)';
  }

  // Refresh verse
  Future<void> refreshVerse() async {
    _setRandomBackgroundImage();
    await fetchRandomVerse();
  }
}
