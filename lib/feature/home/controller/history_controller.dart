import 'package:get/get.dart';
import 'package:qurany/feature/home/model/history_model.dart';
import 'package:qurany/feature/home/services/quran_service.dart';

class HistoryController extends GetxController {
  final QuranService _quranService = QuranService();
  var historyList = <HistoryModel>[].obs;
  var isLoading = true.obs;

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
}
