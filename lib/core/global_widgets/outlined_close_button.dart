import 'package:flutter/material.dart';

class OutlinedCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double radius;
  final double iconSize;
  final Color borderColor;
  final Color iconColor;
  final double borderWidth;

  const OutlinedCloseButton({
    super.key,
    this.onPressed,
    this.radius = 20,
    this.iconSize = 20,
    this.borderColor = const Color(0x80FFFFFF),
    this.iconColor = Colors.white,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: radius,
        child: IconButton(
          icon: Icon(Icons.close, color: iconColor, size: iconSize),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
