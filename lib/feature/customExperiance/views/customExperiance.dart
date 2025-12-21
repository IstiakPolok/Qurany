import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:qurany/feature/permissions/views/location_permission_screen.dart';

import '../../../core/const/app_colors.dart';
import '../../compass/widgets/classicCompass.dart';
import '../../compass/widgets/modernCompass.dart';
import '../../compass/widgets/cleanCompass.dart';

class CustomizeExperienceScreen extends StatefulWidget {
  @override
  _CustomizeExperienceScreenState createState() =>
      _CustomizeExperienceScreenState();
}

class _CustomizeExperienceScreenState extends State<CustomizeExperienceScreen> {
  String selectedVisual = 'Islamic';
  String selectedCompass = 'Modern';
  double _qiblaDirection =
      0; // Current Qibla direction relative to North (0-360)

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _calculateQibla(position.latitude, position.longitude);
  }

  void _calculateQibla(double lat, double lng) {
    // Kaaba coordinates
    double kaabaLat = 21.422487;
    double kaabaLng = 39.826206;

    double pi = math.pi;
    double rad = pi / 180.0;

    double phiK = kaabaLat * rad;
    double lambdaK = kaabaLng * rad;
    double phi = lat * rad;
    double lambda = lng * rad;

    double psi = math.atan2(
      math.sin(lambdaK - lambda),
      math.cos(phi) * math.tan(phiK) -
          math.sin(phi) * math.cos(lambdaK - lambda),
    );

    double qibla = psi / rad; // convert to degrees

    // Normalize to 0-360
    qibla = (qibla + 360) % 360;

    if (mounted) {
      setState(() {
        _qiblaDirection = qibla;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          // Top-aligned, fitted background image
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/image/customxp.png',
              fit: BoxFit.fitWidth,
              width: double.infinity,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildSelectionCard(
                          "Visual Style",
                          ["Minimal", "Islamic", "Ornate"],
                          selectedVisual,
                          (val) => setState(() => selectedVisual = val),
                        ),
                        const SizedBox(height: 16),
                        _buildSelectionCard(
                          "Qibla Compass",
                          ["Classic", "Modern", "Clean"],
                          selectedCompass,
                          (val) => setState(() => selectedCompass = val),
                        ),
                        const SizedBox(height: 20),
                        _buildPaginationDots(),
                        const SizedBox(height: 20),
                        _buildCompassPreview(),

                        _buildContinueButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: CircleAvatar(
              backgroundColor: Colors.white24,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),
          const Text(
            "Customize your Experience",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "See changes in real-time",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(
    String title,
    List<String> options,
    String current,
    Function(String) onSelect,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: options
                .map((opt) => _buildOptionButton(opt, opt == current, onSelect))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    String label,
    bool isSelected,
    Function(String) onSelect,
  ) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: GestureDetector(
          onTap: () => onSelect(label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white30),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompassPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Compass preview (changes with selectedCompass)
          StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              double heading = snapshot.data?.heading ?? 0;

              if (selectedCompass == 'Modern') {
                return ModernCompass(
                  heading: heading,
                  qiblaAngle: _qiblaDirection,
                );
              }
              if (selectedCompass == 'Clean') {
                return CleanCompass(
                  heading: heading,
                  qiblaAngle: _qiblaDirection,
                );
              }
              // Default to Classic
              return ClassicCompass(
                heading: heading,
                qiblaAngle: _qiblaDirection,
              );
            },
          ),
          const SizedBox(height: 30),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.compass, size: 20, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                "Qibla Compass",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallPreview(
                "Classic",
                "assets/image/classic_icon.png",
                selectedCompass == 'Classic',
              ),
              _buildSmallPreview(
                "Modern",
                "assets/image/modern_icon.png",
                selectedCompass == 'Modern',
              ),
              _buildSmallPreview(
                "Clean",
                "assets/image/clean_icon.png",
                selectedCompass == 'Clean',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPreview(String label, String img, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCompass = label;
        });
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: Colors.green, width: 2)
                  : Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(
                img,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.compass_calibration,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      // Remove padding here to let the white background fill to the bottom
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(45),
            ),
          ),
          onPressed: () {
            Get.to(LocationPermissionScreen());
          },
          child: const Text(
            "Continue",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: selectedCompass == 'Classic' ? 20 : 4,
          height: 4,
          decoration: BoxDecoration(
            color: selectedCompass == 'Classic' ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: selectedCompass == 'Modern' ? 20 : 4,
          height: 4,
          decoration: BoxDecoration(
            color: selectedCompass == 'Modern' ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: selectedCompass == 'Clean' ? 20 : 4,
          height: 4,
          decoration: BoxDecoration(
            color: selectedCompass == 'Clean' ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
