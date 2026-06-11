import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/const/app_colors.dart' as AppColors;
import 'package:slide_to_act/slide_to_act.dart';

import '../../customExperiance/views/customExperiance.dart';

class onBoardind2 extends StatefulWidget {
  const onBoardind2({super.key});

  @override
  State<onBoardind2> createState() => _onBoardind2State();
}

class _onBoardind2State extends State<onBoardind2> {
  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() async {
    for (int i = 0; i < _images.length - 1; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _pageController.animateToPage(
        i + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final GlobalKey<SlideActionState> _slideKey = GlobalKey();

  final List<String> _images = [
    'assets/image/onboard1.jpg',
    'assets/image/onboard2.jpg',
    'assets/image/onboard3.jpg',
    'assets/image/onboard4.jpg',
    'assets/image/onboard5.jpg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: Image.asset(
                  _images[index],
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
          // Top Bar with progress and Skip
          _buildTopBar(),

          // Show SlideAction only on last image
          if (_currentPage == _images.length - 1)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 100.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35.r),
                ),
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.elasticOut, // Bouncy effect
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: SlideAction(
                        key: _slideKey,
                        onSubmit: () {
                          _slideKey.currentState!.reset();
                          Get.to(CustomizeExperienceScreen());
                          return null;
                        },
                        height: 50.h, // Using screenutil
                        borderRadius: 60.r,
                        elevation: 0,
                        innerColor: Colors.white,
                        outerColor: AppColors.primaryColor,
                        sliderButtonIcon: SizedBox(
                          width: 40.w,
                          height: 10.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/arrow_right.png',
                                width: 24.w,
                                height: 24.h,
                              ),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get started',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top - 10.h,
      left: 16.w,
      right: 16.w,
      child: Row(
        children: [
          // Progress Bars
          Expanded(
            child: Row(
              children: List.generate(_images.length, (index) {
                return Expanded(
                  child: Container(
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? AppColors.green
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(width: 15.w),
          // Skip Button
          GestureDetector(
            onTap: () {
              Get.to(CustomizeExperienceScreen());
            },
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
