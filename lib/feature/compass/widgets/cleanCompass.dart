import 'package:flutter/material.dart';
import 'dart:math' as math;

class CleanCompass extends StatelessWidget {
  final double heading;
  final double qiblaAngle;

  const CleanCompass({
    super.key,
    required this.heading,
    required this.qiblaAngle,
  });

  @override
  Widget build(BuildContext context) {
    // Rotate dial opposite to heading so "North" points to Magnetic North
    double rotationAngle = -heading * (math.pi / 180);
    final double compassSize = 220;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            // 1. ROTATING DIAL
            Transform.rotate(
              angle: rotationAngle,
              child: Container(
                width: compassSize,
                height: compassSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CustomPaint(painter: _CleanCompassPainter()),
              ),
            ),

            // 2. QIBLA INDICATOR (Kaaba Icon on the dial)
            // We want the icon to stay at the Qibla angle relative to North.
            // Since the dial rotates by -heading, a child of the rotation transform
            // would be fixed to the dial.
            // But here we are outside the rotation transform for the dial.
            // Let's position it relative to the screen, calculating the angle:
            // Angle on screen = (Qibla Angle - Heading)
            Builder(
              builder: (context) {
                final double radius = compassSize / 2;
                final double placeR = radius + 15; // Slightly inside
                final double theta = (qiblaAngle - heading) * (math.pi / 180);
                final double dx = placeR * math.sin(theta);
                final double dy = -placeR * math.cos(theta);

                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(
                      child: Text('🕋', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              },
            ),

            // 3. CENTER NEEDLE (User Heading)
            // In a "North Up" dial (dial rotates), the top of the phone is the heading.
            // Usually there's a fixed needle pointing UP.
            // Or, if we want a needle that acts like a magnetic needle,
            // the needle should point North (which is rotation 0 relative to dial).
            // But the dial is already rotating.
            // Let's look at the image: The needle is in the center.
            // Standard behavior: Dial rotates. Fixed "Lubber Line" at top.
            // OR Needle rotates.
            // The user's image has "N" at the top 0 position.
            // I will add a central needle that points North (so it rotates with the dial).
            // Wait, if the dial rotates, and the needle points to N on the dial,
            // the needle basically rotates with the dial.
            // Let's just draw the needle pointing UP relative to the DIAL (fixed to dial),
            // and the whole thing rotates.
            // This emulates a physical compass where the needle and card might move together
            // or the needle moves over a fixed card.
            // If the card is moving (digital compass), the needle is usually fixed to the card?
            // No, magnetic needle stays North. Card stays North. They move together.
            // The PHONE rotates.
            // So on screen, they both rotate opposite to heading.
            Transform.rotate(
              angle: rotationAngle,
              child: CustomPaint(
                size: Size(compassSize, compassSize),
                painter: _CleanNeedlePainter(),
              ),
            ),

            // Fixed Marker at Top (Lubber Line) to read heading?
            // The image doesn't clearly show a top red line.
            // But usually you read the heading at the top.
            // I'll add a small fixed pointer at the top just in case,
            // or rely on the "UP" orientation.
            Positioned(
              top: 0,
              child: Container(
                width: 4,
                height: 15,
                decoration: BoxDecoration(
                  color: Color(0xFFFF5722), // Deep Orange/Red
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CleanCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()..style = PaintingStyle.stroke;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // 1. Ticks and Numbers
    for (int i = 0; i < 360; i += 2) {
      double angle = (i - 90) * (math.pi / 180);
      bool isMajor = i % 30 == 0;
      bool isMinor = i % 10 == 0;

      double tickLen = isMajor ? 12 : (isMinor ? 8 : 4);
      paint.color = isMajor
          ? Colors.black54
          : (isMinor ? Colors.black26 : Colors.black12);
      paint.strokeWidth = isMajor ? 2 : 1;

      double r1 = radius - 15;
      double r2 = r1 - tickLen;

      Offset p1 = Offset(
        center.dx + r1 * math.cos(angle),
        center.dy + r1 * math.sin(angle),
      );
      Offset p2 = Offset(
        center.dx + r2 * math.cos(angle),
        center.dy + r2 * math.sin(angle),
      );

      // Don't draw ticks over the letters N, E, S, W
      if (i % 90 != 0) {
        canvas.drawLine(p1, p2, paint);
      }

      // Draw Numbers
      if (isMajor && i % 90 != 0) {
        textPainter.text = TextSpan(
          text: i.toString(),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.normal,
          ),
        );
        textPainter.layout();
        double rText = r2 - 10;
        Offset textOffset = Offset(
          center.dx + rText * math.cos(angle) - textPainter.width / 2,
          center.dy + rText * math.sin(angle) - textPainter.height / 2,
        );
        // Transform canvas to rotate text upright?
        // For now, just draw it.
        textPainter.paint(canvas, textOffset);
      }
    }

    // 2. Cardinals (N, E, S, W)
    final cardinals = {0: 'N', 90: 'E', 180: 'S', 270: 'W'};
    cardinals.forEach((angleDeg, label) {
      double angle = (angleDeg - 90) * (math.pi / 180);
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: Color(0xFF2E7D32), // Green color from image
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      double rText = radius - 35; // Position inside the ticks
      Offset textOffset = Offset(
        center.dx + rText * math.cos(angle) - textPainter.width / 2,
        center.dy + rText * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CleanNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    final needleLen = size.width / 2 - 50;
    final needleWidth = 6.0;

    // Draw simple compass needle pointing North (Up)
    // North Half (Green)
    Path northPath = Path();
    northPath.moveTo(center.dx, center.dy - needleLen);
    northPath.lineTo(center.dx + needleWidth, center.dy);
    northPath.lineTo(center.dx - needleWidth, center.dy);
    northPath.close();

    // South Half (Silver/Grey)
    Path southPath = Path();
    southPath.moveTo(center.dx, center.dy + needleLen);
    southPath.lineTo(center.dx + needleWidth, center.dy);
    southPath.lineTo(center.dx - needleWidth, center.dy);
    southPath.close();

    // Shadow
    canvas.drawPath(northPath.shift(Offset(1, 1)), shadowPaint);
    canvas.drawPath(southPath.shift(Offset(1, 1)), shadowPaint);

    Paint nPaint = Paint()
      ..color = Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;
    Paint sPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    canvas.drawPath(northPath, nPaint);
    canvas.drawPath(southPath, sPaint);

    // Center Pin
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
