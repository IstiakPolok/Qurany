import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/google_auth_service.dart';
import '../../../core/services/purchase_api.dart';

class AuthController extends GetxController {
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    firebaseUser.bindStream(FirebaseAuth.instance.authStateChanges());

    // Sync with RevenueCat for webhook identification
    ever(firebaseUser, (User? user) {
      if (user != null) {
        PurchaseApi.logIn(user.uid);
      } else {
        PurchaseApi.logOut();
      }
    });
  }

  Future<bool> signInWithGoogle() async {
    return await GoogleSignInService.signInWithGoogle();
  }

  Future<void> signOut() async {
    await GoogleSignInService.signOut();
  }

  bool get isSignedIn => firebaseUser.value != null;
}
