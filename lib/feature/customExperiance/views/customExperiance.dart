import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/feature/permissions/views/location_permission_screen.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

import '../../../core/const/app_colors.dart';
import '../../../core/global_widgets/outlined_close_button.dart';
import '../../compass/widgets/classicCompass.dart';
import '../../compass/widgets/modernCompass.dart';
import '../../compass/widgets/cleanCompass.dart';

class CustomizeExperienceScreen extends StatefulWidget {
  const CustomizeExperienceScreen({super.key});

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
    _loadSavedCompassStyle();
    _determinePosition();
  }

  void _loadSavedCompassStyle() async {
    final savedStyle = await SharedPreferencesHelper.getCompassStyle();
    if (mounted) {
      setState(() {
        selectedCompass = savedStyle;
      });
    }
  }

  void _saveCompassStyle(String style) async {
    await SharedPreferencesHelper.saveCompassStyle(style);
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
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    // Base height for the bottom sheet (approx: top+button+bottom padding)
    final bottomSheetBase = 96.0;
    final bottomSheetHeight = bottomSheetBase + mq.viewPadding.bottom;

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
                    padding: EdgeInsets.only(bottom: bottomSheetHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        SizedBox(height: width * 0.02),

                        _buildSelectionCard(
                          "Qibla Compass",
                          ["Classic", "Modern", "Clean"],
                          selectedCompass,
                          (val) {
                            setState(() => selectedCompass = val);
                            _saveCompassStyle(val);
                          },
                        ),
                        SizedBox(height: width * 0.05),
                        _buildPaginationDots(),
                        SizedBox(height: width * 0.05),
                        _buildCompassPreview(),

                        SizedBox(height: width * 0.05),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: _buildContinueButton(),
    );
  }

  Widget _buildHeader() {
    final width = MediaQuery.of(context).size.width;
    final hPad = (width * 0.05).clamp(12.0, 32.0);
    final vPad = (width * 0.03).clamp(8.0, 22.0);
    final headlineSize = (width * 0.05).clamp(18.0, 22.0);
    final subtitleSize = (width * 0.03).clamp(12.0, 14.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedCloseButton(onPressed: () => Navigator.pop(context)),
          ),
          SizedBox(height: vPad * 0.5),
          Text(
            "Customize your Experience",
            style: GoogleFonts.abhayaLibre(
              color: Colors.white,
              fontSize: headlineSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: vPad * 0.25),
          Text(
            "See changes in real-time",
            style: TextStyle(color: Colors.white70, fontSize: subtitleSize),
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
    final width = MediaQuery.of(context).size.width;
    final hMargin = (width * 0.05).clamp(12.0, 32.0);
    final innerPadding = (width * 0.03).clamp(8.0, 20.0);
    final titleSize = (width * 0.035).clamp(12.0, 16.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hMargin),
      padding: EdgeInsets.all(innerPadding),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: titleSize + 4,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: titleSize,
                ),
              ),
            ],
          ),
          SizedBox(height: innerPadding * 0.7),
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
    final width = MediaQuery.of(context).size.width;
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: GestureDetector(
          onTap: () => onSelect(label),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: (width * 0.03).clamp(8.0, 16.0),
              vertical: (width * 0.025).clamp(6.0, 12.0),
            ),
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
                    fontSize: (width * 0.03).clamp(11.0, 14.0),
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
    final width = MediaQuery.of(context).size.width;
    final hMargin = (width * 0.05).clamp(12.0, 32.0);
    final innerPad = (width * 0.06).clamp(16.0, 40.0);
    final radius = (width * 0.08).clamp(20.0, 40.0);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hMargin),
      padding: EdgeInsets.all(innerPad),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.all(Radius.circular(radius)),
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
          SizedBox(height: innerPad * 1),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                CupertinoIcons.compass,
                size: (width * 0.05).clamp(14.0, 20.0),
                color: Colors.grey,
              ),
              SizedBox(width: 6),
              Text(
                "Qibla Compass",
                style: TextStyle(
                  fontSize: (width * 0.03).clamp(11.0, 14.0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: innerPad * 0.5),
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
    final width = MediaQuery.of(context).size.width;
    final pad = (width * 0.02).clamp(6.0, 12.0);
    final size = (width * 0.09).clamp(32.0, 60.0);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCompass = label;
        });
        _saveCompassStyle(label);
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: Colors.green, width: 2)
                  : Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: size,
              height: size,
              child: Image.asset(
                img,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.compass_calibration,
                  size: size * 0.9,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: (width * 0.03).clamp(11.0, 13.0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        // Remove padding here to let the white background fill to the bottom
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBF2),
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
