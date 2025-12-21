import 'dart:math' as math;
import 'package:flutter/material.dart';

class ClassicCompass extends StatelessWidget {
  final double heading; // device heading in degrees
  final double qiblaAngle; // qibla direction in degrees

  const ClassicCompass({super.key, this.heading = 0.0, this.qiblaAngle = 0.0});

  @override
  Widget build(BuildContext context) {
    // Return the compass container so this widget can be embedded in other screens
    return Center(
      child: Container(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. ROTATING BACKGROUND
            // This rotates in the opposite direction of the phone's heading
            Transform.rotate(
              angle: -(heading * (math.pi / 180)),
              child: Image.asset(
                'assets/image/compass_bg.png', // Your ornamental background image
                fit: BoxFit.contain,
              ),
            ),

            // 2. QIBLA NEEDLE
            // This stays pointing toward the Qibla regardless of phone rotation
            Transform.rotate(
              angle: (qiblaAngle - heading) * (math.pi / 180),
              child: Image.asset(
                'assets/image/qibla_needle.png', // Your gold needle image
                fit: BoxFit.contain,
              ),
            ),

            // 3. STATIC OVERLAY (Optional)
            // 3. Kaaba icon placed on the circumference at the Qibla bearing
            // Calculate position using polar coordinates (0° = North/top)
            Builder(
              builder: (context) {
                final double size = 250;
                final double radius = size / 2;
                // place the icon slightly inside the outer edge
                final double placeR = radius + 10;
                final double theta = (qiblaAngle - heading) * (math.pi / 180);
                final double dx = placeR * math.sin(theta);
                final double dy = -placeR * math.cos(theta);

                return Positioned.fill(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: SizedBox(
                        width: 30, // Slightly smaller icon
                        height: 30,
                        child: Center(
                          child: Text('🕋', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
