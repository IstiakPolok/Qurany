import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/ask_ai/view/ask_ai_intro_screen.dart';
import 'package:qurany/feature/quran/model/verse_detail_model.dart';
import 'package:qurany/feature/quran/view/memorization_screen.dart';
import 'package:qurany/feature/quran/view/surah_reading_screen.dart';
import 'package:qurany/core/const/static_surah_data.dart';
import 'package:qurany/feature/home/services/quran_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/home/controller/verse_of_day_controller.dart';
import 'dart:async';

class QuranReadModeScreen extends StatefulWidget {
  final String surahName;
  final String arabicName;
  final String meaning;
  final String origin;
  final int ayaCount;
  final String translation;
  final List<VerseDetailModel> verses;
  final SurahReadingController controller;

  const QuranReadModeScreen({
    super.key,
    required this.surahName,
    required this.arabicName,
    required this.meaning,
    required this.origin,
    required this.ayaCount,
    required this.translation,
    required this.verses,
    required this.controller,
  });

  @override
  State<QuranReadModeScreen> createState() => _QuranReadModeScreenState();
}

class _QuranReadModeScreenState extends State<QuranReadModeScreen> {
  double _fontSize = 22.0;
  static const String _fontSizePrefKey = 'quran_readmode_fontsize';
  int? _selectedVerseIndex;

  // Settings state
  String _selectedLanguage = 'English';
  int _selectedScript = 0;
  String _selectedScriptName = 'Imlaei';
  String _endOfSurahAction = 'play_next_surah';
  int _viewMode = 0; // 0 = List, 1 = Page

  late SurahReadingController _controller;
  late String _surahName;
  late String _arabicName;
  late String _meaning;
  late String _origin;
  late int _ayaCount;
  late String _translation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _surahName = widget.surahName;
    _arabicName = widget.arabicName;
    _meaning = widget.meaning;
    _origin = widget.origin;
    _ayaCount = widget.ayaCount;
    _translation = widget.translation;
    _loadFontSize();
    _loadScript();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await SharedPreferencesHelper.getLanguage();
    if (mounted) {
      setState(() {
        _selectedLanguage = lang;
      });
    }
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

