import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DayProgressWidget extends StatelessWidget {
  final int currentDay;
  final int totalDays;
  final double? size;

  const DayProgressWidget({
    super.key,
    required this.currentDay,
    required this.totalDays,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final double effectiveSize = size ?? 120.h;
    return Container(
      width: effectiveSize,
      height: effectiveSize,

      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/image/bubble.png',
            width: effectiveSize,
            height: effectiveSize,
            fit: BoxFit.contain,
          ),
          SizedBox(
            width: effectiveSize * 0.75, // Scale the rings inside the container
            height: effectiveSize * 0.75,
            child: CustomPaint(
              painter: _SegmentedArcPainter(
                totalSegments: 3, // Visual segments (gaps)
                filledSegments: 1, // How many are green
                activeColor: const Color(0xFF2E7D32), // Dark Green
                inactiveColor: Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
          // The Text Center
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$currentDay',
                style: TextStyle(
                  fontSize: effectiveSize * 0.25, // Responsive font size
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF333333),
                  height: 1.0,
                ),
              ),
              Text(
                'Day',
                style: TextStyle(
                  fontSize: effectiveSize * 0.1,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentedArcPainter extends CustomPainter {
  final int totalSegments;
  final int filledSegments;
  final Color activeColor;
  final Color inactiveColor;

  _SegmentedArcPainter({
    required this.totalSegments,
    required this.filledSegments,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Config
    final double strokeWidth = min(size.width, size.height) * 0.1;
    const gapAngle = 0.25; // Size of the gap in radians

    // We rotate the canvas slightly so the green bar appears on the right
    // similar to the reference image (approx -30 degrees offset)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-pi / 6);
    canvas.translate(-center.dx, -center.dy);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Calculate the size of each arc segment
    final double segmentArcSize = (2 * pi) / totalSegments;

    for (int i = 0; i < totalSegments; i++) {
      // Determine color: The logic here assumes the "first" segment is the active one
      // You can adjust this logic if you want the progress to fill differently
      paint.color = (i < filledSegments) ? activeColor : inactiveColor;

      // Calculate start angle for this segment
      // We add half the gap to center the arc between gaps
      final startAngle = (i * segmentArcSize) + (gapAngle / 2);
      final sweepAngle = segmentArcSize - gapAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
