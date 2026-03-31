import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/welcome/view/onBoarding2.dart';

class onBoardind extends StatefulWidget {
  const onBoardind({super.key});

  @override
  State<onBoardind> createState() => _onBoardindState();
}

class _onBoardindState extends State<onBoardind> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Get.offAll(() => onBoardind2());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _startTimer(),
      onPointerMove: (_) => _startTimer(),
      child: GestureDetector(
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
      ),
    );
  }
}
