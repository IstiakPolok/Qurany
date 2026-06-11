import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            // Content
            Expanded(
              child: Obx(() {
                final user = controller.user.value;
                if (user == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),

                      // Avatar with camera button
                      _buildAvatarSection(user.avatarUrl, user.initials),

                      SizedBox(height: 40.h),

                      // First Name Field
                      _buildTextField(
                        "First name",
                        controller.firstNameController,
                      ),

                      SizedBox(height: 20.h),

                      // Last Name Field
                      _buildTextField(
                        "Last Name",
                        controller.lastNameController,
                      ),

                      SizedBox(height: 20.h),

                      // Email Field
                      _buildTextField(
                        "Email Address",
                        controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      SizedBox(height: 40.h),

                      // Update Profile Button
                      _buildUpdateButton(),

                      SizedBox(height: 32.h),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Profile",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 40.w), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String? avatarUrl, String initials) {
    final ProfileController controller = Get.find<ProfileController>();
    return Center(
      child: GestureDetector(
        onTap: () => controller.pickAndUploadAvatar(),
        child: Stack(
          children: [
            // Avatar circle
            Obx(() {
              final isUploading = controller.isUploadingAvatar.value;
              final currentUrl = controller.user.value?.avatarUrl ?? avatarUrl;
              return Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF9F0),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  image: (currentUrl != null && currentUrl.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(currentUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: isUploading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2E7D32),
                          strokeWidth: 2,
                        ),
                      )
                    : (currentUrl == null || currentUrl.isEmpty)
                    ? Center(
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    : null,
              );
            }),

            // Camera button
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 20.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
          ),
          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    final ProfileController controller = Get.find<ProfileController>();
    return Obx(() {
      return GestureDetector(
        onTap: controller.isUpdating.value
            ? null
            : () => controller.updateProfile(),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: controller.isUpdating.value
                ? const Color(0xFF2E7D32).withOpacity(0.6)
                : const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Center(
            child: controller.isUpdating.value
                ? SizedBox(
                    height: 20.h,
                    width: 20.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    "Update Profile",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
