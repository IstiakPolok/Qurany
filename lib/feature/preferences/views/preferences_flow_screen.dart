import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qurany/core/const/app_colors.dart';
import '../../auth/views/login_options_screen.dart';
import '../widgets/language_step.dart';
import '../widgets/script_step.dart';
import '../widgets/reciter_step.dart';
import '../widgets/goals_step.dart';

class PreferencesFlowScreen extends StatefulWidget {
  const PreferencesFlowScreen({super.key});

  @override
  State<PreferencesFlowScreen> createState() => _PreferencesFlowScreenState();
}

class _PreferencesFlowScreenState extends State<PreferencesFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to PreparingSpaceScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginOptionsScreen()),
      );
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/preferencesbg.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10.h),
                // Progress Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      ...List.generate(_totalSteps, (index) {
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: index <= _currentStep
                                  ? primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        );
                      }),
                      SizedBox(width: 10.w),
                      GestureDetector(
                        onTap: () {
                          // Handle Skip
                        },
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable swipe
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: const [
                      LanguageStep(),
                      ScriptStep(),
                      ReciterStep(),
                      GoalsStep(),
                    ],
                  ),
                ),

                // Bottom Navigation
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _prevPage,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                            ),
                            child: Text(
                              "Back",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                          child: Text(
                            "Next",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
