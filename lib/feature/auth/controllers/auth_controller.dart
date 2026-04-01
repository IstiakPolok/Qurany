import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/google_auth_service.dart';
import '../../../core/services/purchase_api.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';

class AuthController extends GetxController {
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    firebaseUser.bindStream(FirebaseAuth.instance.authStateChanges());

    // Sync with RevenueCat for webhook identification
    // Note: ProfileController also calls logIn with the definitive backend ID
    ever(firebaseUser, (User? user) {
      if (user != null) {
        // Fallback or early sync with Firebase UID
        PurchaseApi.logIn(user.uid);
      } else {
        _checkAndSyncGuest();
      }
    });

    // Initial sync
    _checkAndSyncGuest();
  }

  Future<void> _checkAndSyncGuest() async {
    if (firebaseUser.value != null) {
      PurchaseApi.logIn(firebaseUser.value!.uid);
      return;
    }

    // Check if guest is logged in
    final isLogin = await SharedPreferencesHelper.checkLogin();
    if (isLogin == true) {
      final email = await SharedPreferencesHelper.getEmail();
      if (email.isNotEmpty && email != 'me') {
        PurchaseApi.logIn(email);
      }
    } else {
      PurchaseApi.logOut();
    }
  }

  Future<bool> signInWithGoogle() async {
    return await GoogleSignInService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await GoogleSignInService.signOut();
  }

  bool get isSignedIn => firebaseUser.value != null;
}
