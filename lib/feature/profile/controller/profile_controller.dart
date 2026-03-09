import 'package:get/get.dart';
import '../model/user_model.dart';
import '../services/profile_service.dart';
import 'package:file_picker/file_picker.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUploadingAvatar = false.obs;
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

  Future<void> pickAndUploadAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // ensure bytes are always loaded (required on Android)
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;

      isUploadingAvatar(true);
      UserModel? updated;

      if (file.path != null) {
        // Desktop / iOS path is available
        updated = await _profileService.uploadAvatar(file.path!);
      } else if (file.bytes != null) {
        // Android content URI — only bytes are available
        final filename = file.name.isNotEmpty ? file.name : 'avatar.jpg';
        updated = await _profileService.uploadAvatarBytes(
          file.bytes!.toList(),
          filename,
        );
      }

      if (updated != null) {
        user.value = updated;
        // ignore: avoid_print
        print('[DEBUG] Avatar uploaded: ${updated.avatarUrl}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error picking/uploading avatar: $e');
    } finally {
      isUploadingAvatar(false);
    }
  }
}
