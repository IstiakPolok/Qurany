import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:qurany/feature/home/controller/verse_of_day_controller.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

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
  String selectedScript = 'Imlaei';
  String _selectedReciterName = 'Mishary Rashid Alafasy';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final script = await SharedPreferencesHelper.getArabicScript();
    final reciter = await SharedPreferencesHelper.getReciter();
    // For now, these aren't saved/loaded explicitly in SharedPreferencesHelper
    // but we can initialize them from defaults or add helpers later if needed.
    // selectedTranslation and selectedThemeIndex are handled via state for now.

    if (mounted) {
      setState(() {
        selectedScript = script;
        selectedScriptIndex = _getScriptIndex(script);
        _selectedReciterName = reciter;
      });
    }
  }

  int _getScriptIndex(String script) {
    switch (script) {
      case 'IndoPak':
        return 0;
      case 'Uthmani':
        return 1;
      case 'No symbol':
        return 2;
      case 'Compatible':
        return 3;
      default:
        return 0;
    }
  }

  String _getScriptName(int index) {
    switch (index) {
      case 0:
        return 'IndoPak';
      case 1:
        return 'Uthmani';
      case 2:
        return 'No symbol';
      case 3:
        return 'Compatible';
      default:
        return 'IndoPak';
    }
  }

  Future<void> _selectScript(int index) async {
    final script = _getScriptName(index);
    await SharedPreferencesHelper.saveArabicScript(script);
    final saved = await SharedPreferencesHelper.getArabicScript();
    // Debug print
    // ignore: avoid_print
    print('[DEBUG] Saved script: $saved');
    if (mounted) {
      setState(() {
        selectedScriptIndex = index;
        selectedScript = saved;
      });
    }
  }

  String selectedTranslation2 = 'English';
  int selectedThemeIndex = 1; // Islamic selected by default

  final List<Map<String, String>> arabicScripts = [
    {'name': 'IndoPak', 'key': 'indopak', 'sample': 'بِسْمِ اللّٰهِ'},
    {'name': 'Uthmani', 'key': 'uthmani', 'sample': 'بِسْمِ اللّٰهِ'},
    {'name': 'No symbol', 'key': 'no_symbol', 'sample': 'بِسْمِ اللّٰهِ'},
    {'name': 'Compatible', 'key': 'compatible', 'sample': 'بِسْمِ اللّٰهِ'},
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
                      "select_reciter".tr,
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
                      "translation".tr,
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
                      "select_arabic_script".tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildArabicScriptSelector(),

                    // SizedBox(height: 24.h),

                    // // Theme
                    // Text(
                    //   "theme".tr,
                    //   style: TextStyle(
                    //     fontSize: 14.sp,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                    // SizedBox(height: 12.h),
                    // _buildThemeSelector(),
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
                "appearance_settings".tr,
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
    final VerseOfDayController controller = Get.find<VerseOfDayController>();
    return Obx(() {
      final audioData = controller.randomVerse.value?.data.verse.verse.audio;
      if (audioData == null || audioData.isEmpty) {
        return Center(child: Text("no_reciters_available".tr));
      }
      final reciters = audioData.values.map((audioInfo) {
        String assetPath = "assets/image/MisharyRashidAIAlfasy.jpg"; // Default

        if (audioInfo.reciter.contains("Sudais")) {
          assetPath =
              "assets/image/MisharyRashidAIAlfasy.jpg"; // Fallback if Sudais not found
        } else if (audioInfo.reciter.contains("Yasser") ||
            audioInfo.reciter.contains("Dussary")) {
          assetPath = "assets/image/YasserAlDosari.jpg";
        } else if (audioInfo.reciter.contains("Nasser") ||
            audioInfo.reciter.contains("Qatami")) {
          assetPath = "assets/image/NasserAlQatami.jpg";
        } else if (audioInfo.reciter.contains("Mishary") ||
            audioInfo.reciter.contains("Alafasy")) {
          assetPath = "assets/image/MisharyRashidAIAlfasy.jpg";
        } else if (audioInfo.reciter.contains("Abu Bakr") ||
            audioInfo.reciter.contains("Shatri")) {
          assetPath = "assets/image/abu_bakr_shatri.jpg";
        }
        return {'name': audioInfo.reciter, 'image': assetPath};
      }).toList();

      return SizedBox(
        height: 120.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: reciters.length,
          itemBuilder: (context, index) {
            final reciterName = reciters[index]['name']!;
            final isSelected = _selectedReciterName == reciterName;
            return GestureDetector(
              onTap: () => setState(() => _selectedReciterName = reciterName),
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
                              image: AssetImage(reciters[index]['image']!),
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
    });
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
          'العربية',
          'اردو',
          'Türkçe',
          'Bahasa',
          'François',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildArabicScriptSelector() {
    // Show only one preview card like ScriptStep
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFFDAE2D0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset(
                'assets/image/Layer_1.png',
                width: 32.w,
                height: 32.h,
              ),
              Text(
                "alhamdulillah_verse".tr,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: selectedScript == 'IndoPak' ? 'IndoPak' : 'Arial',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "alhamdulillah_trans".tr,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: List.generate(arabicScripts.length, (index) {
              final isSelected = selectedScriptIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _selectScript(index),
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
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily:
                                arabicScripts[index]['name'] == 'IndoPak'
                                ? 'IndoPak'
                                : 'Arial',
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          arabicScripts[index]['key']!.tr,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
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
                  themes[index].toLowerCase().tr,
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
      onTap: () async {
        // Save selected reciter to SharedPreferences
        // No need to rebuild the reciters list here since we use _selectedReciterName directly
        await SharedPreferencesHelper.saveReciter(_selectedReciterName);
        // Debug print
        // ignore: avoid_print
        print('[DEBUG] Saved reciter: $_selectedReciterName');
        // Save other settings if needed
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
            "save".tr,
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
