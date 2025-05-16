import 'package:flutter/material.dart';

class DecorBar extends StatelessWidget {
  final double left;
  final double top;
  final double height;

  const DecorBar({
    required this.left,
    required this.top,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 4,
        height: height,
        decoration: ShapeDecoration(
          color: Color(0xFFA499AB),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 0.5, color: Color(0xFF4E4354)),
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}
