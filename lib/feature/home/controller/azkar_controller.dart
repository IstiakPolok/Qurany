import 'package:get/get.dart';
import 'package:qurany/feature/home/model/azkar_model.dart';
import 'package:qurany/feature/home/services/quran_service.dart';

class AzkarController extends GetxController {
  final QuranService _quranService = QuranService();

  var allAzkar = <AzkarModel>[].obs;
  var azkarGroup = <AzkarModel>[].obs;
  var isLoading = true.obs;
  var isLoadingGroup = false.obs;

  @override
  void onInit() {
    super.onInit();
    print("🏠 AzkarController initialized");
    fetchAllAzkar();
  }

  Future<void> fetchAllAzkar() async {
    try {
      isLoading(true);
      print("📡 Fetching all Azkar...");
      final response = await _quranService.fetchAzkar();
      print("✅ Fetched ${response.length} Azkar items");
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
      print("Error fetching azkar group: $e");
    } finally {
      isLoadingGroup(false);
    }
  }

  // Get unique titles with their representative data for the list view
  List<Map<String, dynamic>> get uniqueAzkarGroups {
    final groups = <String, AzkarModel>{};
    for (var azkar in allAzkar) {
      // Use time as group key, fallback to name if time is missing
      final groupKey = azkar.time.isNotEmpty
          ? azkar.time
          : (azkar.name.isNotEmpty ? azkar.name : "Azkar");
      if (!groups.containsKey(groupKey)) {
        groups[groupKey] = azkar;
      }
    }
    return groups.entries
        .map(
          (e) => {
            'title': e.key,
            'time': e.value.time,
            'duration': e.value.duration,
            'image': e.value.image,
          },
        )
        .toList();
  }
}
