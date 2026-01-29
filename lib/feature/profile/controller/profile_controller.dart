import 'package:get/get.dart';
import '../model/user_model.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      error('');
      final result = await _profileService.getProfile();
      if (result != null) {
        user.value = result;
      } else {
        error('Failed to load profile');
      }
    } catch (e) {
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
