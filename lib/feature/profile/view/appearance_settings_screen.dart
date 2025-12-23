import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  int selectedReciterIndex = 0;
  String selectedTranslation = 'English';
  int selectedScriptIndex = 0;
  String selectedTranslation2 = 'English';
  int selectedThemeIndex = 1; // Islamic selected by default

  final List<Map<String, String>> reciters = [
    {
      'name': "Mishary Al-Afasy",
      'image':
          'https://images.unsplash.com/photo-1564121211835-e88c852648ab?q=80&w=300&auto=format&fit=crop',
    },
    {
      'name': "Sheikh Sudais",
      'image':
          'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=300&auto=format&fit=crop',
    },
    {
      'name': "Sheikh Abdul Basit",
      'image':
          'https://images.unsplash.com/photo-1519817650390-64a93db51149?q=80&w=300&auto=format&fit=crop',
    },
    {
      'name': "Sheikh Mansour",
      'image':
          'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=300&auto=format&fit=crop',
    },
  ];

  final List<Map<String, String>> arabicScripts = [
    {'name': 'IndoPak', 'sample': 'بِسْمِ اللّٰهِ'},
    {'name': 'Uthmani', 'sample': 'بِسْمِ اللّٰهِ'},
    {'name': 'No symbol', 'sample': 'بِسْمِ اللّٰهِ'},
    {'name': 'Compatible', 'sample': 'بِسْمِ اللّٰهِ'},
  ];

  final List<String> themes = ['Minimal', 'Islamic', 'Ornate'];

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
                    SizedBox(height: 16.h),

                    // Select Your Reciter
                    Text(
                      "Select Your Reciter",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildReciterSelector(),

                    SizedBox(height: 24.h),

                    // Translation
                    Text(
                      "Translation",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildDropdown(selectedTranslation, (value) {
                      setState(() => selectedTranslation = value!);
                    }),

                    SizedBox(height: 24.h),

                    // Select your Arabic script
                    Text(
                      "Select your Arabic script",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildArabicScriptSelector(),

                    SizedBox(height: 24.h),

                    // Translation (second)
                    Text(
                      "Translation",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildDropdown(selectedTranslation2, (value) {
                      setState(() => selectedTranslation2 = value!);
                    }),

                    SizedBox(height: 24.h),

                    // Theme
                    Text(
                      "Theme",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildThemeSelector(),

                    SizedBox(height: 40.h),

                    // Save Button
                    _buildSaveButton(),

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
                "Appearance Setting",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildReciterSelector() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reciters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedReciterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedReciterIndex = index),
            child: Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 12.w),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFF2E7D32),
                                  width: 2,
                                )
                              : null,
                          image: DecorationImage(
                            image: NetworkImage(reciters[index]['image']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 4.w,
                          right: 4.w,
                          child: Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    reciters[index]['name']!,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        items: [
          'English',
          'Arabic',
          'Urdu',
          'Bengali',
          'Indonesian',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildArabicScriptSelector() {
    return Row(
      children: List.generate(arabicScripts.length, (index) {
        final isSelected = selectedScriptIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedScriptIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8.w : 0),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey[200]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  if (isSelected)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    arabicScripts[index]['sample']!,
                    style: TextStyle(fontSize: 14.sp, fontFamily: 'Amiri'),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    arabicScripts[index]['name']!,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildThemeSelector() {
    return Row(
      children: List.generate(themes.length, (index) {
        final isSelected = selectedThemeIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedThemeIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 12.w : 0),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  themes[index],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        // Save settings
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Center(
          child: Text(
            "Save",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
