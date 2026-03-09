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
  @override
  void initState() {
    super.initState();
    _loadScript();
  }

  Future<void> _loadScript() async {
    final script = await SharedPreferencesHelper.getArabicScript();
    if (mounted) {
      setState(() {
        selectedScript = script;
        selectedScriptIndex = _getScriptIndex(script);
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
    final VerseOfDayController controller = Get.find<VerseOfDayController>();
    return Obx(() {
      final audioData = controller.randomVerse.value?.data.verse.verse.audio;
      if (audioData == null || audioData.isEmpty) {
        return const Center(child: Text("No reciters available"));
      }
      final reciters = audioData.values.map((audioInfo) {
        String placeholderImg =
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";

        if (audioInfo.reciter.contains("Sudais")) {
          placeholderImg =
              "https://i0.wp.com/www.middleeastmonitor.com/wp-content/uploads/2020/09/Abdul-Rahman-Al-Sudais.jpg?fit=920%2C613&ssl=1";
        } else if (audioInfo.reciter.contains("Yasser") ||
            audioInfo.reciter.contains("Dussary")) {
          placeholderImg =
              "https://i.scdn.co/image/ab67616100005174e4bd7040657e8e61dc4667be";
        } else if (audioInfo.reciter.contains("Nasser") ||
            audioInfo.reciter.contains("Qatami")) {
          placeholderImg =
              "https://scontent.fdac207-1.fna.fbcdn.net/v/t39.30808-6/470019064_1119048786249564_9159029543174380749_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=7b2446&_nc_ohc=O9kA8gkeLGMQ7kNvwGNr5oH&_nc_oc=AdnT-OiSE9RjU0v0kTD07qPFSudAeHeqDozhECy78a0zZ8DxGG4kud8d2Wg7InObuBY&_nc_zt=23&_nc_ht=scontent.fdac207-1.fna&_nc_gid=7xGR-giX8dhXhYZ-X3B0xg&_nc_ss=8&oh=00_AfwTIfRlr9uHLOvZeNeCuTaXLMyn9KiQObXJwr7oy-Ctmg&oe=69B44A59";
        } else if (audioInfo.reciter.contains("Mishary") ||
            audioInfo.reciter.contains("Alafasy")) {
          placeholderImg =
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";
        } else if (audioInfo.reciter.contains("Abu Bakr") ||
            audioInfo.reciter.contains("Shatri")) {
          placeholderImg =
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUmPkcySF56YidTERKU54hBnQ0lf734dwb4w&s";
        }
        return {'name': audioInfo.reciter, 'image': placeholderImg};
      }).toList();

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
                "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
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
                "[All] praise is [due] to Allah, Lord of the worlds -",
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
                          arabicScripts[index]['name']!,
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
    final VerseOfDayController controller = Get.find<VerseOfDayController>();
    return GestureDetector(
      onTap: () async {
        // Save selected reciter to SharedPreferences
        final audioData = controller.randomVerse.value?.data.verse.verse.audio;
        if (audioData != null && audioData.isNotEmpty) {
          final reciters = audioData.values.map((audioInfo) {
            String placeholderImg =
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";
            if (audioInfo.reciter.contains("Sudais")) {
              placeholderImg =
                  "https://i0.wp.com/www.middleeastmonitor.com/wp-content/uploads/2020/09/Abdul-Rahman-Al-Sudais.jpg?fit=920%2C613&ssl=1";
            } else if (audioInfo.reciter.contains("Yasser") ||
                audioInfo.reciter.contains("Dussary")) {
              placeholderImg =
                  "https://i.scdn.co/image/ab67616100005174e4bd7040657e8e61dc4667be";
            } else if (audioInfo.reciter.contains("Nasser") ||
                audioInfo.reciter.contains("Qatami")) {
              placeholderImg =
                  "https://scontent.fdac207-1.fna.fbcdn.net/v/t39.30808-6/470019064_1119048786249564_9159029543174380749_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=7b2446&_nc_ohc=O9kA8gkeLGMQ7kNvwGNr5oH&_nc_oc=AdnT-OiSE9RjU0v0kTD07qPFSudAeHeqDozhECy78a0zZ8DxGG4kud8d2Wg7InObuBY&_nc_zt=23&_nc_ht=scontent.fdac207-1.fna&_nc_gid=7xGR-giX8dhXhYZ-X3B0xg&_nc_ss=8&oh=00_AfwTIfRlr9uHLOvZeNeCuTaXLMyn9KiQObXJwr7oy-Ctmg&oe=69B44A59";
            } else if (audioInfo.reciter.contains("Mishary") ||
                audioInfo.reciter.contains("Alafasy")) {
              placeholderImg =
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";
            } else if (audioInfo.reciter.contains("Abu Bakr") ||
                audioInfo.reciter.contains("Shatri")) {
              placeholderImg =
                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUmPkcySF56YidTERKU54hBnQ0lf734dwb4w&s";
            }
            return {'name': audioInfo.reciter, 'image': placeholderImg};
          }).toList();
          if (selectedReciterIndex >= 0 &&
              selectedReciterIndex < reciters.length) {
            final selectedReciterName = reciters[selectedReciterIndex]['name']!;
            await SharedPreferencesHelper.saveReciter(selectedReciterName);
            // Debug print
            // ignore: avoid_print
            print('[DEBUG] Saved reciter: $selectedReciterName');
          }
        }
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
