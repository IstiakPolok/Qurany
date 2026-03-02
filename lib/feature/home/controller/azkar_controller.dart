import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/home/model/azkar_model.dart';
import 'package:qurany/feature/home/services/quran_service.dart';

class AzkarController extends GetxController {
  final QuranService _quranService = QuranService();

  var allAzkar = <AzkarGroupModel>[].obs; // Changed to GroupModel
  var azkarGroup = <AzkarItem>[].obs; // Changed to AzkarItem
  var isLoading = true.obs;
  var isLoadingGroup = false.obs;
  var isLoadingBookmarks = false.obs;

  final RxSet<String> bookmarkedAzkarGroupIds = <String>{}.obs;
  final RxSet<String> bookmarkingAzkarGroupIds = <String>{}.obs;
  final RxMap<String, String> bookmarkedAzkarGroupBookmarkIds =
      <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    print("🏠 AzkarController initialized");
    fetchAllAzkar();
    fetchBookmarkedAzkarGroups();
  }

  Future<void> fetchBookmarkedAzkarGroups() async {
    isLoadingBookmarks(true);
    try {
      final map = await _quranService.fetchAzkarBookmarkedGroupIdToBookmarkId();
      bookmarkedAzkarGroupBookmarkIds
        ..clear()
        ..addAll(map);

      bookmarkedAzkarGroupIds
        ..clear()
        ..addAll(map.keys);
    } catch (e) {
      print('❌ Error fetching bookmarked azkar groups: $e');
    } finally {
      isLoadingBookmarks(false);
    }
  }

  Future<void> fetchAllAzkar() async {
    try {
      isLoading(true);
      final response = await _quranService.fetchAzkar();
      allAzkar.assignAll(response);
    } catch (e) {
      print("❌ Error fetching all azkar: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAzkarByGroup(String time) async {
    try {
      isLoadingGroup(true);
      azkarGroup.clear();
      final response = await _quranService.fetchAzkarByGroup(time);
      azkarGroup.assignAll(response);
    } catch (e) {
      print("❌ Error fetching azkar group: $e");
    } finally {
      isLoadingGroup(false);
    }
  }

  // Get unique titles with their representative data for the list view
  List<Map<String, dynamic>> get uniqueAzkarGroups {
    return allAzkar
        .map(
          (group) => {
            'id': group.id,
            'title': group.name,
            'time': group.time,
            'duration': group.duration,
            'image': group.image ?? '',
          },
        )
        .toList();
  }

  Future<void> bookmarkAzkarGroup(String azkarGroupId) async {
    if (azkarGroupId.isEmpty) return;
    if (bookmarkingAzkarGroupIds.contains(azkarGroupId)) return;

    try {
      bookmarkingAzkarGroupIds.add(azkarGroupId);
      final existingBookmarkId = bookmarkedAzkarGroupBookmarkIds[azkarGroupId];

      // If already bookmarked -> delete the bookmark record
      if (existingBookmarkId != null && existingBookmarkId.isNotEmpty) {
        final result = await _quranService.deleteAzkarBookmark(
          existingBookmarkId,
        );
        if (result.success) {
          bookmarkedAzkarGroupBookmarkIds.remove(azkarGroupId);
          bookmarkedAzkarGroupIds.remove(azkarGroupId);
          await fetchBookmarkedAzkarGroups();
        }

        Get.snackbar(
          'Bookmark',
          result.success ? 'Removed from bookmark' : result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: result.success ? Colors.green : Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Not bookmarked -> create bookmark
      final result = await _quranService.bookmarkAzkarGroup(azkarGroupId);
      if (result.success) {
        bookmarkedAzkarGroupIds.add(azkarGroupId);
        await fetchBookmarkedAzkarGroups();
      }

      if (result.message.isNotEmpty) {
        Get.snackbar(
          'Bookmark',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: result.success ? Colors.green : Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error bookmarking azkar group: $e');
    } finally {
      bookmarkingAzkarGroupIds.remove(azkarGroupId);
    }
  }
}
