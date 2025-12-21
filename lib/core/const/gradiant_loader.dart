import 'package:flutter/material.dart';
import 'dart:math' as math;

class GradientLoader extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final List<Color> colors;

  const GradientLoader({
    super.key,
    this.size = 100.0,
    this.strokeWidth = 12.0,
    this.colors = const [
      Colors.transparent,
      Color(0xFF4CAF50),
    ], // Emerald green
  });

  @override
  State<GradientLoader> createState() => _GradientLoaderState();
}

class _GradientLoaderState extends State<GradientLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _GradientPainter(
          strokeWidth: widget.strokeWidth,
          colors: widget.colors,
        ),
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  final double strokeWidth;
  final List<Color> colors;

  _GradientPainter({required this.strokeWidth, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap
          .round // Makes the ends look soft
      ..shader = SweepGradient(
        colors: colors,
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
