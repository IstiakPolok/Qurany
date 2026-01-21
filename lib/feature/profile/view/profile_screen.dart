import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:qurany/feature/auth/views/login_options_screen.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../../auth/services/google_auth_service.dart';
import 'appearance_settings_screen.dart';
import 'bookmarks_screen.dart';
import 'downlaod_reciters_screen.dart';
import 'edit_profile_screen.dart';
import 'invite_friends_screen.dart';
import 'notes_screen.dart';
import 'notifications_settings_screen.dart';
import 'premium_plan_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: Column(
        children: [
          // Header with green background

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  // Support Mission Card
                  _buildSupportMissionCard(),

                  SizedBox(height: 24.h),

                  // Settings Section
                  _buildSettingsSection(context),

                  SizedBox(height: 16.h),

                  // Other Options Section
                  _buildOtherOptionsSection(context),

                  SizedBox(height: 24.h),

                  // Logout Button
                  _buildLogoutButton(),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Background Image Stack
        Positioned(
          child: Image.asset(
            'assets/image/profilebg.png',
            width: MediaQuery.of(context).size.width,

            fit: BoxFit.fill,
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ),
                    Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 40.w), // Spacer to balance back button
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(70.r),
                      ),
                      child: Center(
                        child: Text(
                          "EJ",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Name and Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Emily John",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "johndoe@email.com",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit Profile Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(color: Colors.white),
                        ),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(8.w),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: _buildFreePlanCard(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreePlanCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E9D8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/image/crown.png',
                width: 50.w,

                fit: BoxFit.contain,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Free Plan",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Upgrade premium to unlock all features.",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumPlanScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2F7D33),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Center(
                child: Text(
                  "Go Premium",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportMissionCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F7D33), Color(0xFF00D492)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text(
                "Support Our Mission",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "Want to help us keep Qurani+ free for everyone? Watch a short video to support our mission — your contribution helps us serve the Ummah better.",
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          SizedBox(height: 20.h),
          // Donation counter bar
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Donations",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "12 videos",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    color: Colors.white,
                    minHeight: 8.h,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "You've helped support Qurani+ — Thank you! 🤲",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20.h),
          // Watch & Donate Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Center(
              child: Text(
                "Watch & Donate (30 sec)",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Center(
            child: Text(
              "100% free • No payment required • Skip anytime",
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _buildSettingsItem(
                  Icons.notifications_outlined,
                  "Notifications",
                  "Prayer times & reminders",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationsSettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.language_outlined,
                  "Language",
                  "English",
                ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.record_voice_over_outlined,
                  "Reciter",
                  "Download reciters",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DownloadedRecitersScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.color_lens_outlined,
                  "Quran Hub Appearance",
                  null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppearanceSettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.note_outlined,
                  "Notes",
                  null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotesScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.bookmark_border,
                  "Bookmark",
                  null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookmarksScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherOptionsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            _buildSettingsItem(
              Icons.person_add_outlined,
              "Invite Friends",
              null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InviteFriendsScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.star_border,
              "Rate us",
              null,
              onTap: () => _showRateUsDialog(context),
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.verified_user_outlined,
              "Privacy Policy",
              null,
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.description_outlined,
              "Terms & Conditions",
              null,
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.delete_outline,
              "Delete Account",
              null,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String? subtitle, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF5F5F5,
                ), // Light gray background for icon
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: isDestructive ? Colors.red : Colors.grey[700],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200], indent: 54.w);
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () async {
          // Clear user data and navigate to login screen
          await SharedPreferencesHelper.logoutUser();
          // Optionally sign out from Google if using GoogleSignInService
          try {
            await GoogleSignInService.signOut();
          } catch (_) {}
          // Replace with your actual login screen import and navigation
          Get.offAll(() => const LoginOptionsScreen());
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 20.sp, color: Colors.white),
              SizedBox(width: 8.w),
              Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRateUsDialog(BuildContext context) {
    int selectedRating = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Title
                Text(
                  "Enjoying the app?",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12.h),

                // Subtitle
                Text(
                  "We will work harder to make you more satisfied.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 24.h),

                // Star Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSelected = index < selectedRating;
                    final isLast = index == 4;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: isLast && !isSelected
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.star_outline,
                                    size: 40.sp,
                                    color: const Color(0xFFFFD700),
                                  ),
                                  Positioned(
                                    bottom: 8.h,
                                    child: Text(
                                      "😊",
                                      style: TextStyle(fontSize: 12.sp),
                                    ),
                                  ),
                                ],
                              )
                            : Icon(
                                isSelected ? Icons.star : Icons.star_outline,
                                size: 40.sp,
                                color: const Color(0xFFFFD700),
                              ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 28.h),

                // Submit button
                GestureDetector(
                  onTap: () {
                    // Handle submit
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
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
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
