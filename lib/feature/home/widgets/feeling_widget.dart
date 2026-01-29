import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/home/widgets/feeling_bottom_sheet.dart';
import 'dart:math';

class FeelingWidget extends StatefulWidget {
  const FeelingWidget({super.key});

  @override
  State<FeelingWidget> createState() => _FeelingWidgetState();
}

class _FeelingWidgetState extends State<FeelingWidget> {
  Map<String, String>? _selectedFeeling;

  @override
  void initState() {
    super.initState();
    _loadSavedFeeling();
  }

  Future<void> _loadSavedFeeling() async {
    final savedFeeling = await SharedPreferencesHelper.getFeeling();
    setState(() {
      _selectedFeeling = savedFeeling;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            "Personalized your recommendation",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            final result = await showModalBottomSheet<Map<String, String>>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => const FeelingBottomSheet(),
            );

            if (result != null) {
              await SharedPreferencesHelper.saveFeeling(result);
            }
            // Always reload to sync with SharedPreferences (handles Clear and Dismiss)
            await _loadSavedFeeling();
          },
          child: _selectedFeeling != null
              ? _buildSelectedState()
              : _buildDefaultState(),
        ),
      ],
    );
  }

  Widget _buildDefaultState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E9D8), // Light green bg
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(
          color: const Color(0xFF2F7D33), // Matching the icon color
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          ClipPath(
            clipper: HexagonClipper(),
            child: Container(
              width: 36.w,
              height: 36.w,
              color: const Color(0xFF2E7D32),
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '😊',
                  style: TextStyle(
                    fontSize: 20.sp,
                    height: 1,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            "How do you feel today?",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildSelectedState() {
    // Based on image: Container with light background (already wrapper?), Text "You're feeling:" on left, Green Pill on right.
    // To match image, the outer container might need to be consistent or just use a generic container for this row.
    // The screenshot has a light green background for the whole row as well.
    // Let's use the same container style but change content.

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E9D8), // Same light green bg
        borderRadius: BorderRadius.circular(9.r),
        // Border might be optional in this state based on image, but keeping consistency is safe unless requested otherwise.
        border: Border.all(
          color: Colors
              .transparent, // Image doesn't show strong border, but let's keep it clean
          width: 0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "You're feeling:",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: () async {
              await SharedPreferencesHelper.clearFeeling();
              setState(() {
                _selectedFeeling = null;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32), // Dark green
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedFeeling!['emoji']!,
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _selectedFeeling!['label']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.close, color: Colors.white, size: 18.sp),
                ],
              ),
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
    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double centerY = height / 2;
    final double radius = width / 2;
    path.moveTo(
      centerX + radius * cos(-pi / 6),
      centerY + radius * sin(-pi / 6),
    );
    for (int i = 1; i <= 6; i++) {
      double angle = -pi / 6 + i * pi / 3;
      path.lineTo(centerX + radius * cos(angle), centerY + radius * sin(angle));
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
