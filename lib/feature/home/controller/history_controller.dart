import 'package:get/get.dart';
import 'package:qurany/feature/home/model/history_model.dart';
import 'package:qurany/feature/home/services/quran_service.dart';

class HistoryController extends GetxController {
  final QuranService _quranService = QuranService();
  var historyList = <HistoryModel>[].obs;
  var isLoading = true.obs;
  final RxSet<String> bookmarkedIds = <String>{}.obs;
  final RxSet<String> bookmarkingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading(true);
      final response = await _quranService.fetchHistory();
      historyList.assignAll(response);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch history: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> toggleBookmark(String historyId) async {
    if (bookmarkingIds.contains(historyId)) return;
    bookmarkingIds.add(historyId);
    final wasBookmarked = bookmarkedIds.contains(historyId);
    // Optimistic update
    if (wasBookmarked) {
      bookmarkedIds.remove(historyId);
    } else {
      bookmarkedIds.add(historyId);
    }
    final success = await _quranService.bookmarkHistory(historyId);
    if (!success) {
      // Revert on failure
      if (wasBookmarked) {
        bookmarkedIds.add(historyId);
      } else {
        bookmarkedIds.remove(historyId);
      }
      Get.snackbar('Error', 'Failed to bookmark story');
    }
    bookmarkingIds.remove(historyId);
  }
}
