import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:qurany/core/const/app_colors.dart'; // Removed unused import

class FeelingBottomSheet extends StatefulWidget {
  const FeelingBottomSheet({super.key});

  @override
  State<FeelingBottomSheet> createState() => _FeelingBottomSheetState();
}

class _FeelingBottomSheetState extends State<FeelingBottomSheet> {
  Map<String, String>? _selectedFeeling;

  final List<Map<String, String>> _feelings = [
    {"emoji": "😃", "label": "Happy"},
    {"emoji": "🙂", "label": "OK"},
    {"emoji": "😐", "label": "Neutral"},
    {"emoji": "😟", "label": "Sad"},
    {"emoji": "😔", "label": "Very Sad"},
    {"emoji": "😫", "label": "Panicked"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Header Row
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFeeling = null;
                });
              },
              child: Text(
                "Clear",
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _feelings.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) {
              final feeling = _feelings[index];
              final isSelected = _selectedFeeling?["label"] == feeling["label"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFeeling = feeling;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        feeling["emoji"]!,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        feeling["label"]!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 32.h),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedFeeling);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h + MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }
}
