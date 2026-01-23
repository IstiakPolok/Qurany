import 'package:get/get.dart';
import 'package:qurany/feature/home/model/random_verse_model.dart';
import 'package:qurany/feature/home/services/quran_service.dart';

class VerseOfDayController extends GetxController {
  final QuranService _quranService = QuranService();

  final Rx<RandomVerseResponse?> randomVerse = Rx<RandomVerseResponse?>(null);
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRandomVerse();
  }

  Future<void> fetchRandomVerse() async {
    try {
      isLoading(true);
      errorMessage('');
      final response = await _quranService.fetchRandomVerse();
      randomVerse.value = response;
    } catch (e) {
      errorMessage('Failed to load verse: $e');
      print('Error in VerseOfDayController: $e');
    } finally {
      isLoading(false);
    }
  }

  // Helper method to get surah name
  String getSurahName() {
    if (randomVerse.value == null) return 'Unknown';
    return SurahNames.getSurahName(
      randomVerse.value!.data.verse.surahId,
      lang: 'en',
    );
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
