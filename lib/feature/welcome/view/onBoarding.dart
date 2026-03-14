import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/welcome/view/onBoarding2.dart';

class onBoardind extends StatelessWidget {
  const onBoardind({super.key});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        Get.offAll(() => onBoardind2());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset('assets/image/bg2.png', fit: BoxFit.fill),
            ),

            // Centered logo
            Center(
              child: Image.asset(
                'assets/icons/logo.png',
                width: 200,
                height: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
