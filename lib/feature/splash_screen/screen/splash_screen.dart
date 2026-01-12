import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/splash_screen_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});
  final SplashScreenController controller = Get.put(SplashScreenController());

  @override
  Widget build(BuildContext context) {
    //var screenWidth = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          // Background image (fills the whole screen)
          Positioned.fill(
            child: Image.asset(
              'assets/image/bg.jpg', // replace with your background image path
              fit: BoxFit.fill,
            ),
          ),

          // Centered image
          Center(
            child: Image.asset(
              'assets/icons/logo.png', // replace with your center image path
              width: 200, // optional size
              height: 200,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 3 * 3.1415926535),
                duration: const Duration(seconds: 4),
                curve: Curves.linear,
                onEnd: () {},
                builder: (context, angle, child) {
                  return Transform.rotate(angle: angle, child: child);
                },
                child: Image.asset(
                  'assets/image/loader.png',

                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
