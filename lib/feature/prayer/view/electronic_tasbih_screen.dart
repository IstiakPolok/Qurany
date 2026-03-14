import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'dart:ui' as ui;
import 'package:get/get.dart';

class ElectronicTasbihScreen extends StatefulWidget {
  const ElectronicTasbihScreen({super.key});

  @override
  State<ElectronicTasbihScreen> createState() => _ElectronicTasbihScreenState();
}

class _ElectronicTasbihScreenState extends State<ElectronicTasbihScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _round = 1;
  int _targetCount = 100; // Example target
  double _dragOffset = 0.0;
  final double _beadSpacing = 35.0; // Spacing between beads
  late Path _beadPath;
  ui.PathMetric? _pathMetric;
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  int? _currentlyPlayingIndex;

  // Bead style: maps style name to ball image asset
  static const Map<String, String> _beadStyles = {
    'Green': 'assets/image/greenball.png',
    'Orange': 'assets/image/ornageball.png',
    'Parrot': 'assets/image/parrotball.png',
  };
  String _selectedBeadStyle = 'Green';

  final List<Map<String, String>> _dhikrList = [
    {
      "arabic": "سُبْحَانَ الله",
      "meaning": "dhikr_subhanallah".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic": "الْحَمْدُ لِلّٰهِ",
      "meaning": "dhikr_alhamdulillah".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic": "اللهُ أَكْبَرُ",
      "meaning": "dhikr_allahuakbar".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic": "لَا إِلٰهَ إِلَّا الله",
      "meaning": "dhikr_lailahaillallah".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic": "أَسْتَغْفِرُ الله",
      "meaning": "dhikr_astaghfirullah".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic": "سُبْحَانَ اللهِ وَبِحَمْدِهِ",
      "meaning": "dhikr_subhanallah_wabitahmidihi".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic": "لا حول ولاقوة إلا بالله",
      "meaning": "dhikr_lahawla".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic": "حسبي الله لا إله إلا هو",
      "meaning": "dhikr_hasbiyallah".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic": "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ",
      "meaning": "dhikr_salawat".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic": "سُبْحَانَ اللهِ وَبِحَمْدِهِ، سُبْحَانَ اللهِ الْعَظِيم",
      "meaning": "dhikr_subhanallah_alazim".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic":
          "لا إِلٰهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِير",
      "meaning": "dhikr_lailahaillallah_wahdahu".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
    {
      "arabic":
          "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيم",
      "meaning": "dhikr_bismillah_la_yadurru".tr,
      "audio": "assets/audio/subhanallah.mp3",
    },
  ];
  int? _selectedDhikrIndex;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          if (state == PlayerState.completed || state == PlayerState.stopped) {
            _currentlyPlayingIndex = null;
          }
        });
      }
    });
    // Initialize standard path for metrics calculation (will be updated in build with actual constraints)
    // Defer actual path creation to build/layout where we have dimensions
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _counter = prefs.getInt('electronic_tasbih_counter') ?? 0;
        _round = prefs.getInt('electronic_tasbih_round') ?? 1;
        _targetCount = prefs.getInt('electronic_tasbih_target') ?? 100;
        _selectedDhikrIndex = prefs.getInt('electronic_tasbih_dhikr_index');
        _selectedBeadStyle =
            prefs.getString('electronic_tasbih_bead_style') ?? 'Green';
      });
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('electronic_tasbih_counter', _counter);
    await prefs.setInt('electronic_tasbih_round', _round);
    await prefs.setInt('electronic_tasbih_target', _targetCount);
    if (_selectedDhikrIndex != null) {
      await prefs.setInt('electronic_tasbih_dhikr_index', _selectedDhikrIndex!);
    } else {
      await prefs.remove('electronic_tasbih_dhikr_index');
    }
    await prefs.setString('electronic_tasbih_bead_style', _selectedBeadStyle);
  }

  void _calculatePath(Size size) {
    final path = Path();
    // Move the curve a bit lower by increasing all y values
    double verticalShift = 60.h; // Move down by 60 screen units
    path.moveTo(-size.width * 0.25, size.height * 0.98 + verticalShift);
    path.cubicTo(
      size.width * -0.18,
      size.height * 0.05 + verticalShift, // Even more curve (left outside)
      size.width * 0.8,
      -size.height * 0.9 + verticalShift, // Much higher peak for stronger arc
      size.width * 1.25,
      size.height * 0.01 + verticalShift,
    );
    _beadPath = path;
    _pathMetric = _beadPath.computeMetrics().first;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.primaryDelta!;

      // Threshold logic for counting
      if (_dragOffset <= -_beadSpacing) {
        // Dragged left (next bead)
        _incrementCounter();
        _dragOffset += _beadSpacing;
      } else if (_dragOffset >= _beadSpacing) {
        // Dragged right (previous bead)
        _decrementCounter();
        _dragOffset -= _beadSpacing;
      }
    });
  }

  void _incrementCounter() {
    HapticFeedback.lightImpact();
    setState(() {
      _counter++;
      if (_counter > _targetCount) {
        _counter = 1;
        _round++;
        HapticFeedback.mediumImpact();
      }
    });
    _savePreferences();
    SharedPreferencesHelper.incrementDailyDhikr();
  }

  void _decrementCounter() {
    if (_counter > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _counter--;
      });
      _savePreferences();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(int index) async {
    final audioPath = _dhikrList[index]['audio']!;
    debugPrint("Attempting to play: $audioPath at index $index");
    try {
      String path = audioPath;
      if (path.startsWith('assets/')) {
        path = path.substring(7);
      }
      debugPrint("Resolved asset path: $path");

      if (_playerState == PlayerState.playing &&
          _currentlyPlayingIndex == index) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingIndex = null;
        });
      } else {
        await _audioPlayer.stop(); // Stop any currently playing audio
        await _audioPlayer.play(AssetSource(path));
        setState(() {
          _currentlyPlayingIndex = index;
        });
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _showEditDialog() {
    // Local state for bottom sheet
    int tempTargetCount = _targetCount;
    int tempRound = _round;
    int tempCustomCount = _counter;
    bool soundFeedback = true;
    bool vibration = true;
    final List<int> presetCounts = [11, 33, 50, 99, 100, 300, 500, 1000];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFDF7F0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24.w,
                right: 24.w,
                top: 20.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
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
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "customize_tasbih".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 40.w), // For symmetry
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Target Count per Round
                    Text(
                      "target_count_round".tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // First row of chips
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: presetCounts.map((count) {
                        final bool isSelected = tempTargetCount == count;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              tempTargetCount = count;
                            });
                          },
                          child: _buildHexagonChip(
                            count.toString(),
                            isSelected,
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 24.h),

                    // Custom Count
                    Text(
                      "custom_count".tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: tempCustomCount.toString(),
                              ),
                              onChanged: (value) {
                                tempCustomCount =
                                    int.tryParse(value) ?? tempCustomCount;
                              },
                            ),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    setSheetState(() => tempCustomCount++),
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.grey[600],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (tempCustomCount > 0) {
                                    setSheetState(() => tempCustomCount--);
                                  }
                                },
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Number of Rounds
                    Text(
                      "number_of_rounds".tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: tempRound.toString(),
                              ),
                              onChanged: (value) {
                                tempRound = int.tryParse(value) ?? tempRound;
                              },
                            ),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => setSheetState(() => tempRound++),
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.grey[600],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (tempRound > 1) {
                                    setSheetState(() => tempRound--);
                                  }
                                },
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),
                    Divider(color: Colors.grey[300]),

                    // Sound Feedback Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "sound_feedback".tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                        Switch(
                          value: soundFeedback,
                          onChanged: (val) =>
                              setSheetState(() => soundFeedback = val),
                          activeThumbColor: const Color(0xFF2E7D32),
                        ),
                      ],
                    ),

                    // Vibration Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "vibration".tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                        Switch(
                          value: vibration,
                          onChanged: (val) =>
                              setSheetState(() => vibration = val),
                          activeThumbColor: const Color(0xFF2E7D32),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _targetCount = tempTargetCount;
                            _round = tempRound;
                            _counter = tempCustomCount;
                          });
                          _savePreferences();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        child: Text(
                          "save".tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHexagonChip(String text, bool isSelected) {
    return Container(
      width: 48.w,
      height: 48.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: isSelected
              ? AssetImage('assets/image/hexashape2.png')
              : AssetImage('assets/image/hexashape.png'),
          fit: BoxFit.fill,
          // Light green for unselected
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _currentDhikrCard() {
    final bool hasSelection = _selectedDhikrIndex != null;
    if (!hasSelection) {
      return Container(
        padding: EdgeInsets.only(top: 20.w, left: 16.w, bottom: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE2EAD8),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "choose_your_dhikr".tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),

                  Text(
                    "start_counting_blessings".tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton(
                    onPressed: _showDhikrPicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(70.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 0.h,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "select_your_dhikr".tr,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/image/tasbih_hand.png',
              height: 70.h,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    }
    final String arabic = _dhikrList[_selectedDhikrIndex!]['arabic']!;
    final String meaning = _dhikrList[_selectedDhikrIndex!]['meaning']!;
    final bool isPlaying =
        _playerState == PlayerState.playing &&
        _currentlyPlayingIndex == _selectedDhikrIndex;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "current_dhikr".tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                color: Colors.black87,
              ),
            ),
            Spacer(),

            GestureDetector(
              onTap: _showDhikrPicker,
              child: Text(
                "view_all".tr,
                style: TextStyle(
                  color: Colors.green[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            IconButton(
              onPressed: _showClearDialog,
              icon: Icon(
                Icons.delete_outline,
                color: Colors.black87,
                size: 20.sp,
              ),
            ),
          ],
        ),

        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _playAudio(_selectedDhikrIndex!),
                child: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_arrow,
                  color: Colors.green,
                  size: 32.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      arabic,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      meaning,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDhikrPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFDF7F0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        // Use StatefulBuilder so the bottom sheet can rebuild independently
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Helper to handle play within sheet
            Future<void> playAudioInSheet(int index) async {
              await _playAudio(index);
              // Update sheet state to reflect icon change
              setSheetState(() {});
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 24.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "select_your_dhikr".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 40), // for symmetry
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ...List.generate(_dhikrList.length, (index) {
                      final dhikr = _dhikrList[index];
                      final bool isPlayingThis =
                          _playerState == PlayerState.playing &&
                          _currentlyPlayingIndex == index;
                      return GestureDetector(
                        onTap: () {
                          // Stop audio if playing when selecting a new dhikr
                          if (_playerState == PlayerState.playing) {
                            _playAudio(index); // This toggles it off
                          }
                          setState(() {
                            _selectedDhikrIndex = index;
                          });
                          _savePreferences();
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 14.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => playAudioInSheet(index),
                                child: Icon(
                                  isPlayingThis
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_fill,
                                  color: Colors.green,
                                  size: 28.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      dhikr['arabic']!,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      dhikr['meaning']!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[700],
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _clearData() {
    setState(() {
      _counter = 0;
      _round = 1;
      _selectedDhikrIndex = null;
    });
    _savePreferences();
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("clear_data".tr),
          content: Text("clear_confirm_msg".tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("cancel".tr),
            ),
            TextButton(
              onPressed: () {
                _clearData();
                Navigator.pop(context);
              },
              child: Text(
                "clear".tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
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
        centerTitle: true,
        title: Text(
          "electronic_tasbih".tr,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: _currentDhikrCard(),
          ),

          SizedBox(height: 12.h),

          // Dhikr Count
          Text(
            "dhikr_count".tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),

          // Hexagon Counter
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130.w,
                height: 145.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/image/Polygon.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$_counter / $_targetCount",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "round".tr + " $_round",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showEditDialog,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2EAD8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 5.h),

          // Beads Curve & Interaction
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final beadHeight = constraints.maxHeight;
                  _calculatePath(Size(constraints.maxWidth, beadHeight));
                  return SizedBox(
                    height: beadHeight,
                    width: constraints.maxWidth,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, beadHeight),
                            painter: BeadPathPainter(_beadPath),
                          ),
                        ),
                        ..._buildVisibleBeads(constraints.maxWidth, beadHeight),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              "swipe_instruction".tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),

          // Style Selector
          SizedBox(
            height: 80.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildStyleItem(
                  "Green",
                  'assets/image/1.png',
                  _selectedBeadStyle == 'Green',
                ),
                _buildStyleItem(
                  "Orange",
                  'assets/image/2.png',
                  _selectedBeadStyle == 'Orange',
                ),
                _buildStyleItem(
                  "Parrot",
                  'assets/image/3.png',
                  _selectedBeadStyle == 'Parrot',
                ),
                _buildStyleItem(
                  "Galaxy",
                  'assets/image/4.png',
                  false,
                  isLocked: true,
                ),
                _buildStyleItem(
                  "Galaxy",
                  'assets/image/5.png',
                  false,
                  isLocked: true,
                ),
                _buildStyleItem(
                  "Galaxy",
                  'assets/image/6.png',
                  false,
                  isLocked: true,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Premium Unlock
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFECEFE2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF2F7D33)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28.w,
                        height: 30.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/image/Polygon.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                        child: Icon(
                          Icons.lock_open,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "unlock_premium_styles".tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              "compass_unlock_desc".tr,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: LinearProgressIndicator(
                                      value: 0.33,
                                      backgroundColor: Colors.grey[300],
                                      color: const Color(0xFF2E7D32),
                                      minHeight: 5.h,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  "33%",
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "compass_unlock_progress".trParams({
                                'count': '2',
                                'name': 'Other',
                              }),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2F7D33),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 25.h),
        ],
      ),
    );
  }

  List<Widget> _buildVisibleBeads(double width, double height) {
    if (_pathMetric == null) return [];

    List<Widget> beads = [];
    final double pathLength = _pathMetric!.length;
    final double centerOffset = pathLength / 2;

    // Render beads so they overflow out of the screen
    // Increase range to cover more beads
    for (int i = -10; i <= 10; i++) {
      double beadLinearPos = centerOffset + _dragOffset + (i * _beadSpacing);

      // Map to path if within bounds
      if (beadLinearPos >= 0 && beadLinearPos <= pathLength) {
        final Tangent? tangent = _pathMetric!.getTangentForOffset(
          beadLinearPos,
        );
        if (tangent != null) {
          final bool isCenterBead = i == 0;
          beads.add(
            Positioned(
              left: tangent.position.dx - 20.w,
              top: tangent.position.dy - 20.w,
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isCenterBead
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, -4),
                          ),
                        ],
                ),
                child: isCenterBead
                    ? null
                    : Image.asset(
                        _beadStyles[_selectedBeadStyle] ??
                            'assets/image/greenball.png',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          );
        }
      }
    }
    return beads;
  }

  Widget _buildStyleItem(
    String label,
    String imagePath,
    bool isSelected, {
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              setState(() {
                _selectedBeadStyle = label;
              });
              _savePreferences();
            },
      child: Stack(
        children: [
          Container(
            decoration: isSelected
                ? BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2E7D32),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  )
                : null,
            child: Image.asset(
              imagePath,
              width: 100.w,
              height: 80.h,
              fit: BoxFit.contain,
            ),
          ),
          if (isLocked)
            Positioned(
              top: 0.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.all(3.w),

                child: Icon(Icons.lock, size: 12.sp, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(0, size.height * 0.75);
    path.lineTo(0, size.height * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class BeadPathPainter extends CustomPainter {
  final Path path;
  BeadPathPainter(this.path);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw the passed path
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HexagonChipClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    // Simple hexagon shape for chips
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
