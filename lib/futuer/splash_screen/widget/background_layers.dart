import 'package:flutter/material.dart';

class BackgroundLayers extends StatelessWidget {
  const BackgroundLayers({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 5,
          top: 1,
          child: _buildLayer(432, 886, Color(0xFFDCD7D8), 70),
        ),
        Positioned(
          left: 7,
          top: 3,
          child: _buildLayer(428, 882, Color(0xFF4A4355), 69),
        ),
        Positioned(
          left: 11,
          top: 7,
          child: _buildLayer(420, 874, Colors.black, 65),
        ),
      ],
    );
  }

  Widget _buildLayer(double w, double h, Color color, double radius) {
    return Container(
      width: w,
      height: h,
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
