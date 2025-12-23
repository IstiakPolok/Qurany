import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qurany/core/const/app_colors.dart';

import '../../compass/widgets/classicCompass.dart';
import '../../compass/widgets/modernCompass.dart';
import '../../compass/widgets/cleanCompass.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> {
  bool _showExpandedCompass = false;
  String _selectedCompass = 'Classic';
  double _qiblaDirection = 261.0; // Default Qibla direction
  double _distanceToMakkah = 345.66; // km
  double _currentHeading = 245.0;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    _calculateQibla(position.latitude, position.longitude);
    _calculateDistance(position.latitude, position.longitude);
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
    qibla = (qibla + 360) % 360;

    if (mounted) {
      setState(() {
        _qiblaDirection = qibla;
      });
    }
  }

  void _calculateDistance(double lat, double lng) {
    // Kaaba coordinates
    double kaabaLat = 21.422487;
    double kaabaLng = 39.826206;

    double distance = Geolocator.distanceBetween(lat, lng, kaabaLat, kaabaLng);
    if (mounted) {
      setState(() {
        _distanceToMakkah = distance / 1000; // Convert to km
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: _showExpandedCompass
          ? Column(
              children: [
                // Custom AppBar for expanded view
                Container(
                  padding: EdgeInsets.only(
                    top: 50.h,
                    left: 16.w,
                    right: 16.w,
                    bottom: 16.h,
                  ),
                  color: const Color(0xFFFFF9F0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showExpandedCompass = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9F0),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 16.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Compass View",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 40), // symmetry
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                _buildStatsRow(),
                SizedBox(height: 16.h),
                _buildCompassSection(),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Map Header Section
                  _buildMapHeader(),

                  // Prayer Info Row
                  _buildPrayerInfoRow(),

                  // Stats Row
                  _buildStatsRow(),

                  SizedBox(height: 16.h),

                  // Compass Section
                  _buildCompassSection(),

                  SizedBox(height: 16.h),

                  // Expand View Button
                  _buildExpandViewButton(),

                  SizedBox(height: 24.h),

                  // Qibla Compass Style Selector
                  _buildCompassStyleSelector(),

                  SizedBox(height: 24.h),

                  // Premium Unlock Banner
                  _buildPremiumBanner(),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
    );
  }

  Widget _buildMapHeader() {
    return Stack(
      children: [
        // Map placeholder
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/googlemapdemo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Back button
        Positioned(
          top: 50.h,
          left: 16.w,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        // Expand map button
        Positioned(
          top: 50.h,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(Icons.open_in_full, size: 20.sp, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerInfoRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      color: const Color(0xFFFFF9F0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Next Prayer",
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    size: 18.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    "Asr",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "11:55 AM",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(
                "in 37m 13s",
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            "${_distanceToMakkah.toStringAsFixed(2)} KM",
            "To Makkah",
          ),
          Container(width: 1, height: 40.h, color: Colors.grey[400]),
          _buildStatItem("${_currentHeading.toInt()}°", "Current Heading"),
          Container(width: 1, height: 40.h, color: Colors.grey[400]),
          _buildStatItem("${_qiblaDirection.toInt()}°", "Qibla direction"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCompassSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          double heading = snapshot.data?.heading ?? 0;
          _currentHeading = heading;

          Widget compass;
          switch (_selectedCompass) {
            case 'Modern':
              compass = ModernCompass(
                heading: heading,
                qiblaAngle: _qiblaDirection,
              );
              break;
            case 'Clean':
              compass = CleanCompass(
                heading: heading,
                qiblaAngle: _qiblaDirection,
              );
              break;
            default:
              compass = ClassicCompass(
                heading: heading,
                qiblaAngle: _qiblaDirection,
              );
          }

          return compass;
        },
      ),
    );
  }

  Widget _buildExpandViewButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showExpandedCompass = true;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(color: primaryColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.open_in_full, size: 18.sp, color: Colors.black87),
            SizedBox(width: 8.w),
            Text(
              "Expand View",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompassStyleSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.explore_outlined,
                size: 18.sp,
                color: Colors.grey[600],
              ),
              SizedBox(width: 8.w),
              Text(
                "Qibla Compass",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // First row - Unlocked styles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompassOption(
                "Classic",
                'assets/image/classic_icon.png',
                false,
              ),
              _buildCompassOption(
                "Modern",
                'assets/image/modern_icon.png',
                false,
              ),
              _buildCompassOption(
                "Clean",
                'assets/image/clean_icon.png',
                false,
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Second row - Locked premium styles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompassOption(
                "Ornate",
                'assets/image/ornateCompass.png',
                true,
              ),
              _buildCompassOption("Neon", 'assets/image/neonCOmpass.png', true),
              _buildCompassOption(
                "Galaxy",
                'assets/image/galaxycompass.png',
                true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompassOption(String label, String imagePath, bool isLocked) {
    final bool isSelected = _selectedCompass == label;

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              setState(() {
                _selectedCompass = label;
              });
            },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90.w,
                height: 90.w,
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey[200] : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16.r),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF2E7D32), width: 2)
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.explore,
                      size: 40.sp,
                      color: isLocked ? Colors.grey : const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              if (isLocked)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock, size: 12.sp, color: Colors.grey),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: isLocked
                  ? Colors.grey
                  : (isSelected ? const Color(0xFF2E7D32) : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.lock_open, size: 20.sp, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Unlock Premium Styles",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Continue using and engaging with Qurany+ to unlock beautiful new compass styles!",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: 0.33,
                          backgroundColor: Colors.white,
                          color: const Color(0xFF2E7D32),
                          minHeight: 6.h,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "33%",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  "Complete 2 more goals to unlock \"Ornate\" style",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF2E7D32),
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
