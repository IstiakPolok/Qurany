import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // Avatar with camera button
                    _buildAvatarSection(),

                    SizedBox(height: 40.h),

                    // First Name Field
                    _buildTextField("First name", "Emily"),

                    SizedBox(height: 20.h),

                    // Last Name Field
                    _buildTextField("Last Name", "John"),

                    SizedBox(height: 20.h),

                    // Email Field
                    _buildTextField("Email Address", "emilyjohn@email.com"),

                    SizedBox(height: 40.h),

                    // Update Profile Button
                    _buildUpdateButton(),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
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

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          // Avatar circle
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFF9F0),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Center(
              child: Text(
                "EJ",
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

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
    );
  }

  Widget _buildTextField(String label, String value) {
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
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Center(
        child: Text(
          "Update Profile",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
