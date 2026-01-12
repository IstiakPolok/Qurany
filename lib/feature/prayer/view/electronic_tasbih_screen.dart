import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

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

  final List<Map<String, String>> _dhikrList = [
    {
      'arabic': 'أستغفرُ اللهَ ربي وأتوبُ إليهِ',
      'translation':
          'I seek forgiveness from Allah, my Lord, for every sin and I turn to Him in repentance.',
    },
    {
      'arabic': 'اللهم اغفر لي ذنوبي كلها',
      'translation': 'O Allah, forgive me all my sins.',
    },
    {
      'arabic': 'أسألك ربي كل خير',
      'translation': 'I ask You, my Lord, for all that is good.',
    },
    {
      'arabic': 'أعوذ بك من عذاب النار',
      'translation': 'I seek refuge in You from the punishment of the Fire.',
    },
    {
      'arabic': 'اللهم اجعلني من التوابين',
      'translation': 'O Allah, make me one of those who repent.',
    },
  ];
  int? _selectedDhikrIndex;

  @override
  void initState() {
    super.initState();
    // Initialize standard path for metrics calculation (will be updated in build with actual constraints)
    // Defer actual path creation to build/layout where we have dimensions
  }

  void _calculatePath(Size size) {
    final path = Path();
    // Arc from bottom-left going up to top-right then curving down
    path.moveTo(0, size.height * 0.9);
    path.cubicTo(
      size.width * 0.15,
      size.height * 0.3, // First control point
      size.width * 0.5,
      -size.height * 0.3, // Second control point (peak)
      size.width,
      size.height * 0.1, // End point (top-right)
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
  }

  void _decrementCounter() {
    if (_counter > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _counter--;
      });
    }
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _round = 1;
    });
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
                              "Customize Tasbih Counts",
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
                      "Target Count per Round",
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
                      "Custom Count",
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
                      "Number of Rounds",
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
                          "Sound Feedback",
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
                          "Vibration",
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
                          "Save",
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
                    "Choose Your Dhikr",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Start counting blessings with the zikr that speaks to your heart.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[800],
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16.h),
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
                      "Select Your Dhikr",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/image/tasbih_hand.png',
              height: 110.h,
              fit: BoxFit.contain,
            ),
          ],
        ),
      );
    }
    final String arabic = _dhikrList[_selectedDhikrIndex!]['arabic']!;
    final String translation = _dhikrList[_selectedDhikrIndex!]['translation']!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Current Dhikr",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: _showDhikrPicker,
              child: Text(
                "View all",
                style: TextStyle(
                  color: Colors.green[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
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
              Icon(Icons.play_arrow, color: Colors.green, size: 32.sp),
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
                      translation,
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
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 24.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          ),
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
                        "Select Dhikr",
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
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDhikrIndex = index;
                    });
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
                        Icon(
                          Icons.play_circle_fill,
                          color: Colors.green,
                          size: 28.sp,
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
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                dhikr['translation']!,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recalculate path metrics based on current screen size
    _calculatePath(Size(MediaQuery.of(context).size.width, 160.h));

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
          "Electric Tasbih",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _currentDhikrCard(),
            ),

            SizedBox(height: 32.h),

            // Dhikr Count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                "Dhikr Count",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Hexagon Counter
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160.w,
                  height: 175.w,
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
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Round $_round",
                        style: TextStyle(
                          fontSize: 14.sp,
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
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EAD8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40.h),

            // Beads Curve & Interaction
            GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              child: SizedBox(
                height: 160.h,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // The Curve Path
                    Positioned(
                      top: 0,
                      left: 0,
                      child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, 160.h),
                        painter: BeadPathPainter(_beadPath),
                      ),
                    ),

                    // Dynamic Beads
                    ..._buildVisibleBeads(
                      MediaQuery.of(context).size.width,
                      160.h,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),
            Text(
              "Right to left swipe will\ndecrease count",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),

            SizedBox(height: 40.h),

            // Style Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  _buildStyleItem("Green", 'assets/image/1.png', true),

                  _buildStyleItem("Orange", 'assets/image/2.png', false),

                  _buildStyleItem("Parrot", 'assets/image/3.png', false),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
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

            SizedBox(height: 32.h),

            // Premium Unlock
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFE2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFECEFE2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_open,
                          color: const Color(0xFF2E7D32),
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Unlock Premium Styles",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Continue using and engaging with Qurany+ to unlock beautiful new compass styles!",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: 0.33,
                              backgroundColor: Colors.grey[300],
                              color: const Color(0xFF2E7D32),
                              minHeight: 6.h,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          "33%",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Complete 2 more goals to unlock \"Other\" colors",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVisibleBeads(double width, double height) {
    if (_pathMetric == null) return [];

    List<Widget> beads = [];
    final double pathLength = _pathMetric!.length;
    final double centerOffset = pathLength / 2;

    // We render multiple beads to fill the path
    // Range of beads to render relative to "center" (index 0)
    for (int i = -5; i <= 5; i++) {
      // Calculate abstract distance on the line
      double beadLinearPos = centerOffset + _dragOffset + (i * _beadSpacing);

      // Map to path if within bounds
      if (beadLinearPos >= 0 && beadLinearPos <= pathLength) {
        final Tangent? tangent = _pathMetric!.getTangentForOffset(
          beadLinearPos,
        );
        if (tangent != null) {
          // Different color for center bead (i == 0)
          final bool isCenterBead = i == 0;

          beads.add(
            Positioned(
              left: tangent.position.dx - 17.5.w, // Adjust for center anchor
              top: tangent.position.dy - 17.5.w, // Center anchor adjustment
              child: Container(
                width: 35.w,
                height: 35.w,
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
    return Column(
      children: [
        Image.asset(
          imagePath,
          width: 120.w,
          height: 100.w,
          fit: BoxFit.contain,
        ),
      ],
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
