import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qurany/feature/profile/controller/profile_controller.dart';
import 'package:qurany/feature/profile/services/profile_service.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

enum ReviewStep {
  rating,
  feedback,
  playStoreReview,
  appStoreReview,
  appStoreNickname,
}

class ReviewService {
  static void showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ReviewDialog(),
    );
  }
}

class ReviewDialog extends StatefulWidget {
  const ReviewDialog({super.key});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  ReviewStep _currentStep = ReviewStep.rating;
  int _selectedRating = 0;
  bool _isSending = false;

  // Controllers
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _playStoreReviewController =
      TextEditingController();
  final TextEditingController _appStoreTitleController =
      TextEditingController();
  final TextEditingController _appStoreReviewController =
      TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  String _userName = '';
  int _playStoreCharCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _playStoreReviewController.addListener(() {
      setState(() {
        _playStoreCharCount = _playStoreReviewController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _playStoreReviewController.dispose();
    _appStoreTitleController.dispose();
    _appStoreReviewController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    // 1. Try to load from SharedPreferences cache
    final cachedName = await SharedPreferencesHelper.getName();
    if (cachedName.trim().isNotEmpty) {
      setState(() {
        _userName = cachedName.trim();
        _nicknameController.text = _userName;
      });
    }

    String? dynamicName;

    // 2. Try to get from ProfileController
    try {
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        dynamicName = profileController.user.value?.fullName;
        if ((dynamicName == null || dynamicName.trim().isEmpty) &&
            !profileController.isLoading.value) {
          await profileController.fetchProfile();
          dynamicName = profileController.user.value?.fullName;
        }
      }
    } catch (_) {}

    // 3. Try to get from ProfileService
    if (dynamicName == null || dynamicName.trim().isEmpty) {
      try {
        final profileService = ProfileService();
        final profile = await profileService.getProfile();
        dynamicName = profile?.fullName;
      } catch (_) {}
    }

    // 4. Update state if found and save to cache
    if (dynamicName != null && dynamicName.trim().isNotEmpty) {
      setState(() {
        _userName = dynamicName!.trim();
        _nicknameController.text = _userName;
      });
      await SharedPreferencesHelper.saveName(_userName);
    } else if (_userName.isEmpty) {
      // Fallback default
      setState(() {
        _userName = 'Muhammad Ismael';
        _nicknameController.text = _userName;
      });
    }
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      Get.snackbar(
        'Rating Required',
        'Please select stars to rate.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (_selectedRating == 5) {
      // 5-star rating -> Trigger Simulated Store Review (using the Play Store styled dialog for both Android and iOS)
      setState(() {
        _currentStep = ReviewStep.playStoreReview;
      });
    } else {
      // 1-4 star rating -> Transition to Feedback View
      setState(() {
        _currentStep = ReviewStep.feedback;
      });
    }
  }

  Future<void> _sendFeedback() async {
    final feedbackText = _feedbackController.text.trim();
    if (feedbackText.isEmpty) {
      Get.snackbar(
        'Feedback Required',
        'Please share your thoughts/suggestions.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('app_feedback').add({
        'userId': user?.uid ?? 'guest',
        'rating': _selectedRating,
        'feedback': feedbackText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Thank You!',
        'Your feedback was successfully submitted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: primaryColor,
        colorText: Colors.white,
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error saving feedback: $e");
      Get.snackbar(
        'Thank You!',
        'Your feedback was successfully submitted.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: primaryColor,
        colorText: Colors.white,
      );
      Navigator.pop(context);
    }
  }

  // Play Store Review Submission
  Future<void> _submitPlayStoreReview() async {
    final reviewText = _playStoreReviewController.text.trim();
    setState(() {
      _isSending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('play_store_reviews').add({
        'userId': user?.uid ?? 'guest',
        'userName': _userName,
        'rating': 5,
        'review': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error writing Play Store review: $e");
    }

    Get.snackbar(
      'Review Posted!',
      'Thank you for your 5-star review!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: primaryColor,
      colorText: Colors.white,
    );

    Navigator.pop(context);

    // Call native requestReview as final touch
    try {
      final isAvailable = await InAppReview.instance.isAvailable();
      if (isAvailable) {
        await InAppReview.instance.requestReview();
      }
    } catch (_) {}
  }

  // App Store Review Submission (First part: trigger Nickname)
  void _submitAppStoreReview() {
    setState(() {
      _currentStep = ReviewStep.appStoreNickname;
    });
  }

  // App Store Final Submission
  Future<void> _submitAppStoreFinalReview() async {
    final reviewTitle = _appStoreTitleController.text.trim();
    final reviewText = _appStoreReviewController.text.trim();
    final nickname = _nicknameController.text.trim();

    setState(() {
      _isSending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('app_store_reviews').add({
        'userId': user?.uid ?? 'guest',
        'nickname': nickname,
        'rating': 5,
        'title': reviewTitle,
        'review': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error writing App Store review: $e");
    }

    Get.snackbar(
      'Review Sent!',
      'Thank you for supporting Qurany!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: primaryColor,
      colorText: Colors.white,
    );

    Navigator.pop(context);

    // Call native requestReview as final touch
    try {
      final isAvailable = await InAppReview.instance.isAvailable();
      if (isAvailable) {
        await InAppReview.instance.requestReview();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == ReviewStep.playStoreReview) {
      return _buildPlayStoreDialog();
    }
    if (_currentStep == ReviewStep.appStoreReview) {
      return _buildAppStoreDialog();
    }
    if (_currentStep == ReviewStep.appStoreNickname) {
      return _buildAppStoreNicknameDialog();
    }

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

              if (_currentStep == ReviewStep.rating)
                _buildRatingLayout()
              else
                _buildFeedbackLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingLayout() {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Text(
          "Help Spread the Word of Allah",
          textAlign: TextAlign.center,
          style: GoogleFonts.abhayaLibre(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          "Help us bring the Holy Quran to more screens around the world. A glowing review boosts our app and helps millions more find peace through the Quran daily.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, color: subheading, height: 1.5),
        ),
        SizedBox(height: 24.h),

        // Stars
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              final isSelected = starNumber <= _selectedRating;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = starNumber;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Icon(
                    isSelected
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 42.sp,
                    color: const Color(0xFFFFC107), // Gold/Amber star color
                  ),
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 28.h),

        // Submit Button
        GestureDetector(
          onTap: _submitRating,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "Submit",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Remind me later
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Remind me later",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: subheading,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildFeedbackLayout() {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Text(
          "We're Sorry 😟",
          textAlign: TextAlign.center,
          style: GoogleFonts.abhayaLibre(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          "We're sorry you aren't having a 5-star experience. How can we improve?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, color: subheading, height: 1.5),
        ),
        SizedBox(height: 20.h),

        // Feedback Input
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: TextField(
            controller: _feedbackController,
            maxLines: 4,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Please share your thoughts and suggestions...",
              hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey[400]),
              border: InputBorder.none,
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Send Feedback Button
        GestureDetector(
          onTap: _isSending ? null : _sendFeedback,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _isSending
                  ? SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Send Feedback",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),

        SizedBox(height: 16.h),

        // Back Button
        GestureDetector(
          onTap: () {
            setState(() {
              _currentStep = ReviewStep.rating;
            });
          },
          child: Text(
            "Back",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: subheading,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  // ----------------------------------------------------
  // PLAY STORE SIMULATED POPUP
  // ----------------------------------------------------
  Widget _buildPlayStoreDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[800],
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Image.asset(
                      'assets/icons/logo.png',
                      width: 36.w,
                      height: 36.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 36.w,
                        height: 36.w,
                        color: primaryColor,
                        child: const Icon(Icons.star, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Qurany",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Your Spiritual Companion",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSending ? null : _submitPlayStoreReview,
                    child: Text(
                      "Post",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // User Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: primaryColor,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Reviews are public and include your account and device info. Learn more",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20.h),

              // Gold Star rating
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: 28.sp,
                      color: const Color(0xFFFFC107),
                    ),
                  );
                }),
              ),

              SizedBox(height: 20.h),

              // Text Box input
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: primaryColor, width: 1.5),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                child: TextField(
                  controller: _playStoreReviewController,
                  maxLines: 5,
                  maxLength: 500,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: "Describe your experience (optional)",
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    counterText: "",
                  ),
                ),
              ),

              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  "$_playStoreCharCount/500",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ),

              if (_isSending)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // APP STORE SIMULATED POPUP
  // ----------------------------------------------------
  Widget _buildAppStoreDialog() {
    return Dialog(
      backgroundColor: const Color(
        0xFFF2F2F7,
      ), // iOS System light gray background
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    "Write a Review",
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: _submitAppStoreReview,
                    child: Text(
                      "Send",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Interactive iOS Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      Icons.star_rounded,
                      size: 36.sp,
                      color: const Color(0xFFFFC107),
                    ),
                  );
                }),
              ),
              SizedBox(height: 4.h),
              Text(
                "Tap a star to rate",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
              ),

              SizedBox(height: 24.h),

              // Fields container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: TextField(
                        controller: _appStoreTitleController,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Title",
                          hintStyle: TextStyle(color: Colors.black26),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 0),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: TextField(
                        controller: _appStoreReviewController,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Review (Optional)",
                          hintStyle: TextStyle(color: Colors.black26),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  // APP STORE SIMULATED NICKNAME POPUP
  Widget _buildAppStoreNicknameDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 32.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close header
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: Colors.black38, size: 20.sp),
              ),
            ),

            Text(
              "Enter a Nickname",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Your nickname will be displayed next to any reviews you write.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black54,
                height: 1.3,
              ),
            ),

            SizedBox(height: 16.h),

            // Input Nickname
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: primaryColor, width: 1.5),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: TextField(
                controller: _nicknameController,
                style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Buttons Row
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 16.sp, color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 1, height: 44, child: VerticalDivider()),
                Expanded(
                  child: TextButton(
                    onPressed: _isSending ? null : _submitAppStoreFinalReview,
                    child: _isSending
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "OK",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
