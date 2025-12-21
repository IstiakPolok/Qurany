import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/const/app_colors.dart' as AppColors;
import 'package:slide_to_act/slide_to_act.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../customExperiance/views/customExperiance.dart';

class onBoardind2 extends StatefulWidget {
  onBoardind2({super.key});

  @override
  State<onBoardind2> createState() => _onBoardind2State();
}

class _onBoardind2State extends State<onBoardind2> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final GlobalKey<SlideActionState> _slideKey = GlobalKey();

  final List<String> _images = [
    'assets/image/onboard1.png',
    'assets/image/onboard2.png',
    'assets/image/onboard3.png',
    'assets/image/onboard4.png',
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
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              );
            },
          ),
          // Show close button only on last image
          if (_currentPage == _images.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                icon: Image.asset(
                  'assets/icons/close_icon.png',
                  width: 32,
                  height: 32,
                ),
                onPressed: () {
                  Get.to(CustomizeExperienceScreen());
                },
              ),
            ),

          // Show SlideAction only on last image
          if (_currentPage == _images.length - 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
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
                      },
                      height: 50, // Increased height
                      borderRadius: 60,
                      elevation: 0,
                      innerColor: Colors.white,
                      outerColor: AppColors.primaryColor,
                      sliderButtonIcon: SizedBox(
                        width: 40, // Increased width
                        height: 10, // Increased height
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/arrow_right.png',
                              width: 24,
                              height: 24,
                            ),
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get started',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
