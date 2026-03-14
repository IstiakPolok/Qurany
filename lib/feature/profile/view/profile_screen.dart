import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/auth/views/login_options_screen.dart';
import '../../../core/services_class/local_service/shared_preferences_helper.dart';
import '../../auth/services/google_auth_service.dart';
import 'appearance_settings_screen.dart';
import 'bookmarks_screen.dart';
import 'edit_profile_screen.dart';
import 'invite_friends_screen.dart';
import 'notes_screen.dart';
import 'notifications_settings_screen.dart';
import 'premium_plan_screen.dart';

import 'package:qurany/feature/profile/controller/profile_controller.dart';
import 'package:qurany/feature/profile/view/legal_document_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedLanguage = 'English';
  final List<String> languages = [
    'English',
    'العربية',
    'اردو',
    'Türkçe',
    'Bahasa',
    'Français',
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await SharedPreferencesHelper.getLanguage();
    setState(() {
      _selectedLanguage = lang;
    });
    _updateLocale(lang);
  }

  void _updateLocale(String lang) {
    Locale locale;
    switch (lang) {
      case 'English':
        locale = const Locale('en');
        break;
      case 'العربية':
        locale = const Locale('ar');
        break;
      case 'اردو':
        locale = const Locale('ur');
        break;
      case 'Türkçe':
        locale = const Locale('tr');
        break;
      case 'Bahasa':
        locale = const Locale('id');
        break;
      case 'Français':
        locale = const Locale('fr');
        break;
      default:
        locale = const Locale('en');
    }
    Get.updateLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());
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
                  Obx(() => _buildHeader(context, profileController)),

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

  Widget _buildHeader(BuildContext context, ProfileController controller) {
    final user = controller.user.value;
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
                      "profile".tr,
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
                        image: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                            ? DecorationImage(
                                image: NetworkImage(user.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                          ? Center(
                              child: Text(
                                user?.initials ?? "U",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2E7D32),
                                ),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    // Name and Email
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? "User",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            user?.email ?? "email@example.com",
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
                        ).then((_) => controller.fetchProfile());
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
                          "edit_profile".tr,
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
                child: _buildFreePlanCard(context, user?.type ?? 'free'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreePlanCard(BuildContext context, String planType) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planType == 'free' ? "free_plan".tr : "premium_plan".tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      planType == 'free' ? "upgrade_msg".tr : "unlocked_msg".tr,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          //  if (planType == 'free') ...[
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
                  "go_premium".tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // ],
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
              Expanded(
                child: Text(
                  "support_mission".tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            "support_desc".tr,
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
                      "your_donations".tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "12 ${"videos".tr}",
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
            "thanks_msg".tr,
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
                "watch_donate".tr,
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
              "support_footer".tr,
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
            "settings".tr,
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
                  "notifications".tr,
                  "prayer_reminders".tr,
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
                _buildLanguageItem(),
                _buildDivider(),
                // _buildSettingsItem(
                //   Icons.record_voice_over_outlined,
                //   "Reciter",
                //   "Download reciters",
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const DownloadedRecitersScreen(),
                //       ),
                //     );
                //   },
                // ),
                _buildDivider(),
                _buildSettingsItem(
                  Icons.color_lens_outlined,
                  "quran_appearance".tr,
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
                  "notes".tr,
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
                  "bookmark".tr,
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
              "invite_friends".tr,
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
              "rate_us".tr,
              null,
              onTap: () => _showRateUsDialog(context),
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.verified_user_outlined,
              "privacy_policy".tr,
              null,
              onTap: () {
                Get.to(() => LegalDocumentScreen(
                      title: "privacy_policy".tr,
                      markdownContent: """
# Privacy Policy

**Effective Date: March 14, 2026**

Welcome to Qurany. Your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use our mobile application.

## 1. Information We Collect
We do not collect any personal data unless you voluntarily provide it (e.g., when creating an account). We may collect non-personal information such as device type and app usage statistics to improve our service.

## 2. Use of Information
The information we collect is used to personalize your experience, provide customer support, and improve app functionality.

## 3. Data Protection
We implement a variety of security measures to maintain the safety of your personal information.

## 4. Third-Party Services
We may use third-party services (like Firebase or RevenueCat) that collect information used to identify you.

## 5. Contact Us
If you have any questions regarding this Privacy Policy, you can contact us at support@quranyapp.com.
""",
                    ));
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.description_outlined,
              "terms_conditions".tr,
              null,
              onTap: () {
                Get.to(() => LegalDocumentScreen(
                      title: "terms_conditions".tr,
                      markdownContent: """
# Terms and Conditions

**Last Updated: March 14, 2026**

By using the Qurany app, you agree to comply with and be bound by the following terms and conditions.

## 1. Acceptance of Terms
By accessing or using our application, you agree to be bound by these Terms. If you do not agree, please do not use the app.

## 2. License to Use
Qurany grants you a personal, non-exclusive, non-transferable, limited license to use the app for personal, non-commercial purposes.

## 3. User Conduct
You agree to use the app only for lawful purposes and in a way that does not infringe the rights of others.

## 4. Premium Subscription
Certain features are only available through a premium subscription. Fees and payment terms are handled by the respective app stores.

## 5. Limitation of Liability
Qurany shall not be liable for any indirect, incidental, or consequential damages arising out of your use of the app.

## 6. Changes to Terms
We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of the new terms.
""",
                    ));
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              Icons.delete_outline,
              "delete_account".tr,
              null,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.language_outlined,
              size: 20.sp,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "language".tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    value: _selectedLanguage,
                    //icon: const Icon(Icons.keyboard_arrow_down),
                    style: TextStyle(fontSize: 11.sp, color: Colors.black87),
                    items: languages
                        .map(
                          (lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)),
                        )
                        .toList(),
                    onChanged: (v) async {
                      if (v != null) {
                        setState(() => _selectedLanguage = v);
                        await SharedPreferencesHelper.saveLanguage(v);
                        _updateLocale(v);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
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
                "logout".tr,
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
                  "enjoying_app".tr,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12.h),

                // Subtitle
                Text(
                  "work_harder".tr,
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
