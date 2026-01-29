import 'package:get/get.dart';
import '../model/knowledge_model.dart';
import '../services/knowledge_service.dart';

class KnowledgeController extends GetxController {
  final KnowledgeService _knowledgeService = KnowledgeService();

  final RxList<KnowledgeModel> knowledgeList = <KnowledgeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKnowledgeItems();
  }

  Future<void> fetchKnowledgeItems() async {
    try {
      isLoading(true);
      error('');
      final items = await _knowledgeService.getKnowledgeItems();
      knowledgeList.assignAll(items);
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
