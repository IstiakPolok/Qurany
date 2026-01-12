import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageStep extends StatefulWidget {
  const LanguageStep({super.key});

  @override
  State<LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends State<LanguageStep> {
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Text(
            "Choose your language",
            style: GoogleFonts.abhayaLibre(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Select the language you'd like the app to use for\nmenus, prompts, and companion responses.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 30.h),

          // Auto Detect Option
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E8D9), // Light green tint
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detect language automatically",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "(Recommended)",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.radio_button_checked, color: Colors.green[800]),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Language Grid
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            children: [
              _buildLanguageItem('English', 'Welcome'),
              _buildarbicLanguageItem('العربية', 'مرحبا'),
              _buildarbicLanguageItem('اردو', 'خوش آمدید'),
              _buildLanguageItem('Türkçe', 'Hoş geldiniz'),
              _buildLanguageItem('Bahasa', 'Selamat datang'),
              _buildLanguageItem('François', 'Bienvenue'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildarbicLanguageItem(String name, String sub) {
    final isSelected = selectedLanguage == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = name;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.bold,
                fontSize: 22.sp,
                color: isSelected ? Colors.green[800] : Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              sub,
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(String name, String sub) {
    final isSelected = selectedLanguage == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = name;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: isSelected ? Colors.green[800] : Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              sub,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
