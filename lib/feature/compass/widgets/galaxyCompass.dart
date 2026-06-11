import 'package:flutter/material.dart';
import 'dart:math' as math;

class GalaxyCompass extends StatelessWidget {
  final double heading;
  final double qiblaAngle;

  const GalaxyCompass({
    super.key,
    required this.heading,
    required this.qiblaAngle,
  });

  @override
  Widget build(BuildContext context) {
    // The compass body rotates opposite to heading
    double rotationAngle = -heading * (math.pi / 180);
    // The pin rotates to always point to Qibla relative to heading
    double pinAngle = (qiblaAngle - heading) * (math.pi / 180);
    final double compassSize = 250;

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: compassSize,
        height: compassSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Compass body (rotates with device)
            Transform.rotate(
              angle: rotationAngle,
              child: Image.asset(
                'assets/image/galaxybody.png',
                width: compassSize,
                height: compassSize,
                fit: BoxFit.contain,
              ),
            ),
            // Pin (needle) - rotates to Qibla
            Transform.rotate(
              angle: pinAngle,
              child: Image.asset(
                'assets/image/galaxypin.png',
                width: compassSize / 3,
                height: compassSize / 3,
                fit: BoxFit.contain,
              ),
            ),
            // Kaaba icon at Qibla direction
            Builder(
              builder: (context) {
                final double radius = compassSize / 2;
                final double placeR = radius + 10;
                final double theta = pinAngle;
                final double dx = placeR * math.sin(theta);
                final double dy = -placeR * math.cos(theta);
                return Positioned.fill(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: SizedBox(
                        width: 30,
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
