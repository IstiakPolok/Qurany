import 'package:get/get.dart';
import 'package:qurany/feature/home/model/history_model.dart';
import 'package:qurany/feature/home/services/quran_service.dart';

class HistoryController extends GetxController {
  final QuranService _quranService = QuranService();
  final RxList<HistoryModel> historyList = <HistoryModel>[].obs;
  final RxList<BookmarkedHistoryModel> bookmarkedHistoryList =
      <BookmarkedHistoryModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingBookmarked = false.obs;
  final RxSet<String> bookmarkedIds = <String>{}.obs;
  final RxSet<String> bookmarkingIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    fetchBookmarkedHistory();
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
    final result = await _quranService.bookmarkHistoryAction(historyId);
    if (!result.success) {
      // Revert on failure
      if (wasBookmarked) {
        bookmarkedIds.add(historyId);
      } else {
        bookmarkedIds.remove(historyId);
      }
      Get.snackbar('Error', result.message);
    } else if (result.message.trim().isNotEmpty) {
      Get.snackbar('Success', result.message);
    }
    bookmarkingIds.remove(historyId);
    fetchBookmarkedHistory();
  }

  Future<void> fetchBookmarkedHistory() async {
    try {
      isLoadingBookmarked(true);
      final response = await _quranService.fetchBookmarkedHistory();
      bookmarkedHistoryList.assignAll(response);
      bookmarkedIds.assignAll(response.map((e) => e.history.id));
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch bookmarked stories: $e');
    } finally {
      isLoadingBookmarked(false);
    }
  }

  Future<void> removeBookmarkedHistory(String historyId) async {
    if (bookmarkingIds.contains(historyId)) return;

    final int index = bookmarkedHistoryList.indexWhere(
      (e) => e.history.id == historyId,
    );
    if (index == -1) return;

    bookmarkingIds.add(historyId);

    final item = bookmarkedHistoryList[index];
    bookmarkedHistoryList.removeAt(index);
    bookmarkedIds.remove(historyId);

    final result = await _quranService.deleteHistoryBookmarkAction(
      item.bookmarkId,
    );

    if (!result.success) {
      bookmarkedHistoryList.insert(index, item);
      bookmarkedIds.add(historyId);
      Get.snackbar('Error', result.message);
    } else if (result.message.trim().isNotEmpty) {
      Get.snackbar('Success', result.message);
    }

    bookmarkingIds.remove(historyId);
  }
}
