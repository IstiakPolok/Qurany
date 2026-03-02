import 'package:get/get.dart';
import 'package:qurany/feature/home/model/random_verse_model.dart';
import 'package:qurany/feature/home/services/quran_service.dart';

class VerseOfDayController extends GetxController {
  final QuranService _quranService = QuranService();

  final Rx<RandomVerseResponse?> randomVerse = Rx<RandomVerseResponse?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  final RxnString aiReflection = RxnString();
  final RxBool isAiReflectionLoading = false.obs;
  final RxString aiReflectionErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRandomVerse();
  }

  Future<void> fetchRandomVerse() async {
    try {
      isLoading(true);
      errorMessage('');
      aiReflection.value = null;
      aiReflectionErrorMessage('');
      final response = await _quranService.fetchRandomVerse();
      randomVerse.value = response;

      await _fetchAiReflectionForVerse(
        surahId: response.data.verse.surahId,
        verseId: response.data.verse.verseId,
      );
    } catch (e) {
      errorMessage('Failed to load verse: $e');
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
    await fetchRandomVerse();
  }
}