  Future<void> _loadScript() async {
    final script = await SharedPreferencesHelper.getArabicScript();
    if (mounted) {
      setState(() {
        _selectedScriptName = script;
        _selectedScript = _getScriptIndex(script);
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

  Future<void> _selectScript(int index, StateSetter setSheetState) async {
    final script = _getScriptName(index);
    await SharedPreferencesHelper.saveArabicScript(script);
    final saved = await SharedPreferencesHelper.getArabicScript();
    if (mounted) {
      setState(() {
        _selectedScript = index;
        _selectedScriptName = saved;
      });
      setSheetState(() {});
    }
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_fontSizePrefKey);
    if (saved != null && saved >= 14 && saved <= 40) {
      setState(() {
        _fontSize = saved;
      });
    }
  }

  void _zoomIn() {
    setState(() {
      if (_fontSize < 40) {
        _fontSize += 2;
        _saveFontSize(_fontSize);
      }
    });
  }

  void _zoomOut() {
    setState(() {
      if (_fontSize > 14) {
        _fontSize -= 2;
        _saveFontSize(_fontSize);
      }
    });
  }

  void _resetZoom() {
    setState(() {
      _fontSize = 22.0;
      _saveFontSize(_fontSize);
    });
  }

  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizePrefKey, value);
  }

  void _selectVerse(int index) {
    setState(() {
      _selectedVerseIndex = _selectedVerseIndex == index ? null : index;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedVerseIndex = null;
    });
  }

  void _showSettingsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSettingsPanel(),
    );
  }

  Widget _buildSettingsPanel() {
    final languages = [
      'English',
      'العربية',
      'اردو',
      'Türkçe',
      'Bahasa',
      'Français',
    ];
    final endOfSurahOptions = [
      {'key': 'play_next_surah', 'label': 'play_next_surah'.tr},
      {'key': 'stop', 'label': 'stop'.tr},
      {'key': 'repeat', 'label': 'repeat'.tr},
    ];

    return StatefulBuilder(
      builder: (ctx, setSheetState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 32.w),
                    Text(
                      'settings'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[200]),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text Size
                      Text(
                        'text_size'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black54,
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF2E7D32),
                                inactiveTrackColor: Colors.grey[300],
                                thumbColor: const Color(0xFF2E7D32),
                                overlayColor: const Color(
                                  0xFF2E7D32,
                                ).withOpacity(0.2),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: _fontSize,
                                min: 14,
                                max: 40,
                                onChanged: (v) async {
                                  setState(() => _fontSize = v);
                                  setSheetState(() {});
                                  await _saveFontSize(v);
                                },
                              ),
                            ),
                          ),
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      // Select Your Reciter
                      Text(
                        'select_reciter'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildReciterSelector(setSheetState),
                      SizedBox(height: 20.h),
                      // Choose your language
                      Text(
                        'language'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: const Color(0xFFFFF9F0),
                            value: _selectedLanguage,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                            items: languages
                                .map(
                                  (lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) async {
                              if (v != null) {
                                setState(() => _selectedLanguage = v);
                                setSheetState(() {});
                                await SharedPreferencesHelper.saveLanguage(v);
                                _updateLocale(v);
                              }
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),
                      // Select your Arabic script
                      Text(
                        'select_arabic_script'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildArabicScriptSelector(setSheetState),
                      SizedBox(height: 20.h),
                      // At the end of Surah
                      Text(
                        'at_end_of_surah'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _endOfSurahAction,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                            items: endOfSurahOptions
                                .map(
                                  (opt) => DropdownMenuItem(
                                    value: opt['key'],
                                    child: Text(opt['label']!),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _endOfSurahAction = v);
                                setSheetState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // View Mode
                      Text(
                        'view_mode'.tr,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _viewMode = 0);
                                  setSheetState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: _viewMode == 0
                                        ? const Color(0xFF2E7D32)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.list,
                                        size: 20.sp,
                                        color: _viewMode == 0
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'list'.tr,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _viewMode == 0
                                              ? Colors.white
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _viewMode = 1);
                                  setSheetState(() {});
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: _viewMode == 1
                                        ? const Color(0xFF2E7D32)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.description_outlined,
                                        size: 20.sp,
                                        color: _viewMode == 1
                                            ? Colors.white
                                            : Colors.black54,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'page'.tr,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: _viewMode == 1
                                              ? Colors.white
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArabicScriptSelector(StateSetter setSheetState) {
    final arabicScripts = [
      {'name': 'IndoPak', 'sample': 'بِسْمِ اللّٰهِ'},
      {'name': 'Uthmani', 'sample': 'بِسْمِ اللّٰهِ'},
      {'name': 'No symbol', 'sample': 'بِسْمِ اللّٰهِ'},
      {'name': 'Compatible', 'sample': 'بِسْمِ اللّٰهِ'},
    ];

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
                  fontFamily: _selectedScriptName == 'IndoPak'
                      ? 'IndoPak'
                      : 'Arial',
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
                'arabic'.tr,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                textAlign: TextAlign.left,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: List.generate(arabicScripts.length, (index) {
              final isSelected = _selectedScript == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _selectScript(index, setSheetState),
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

  Widget _buildReciterSelector(StateSetter setSheetState) {
    VerseOfDayController? controller;
    if (Get.isRegistered<VerseOfDayController>()) {
      controller = Get.find<VerseOfDayController>();
    } else {
      controller = Get.put(VerseOfDayController());
    }

    return Obx(() {
      final audioData = controller!.randomVerse.value?.data.verse.verse.audio;
      if (audioData == null || audioData.isEmpty) {
        return Center(child: Text('no_reciters_available'.tr));
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
            final isSelected = _controller.selectedReciterName.value == reciters[index]['name'];
            return GestureDetector(
              onTap: () async {
                final selectedReciterName = reciters[index]['name']!;
                await _controller.saveReciter(selectedReciterName);
                setSheetState(() {});
              },
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

  void _navigateToSurah(int surahNumber) {
    final surahs = StaticSurahData.getAllSurahs();
    if (surahNumber < 1 || surahNumber > surahs.length) return;
    final surah = surahs[surahNumber - 1];

    final newTag = surah.number.toString();

    // Create new controller (or reuse existing)
    SurahReadingController newController;
    if (Get.isRegistered<SurahReadingController>(tag: newTag)) {
      newController = Get.find<SurahReadingController>(tag: newTag);
    } else {
      newController = Get.put(
        SurahReadingController(
          surahId: surah.number,
          surahName: surah.englishName,
          arabicName: surah.arabicName,
          totalAyaCount: surah.totalVerses,
        ),
        tag: newTag,
      );
    }

    setState(() {
      _controller = newController;
      _surahName = surah.englishName;
      _arabicName = surah.arabicName;
      _meaning = surah.englishName;
      _origin = surah.revelationType;
      _ayaCount = surah.totalVerses;
      _translation = surah.translation;
      _selectedVerseIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: GestureDetector(
        onTap: _clearSelection,
        onHorizontalDragEnd: (details) {
          if (_selectedVerseIndex != null) return;
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 300) {
            // Swipe right → previous surah
            _navigateToSurah(_controller.surahId - 1);
          } else if (velocity < -300) {
            // Swipe left → next surah
            _navigateToSurah(_controller.surahId + 1);
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                // App Bar
                _buildAppBar(context),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        // Surah Header
                        _buildSurahHeader(),

                        SizedBox(height: 16.h),

                        // Bismillah
                        Image.asset(
                          'assets/image/bismillah.png',
                          width: 200.w,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: 24.h),

                        // Continuous Arabic text with verse markers
                        Obx(() {
                          if (_controller.isLoading.value) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: const CircularProgressIndicator(
                                color: Color(0xFF2E7D32),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              _buildContinuousArabicText(),
                              _buildLoadMoreButton(),
                            ],
                          );
                        }),

                        SizedBox(height: 24.h),

                        // Zoom controls
                        _buildZoomControls(),

                        // Bottom padding for audio player + options panel
                        SizedBox(
                          height: _selectedVerseIndex != null ? 300.h : 100.h,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Verse Options Panel (shown when a verse is selected)
            if (_selectedVerseIndex != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Obx(
                    () => _buildVerseOptionsPanel(
                      _controller.verses[_selectedVerseIndex!],
                    ),
                  ),
                ),
              ),

            // Bottom Audio Player (hidden when options panel is shown)
            if (_selectedVerseIndex == null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildAudioPlayer(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 16.w,
        right: 16.w,
        bottom: 12.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Row(
            children: [
              Text(
                _surahName,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.keyboard_arrow_down, size: 20.sp),
            ],
          ),
          GestureDetector(
            onTap: _showSettingsPanel,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(
                Icons.info_outlined,
                size: 18.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _navigateToSurah(_controller.surahId - 1),
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 14.sp,
                  color: _controller.surahId > 1
                      ? Colors.black87
                      : Colors.grey[300],
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              _meaning.toUpperCase(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2,
              ),
            ),
            SizedBox(width: 16.w),
            GestureDetector(
              onTap: () => _navigateToSurah(_controller.surahId + 1),
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: _controller.surahId < 114
                      ? Colors.black87
                      : Colors.grey[300],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _translation.toUpperCase(),
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black54,
                letterSpacing: 1,
              ),
            ),
            _buildDot(),
            Text(
              _origin.toUpperCase(),
              style: TextStyle(fontSize: 11.sp, color: Colors.black54),
            ),
            _buildDot(),
            Text(
              'aya_count'.trParams({'count': _ayaCount.toString()}),
              style: TextStyle(fontSize: 11.sp, color: Colors.black54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Container(
        width: 4.w,
        height: 4.w,
        decoration: const BoxDecoration(
          color: Color(0xFF2E7D32),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildContinuousArabicText() {
    // Build inline spans for all verses with verse number markers
    List<InlineSpan> spans = [];

    for (int i = 0; i < _controller.verses.length; i++) {
      final verse = _controller.verses[i];
      final isSelected = _selectedVerseIndex == i;

      // Add verse text (tappable)
      spans.add(
        TextSpan(
          text: verse.text,
          style: TextStyle(
            fontSize: _fontSize.sp,
            fontFamily: _selectedScriptName == 'IndoPak' ? 'IndoPak' : 'Arial',
            height: 1.8,
            color: isSelected ? const Color(0xFF2E7D32) : Colors.black,
            backgroundColor: isSelected
                ? const Color(0xFF2E7D32).withOpacity(0.1)
                : null,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _selectVerse(i),
        ),
      );

      // Add verse number marker as widget span AFTER text
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () => _selectVerse(i),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/icons/Layer_1.png',
                    width: (_fontSize + 8).sp,
                    height: (_fontSize + 8).sp,
                  ),
                  Text(
                    verse.ayate,
                    style: TextStyle(
                      color: const Color(0xFF2E7D32),
                      fontSize: (_fontSize - 8).sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Add space between verses
      if (i < _controller.verses.length - 1) {
        spans.add(
          TextSpan(
            text: ' ',
            style: TextStyle(fontSize: _fontSize.sp),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadMoreButton() {
    return Obx(() {
      if (!_controller.hasMoreVerses.value) {
        return const SizedBox.shrink();
      }

      if (_controller.isLoadingMore.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: const CircularProgressIndicator(color: Color(0xFF2E7D32)),
        );
      }

      return Padding(
        padding: EdgeInsets.only(top: 24.h),
        child: GestureDetector(
          onTap: () => _controller.loadMoreVerses(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: const Color(0xFF2E7D32).withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 18.sp,
                  color: const Color(0xFF2E7D32),
                ),
                SizedBox(width: 8.w),
                Text(
                  'load_more_verses'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildZoomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Zoom In
        GestureDetector(
          onTap: _zoomIn,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.zoom_in, size: 20.sp, color: Colors.black87),
                SizedBox(width: 6.w),
                Text(
                  'zoom_in'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // Reset
        GestureDetector(
          onTap: _resetZoom,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.fullscreen, size: 20.sp, color: Colors.black87),
          ),
        ),

        SizedBox(width: 12.w),

        // Zoom Out
        GestureDetector(
          onTap: _zoomOut,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.zoom_out, size: 20.sp, color: Colors.black87),
                SizedBox(width: 6.w),
                Text(
                  'zoom_out'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerseOptionsPanel(VerseDetailModel verse) {
    final TextEditingController askController = TextEditingController();
    final controller = _controller;

    void sendToAI() {
      final query = askController.text.trim();
      if (query.isEmpty) return;
      _clearSelection();
      if (Get.isRegistered<AskAIController>()) {
        Get.delete<AskAIController>();
      }
      final aiController = Get.put(AskAIController());
      final contextMessage =
          'About $_surahName, Verse ${verse.verseId}: $query';
      aiController.messageController.text = contextMessage;
      aiController.showChat.value = true;
      Get.to(() => const AskAIScreen());
      Future.delayed(const Duration(milliseconds: 400), () {
        aiController.sendMessage();
      });
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ask about this aya field
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: askController,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      onSubmitted: (_) => sendToAI(),
                      decoration: InputDecoration(
                        hintText: 'ask_about_aya'.tr,
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 13.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: sendToAI,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: const Color(0xFF2E7D32),
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // First row: Copy, Read, Bookmark, Note
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionButton(
                  icon: Icons.copy_outlined,
                  label: 'copy'.tr,
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: '${verse.text}\n\n${verse.translation}',
                      ),
                    );
                    _clearSelection();
                    Get.snackbar(
                      'copied'.tr,
                      'verse_copied_msg'.tr,
                      backgroundColor: const Color(0xFF2E7D32),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                _buildOptionButton(
                  icon: Icons.done_all,
                  label: 'read'.tr,
                  onTap: () {
                    controller.playVerse(verse.verseId);
                    _clearSelection();
                  },
                ),
                _buildOptionButton(
                  icon: Icons.bookmark_outline,
                  label: 'bookmark'.tr,
                  onTap: () {
                    controller.toggleBookmark(verse.verseId);
                    _clearSelection();
                  },
                ),
                _buildOptionButton(
                  icon: Icons.note_alt_outlined,
                  label: 'notes'.tr,
                  onTap: () {
                    _clearSelection();
                    _showAddNoteDialog(
                      context,
                      verse.id,
                      verse.verseId,
                      verse.notes,
                      _controller,
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Second row: Share, Memorise, Repeat
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOptionButton(
                  icon: Icons.share_outlined,
                  label: 'share'.tr,
                  onTap: () {
                    _clearSelection();
                  },
                ),
                SizedBox(width: 32.w),
                _buildOptionButton(
                  icon: Icons.psychology_outlined,
                  label: 'memorize'.tr,
                  onTap: () {
                    _clearSelection();
                    if (Get.isRegistered<MemorizationController>()) {
                      Get.delete<MemorizationController>();
                    }
                    final memoController = Get.put(MemorizationController());
                    Get.to(() => const MemorizationScreen());
                    memoController.startPracticeSession(
                      _controller.surahId,
                      verse.verseId,
                    );
                  },
                ),
                SizedBox(width: 32.w),
                _buildOptionButton(
                  icon: Icons.repeat,
                  label: 'repeat'.tr,
                  onTap: () {
                    controller.playVerse(verse.verseId);
                    _clearSelection();
                  },
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(
    BuildContext context,
    int id,
    int verseId,
    List<NoteModel> notes,
    SurahReadingController controller,
  ) {
    final bool hasNote = notes.isNotEmpty;
    final NoteModel? existingNote = hasNote ? notes.first : null;
    final TextEditingController noteController = TextEditingController(
      text: existingNote?.description ?? '',
    );
    final QuranService noteService = QuranService();
    bool isSaving = false;
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierColor: Colors.black45,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF2F7D33),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  children: [
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          'surah_aya'.trParams({
                            'surah': _surahName,
                            'aya': verseId.toString(),
                          }),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          hasNote ? 'view_edit_note'.tr : 'add_note'.tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Text field
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white54, width: 1.2),
                  ),
                  child: TextField(
                    controller: noteController,
                    maxLines: 5,
                    minLines: 5,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'type_here'.tr,
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final text = noteController.text.trim();
                            if (text.isEmpty) return;
                            setState(() => isSaving = true);
                            final msg = await noteService.createNote(
                              description: text,
                              surahId: _controller.surahId,
                              verseId: verseId,
                              id: id,
                            );
                            setState(() => isSaving = false);
                            if (context.mounted) Navigator.pop(context);
                            if (msg != null) {
                              // Update verse notes in-memory so the UI refreshes
                              final updatedNote = NoteModel(
                                id: existingNote?.id ?? '',
                                title: 'surah_aya'.trParams({
                                  'surah': _surahName,
                                  'aya': verseId.toString(),
                                }),
                                description: text,
                                surahId: _controller.surahId,
                                verseId: verseId,
                              );
                              controller.updateVerseNotes(verseId, [
                                updatedNote,
                              ]);
                              Get.snackbar(
                                'note_saved'.tr,
                                msg,
                                backgroundColor: const Color(0xFF2E7D32),
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } else {
                              Get.snackbar(
                                'error'.tr,
                                'failed_save_note'.tr,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      disabledBackgroundColor: Colors.white60,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2E7D32),
                            ),
                          )
                        : Text(
                            'save_note'.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                // Delete button — only shown when a note exists
                if (hasNote) ...[
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isDeleting
                          ? null
                          : () async {
                              setState(() => isDeleting = true);
                              final ok = await noteService.deleteNote(
                                existingNote!.id,
                              );
                              setState(() => isDeleting = false);
                              if (context.mounted) Navigator.pop(context);
                              if (ok) {
                                controller.updateVerseNotes(verseId, []);
                                Get.snackbar(
                                  'note_deleted'.tr,
                                  'note_removed_msg'.tr,
                                  backgroundColor: Colors.grey[800],
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else {
                                Get.snackbar(
                                  'error'.tr,
                                  'failed_delete_note'.tr,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.red.shade200,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 0,
                      ),
                      child: isDeleting
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'delete_note'.tr,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 26.sp),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer() {
    final controller = _controller;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Speed button
            GestureDetector(
              onTap: () => controller.changePlaybackSpeed(),
              child: Obx(
                () => Text(
                  "${controller.playbackSpeed.value}x",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Playback controls
            Row(
              children: [
                GestureDetector(
                  onTap: () => controller.playPreviousVerse(),
                  child: Icon(
                    Icons.skip_previous,
                    color: Colors.grey[700],
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.togglePlayPause(),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () => controller.playNextVerse(),
                  child: Icon(
                    Icons.skip_next,
                    color: Colors.grey[700],
                    size: 28.sp,
                  ),
                ),
              ],
            ),

            // More options
            Icon(Icons.more_horiz, color: Colors.grey[600], size: 24.sp),
          ],
        ),
      ),
    );
  }
}
