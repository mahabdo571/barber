import 'package:flutter/material.dart';

class TopIndicator extends StatelessWidget {
  const TopIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 179,
      top: 7,
      child: Container(
        width: 84,
        height: 4,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0806), Color(0xFF2D2D2D)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
