import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qurany/feature/bottom_nav_bar/screen/bottom_nav_bar.dart';
import 'package:qurany/core/services/purchase_api.dart';

import '../../../core/const/gradiant_loader.dart';

class PreparingSpaceScreen extends StatefulWidget {
  const PreparingSpaceScreen({super.key});

  @override
  State<PreparingSpaceScreen> createState() => _PreparingSpaceScreenState();
}

class _PreparingSpaceScreenState extends State<PreparingSpaceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Navigate to BottomNavbar after 3 seconds, showing onboarding paywall if needed
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        await PurchaseApi.presentPaywallIfNeededForPlacement('onboarding');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BottomNavbar()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/bgloginload.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/123.png',
                          width: 36.w,
                          height: 36.h,
                          color: Colors.white,
                        ),
                        Text(
                          "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللهِ وَبَرَكَاتُهُ",
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                            fontFamily: 'Arial',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Indeed, the patient will be given their reward\nwithout account.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Surah Az-Zumar-10",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50.h),
              Center(
                child: GradientLoader(
                  size: 80,
                  strokeWidth: 15,
                  colors: [Color.fromARGB(255, 197, 197, 197), Colors.white],
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                "Preparing your space,",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "May it lead you to goodness.",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
