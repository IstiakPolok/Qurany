import 'package:flutter/material.dart';
import 'dart:math' as math;

class ModernCompass extends StatelessWidget {
  final double qiblaAngle;

  String _getDirectionAbbreviation(double heading) {
    // Normalize heading to 0-360
    heading = heading % 360;
    // Define boundaries for main and intercardinal directions
    if (heading >= 337.5 || heading < 22.5) return "N";
    if (heading >= 22.5 && heading < 67.5) return "NE";
    if (heading >= 67.5 && heading < 112.5) return "E";
    if (heading >= 112.5 && heading < 157.5) return "ES";
    if (heading >= 157.5 && heading < 202.5) return "S";
    if (heading >= 202.5 && heading < 247.5) return "SW";
    if (heading >= 247.5 && heading < 292.5) return "W";
    if (heading >= 292.5 && heading < 337.5) return "NW";
    return "";
  }

  final double heading;

  const ModernCompass({
    super.key,
    required this.heading,
    required this.qiblaAngle,
  });

  @override
  Widget build(BuildContext context) {
    // We rotate the dial in the opposite direction of the heading
    double rotationAngle = -heading * (math.pi / 180);

    // Reduced size constants
    final double compassSize = 220; // Reduced from 300
    final double innerSize = 130; // Reduced from 170

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),

        // const Icon(Icons.arrow_drop_up, color: Colors.red, size: 30),
        Stack(
          alignment: Alignment.center,
          children: [
            // Rotating Part
            Transform.rotate(
              angle: rotationAngle,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Background Circle
                  Container(
                    width: compassSize,
                    height: compassSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 20),
                      ],
                    ),
                  ),
                  // Degree Ticks and Cardinal Letters
                  CustomPaint(
                    size: Size(compassSize, compassSize),
                    painter: CompassPainter(),
                  ),
                  // The Green Dot Indicator (Positioned at 260 degrees on the dial)
                  Transform.rotate(
                    angle: 260 * (math.pi / 180),
                    child: Align(
                      alignment: const Alignment(0, -0.75),
                      child: Container(
                        width: 20, // Slightly smaller dot
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fixed Center Info (Doesn't rotate)
            Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0XFFDCE9DC),
                  width: 15,
                ), // Thinner border
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${heading.toInt()}°",
                    style: const TextStyle(
                      fontSize: 32, // Smaller font
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF455A64),
                    ),
                  ),
                  Text(
                    _getDirectionAbbreviation(heading),
                    style: const TextStyle(
                      fontSize: 16, // Smaller font
                      fontWeight: FontWeight.w500,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
            // Kaaba Icon (Fixed at the top)
            Builder(
              builder: (context) {
                final double size = compassSize;
                final double radius = size / 2;
                // place the icon slightly inside the outer edge
                final double placeR = radius + 35; // Adjusted offset
                final double theta = (qiblaAngle - heading) * (math.pi / 180);
                final double dx = placeR * math.sin(theta);
                final double dy = -placeR * math.cos(theta);

                return Positioned.fill(
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(dx, dy),
                      child: SizedBox(
                        width: 32, // Smaller icon container
                        height: 32,
                        child: Center(
                          child: Text(
                            '🕋',
                            style: TextStyle(fontSize: 20),
                          ), // Smaller emoji
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 10) {
      // Adjust angle so 0° is at -90° (top/North), and degrees increase clockwise
      double angle = (i - 90) * (math.pi / 180);

      // Draw ticks
      double tickLength = (i % 90 == 0) ? 15 : 8; // Shorter ticks
      Offset p1 = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      Offset p2 = Offset(
        center.dx + (radius - 5 - tickLength) * math.cos(angle),
        center.dy + (radius - 5 - tickLength) * math.sin(angle),
      );

      // Color coding for N, S, E, W
      if (i % 90 == 0) {
        paint.color = (i == 270) ? Colors.red : Colors.orange;
      } else {
        paint.color = Colors.grey.shade300;
      }
      canvas.drawLine(p1, p2, paint);

      // Draw Degree Numbers (e.g., 30, 60...)
      if (i % 30 == 0 && i % 90 != 0) {
        // Show 30, 60, ... after N (not 330, 300)
        int label = i;
        _drawText(
          canvas,
          center,
          radius - 35,
          label.toString(),
          angle,
          fontSize: 10,
        );
      }
    }

    // Draw N, S, E, W (adjusted angles)
    _drawText(
      canvas,
      center,
      radius + 15, // Closer labels
      "N",
      -math.pi / 2,
      color: Colors.red,
      fontSize: 18, // Smaller font
    );
    _drawText(
      canvas,
      center,
      radius + 15,
      "E",
      0,
      color: Colors.blueGrey,
      fontSize: 18,
    );
    _drawText(
      canvas,
      center,
      radius + 15,
      "S",
      math.pi / 2,
      color: Colors.blueGrey,
      fontSize: 18,
    );
    _drawText(
      canvas,
      center,
      radius + 15,
      "W",
      math.pi,
      color: Colors.blueGrey,
      fontSize: 18,
    );
  }

  void _drawText(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    double angle, {
    Color color = Colors.grey,
    double fontSize = 12,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final x = center.dx + radius * math.cos(angle) - textPainter.width / 2;
    final y = center.dy + radius * math.sin(angle) - textPainter.height / 2;
    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
