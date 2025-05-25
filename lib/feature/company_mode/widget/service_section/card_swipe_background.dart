import 'package:flutter/material.dart';

class CardSwipeBackground extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Alignment alignment;

  const CardSwipeBackground({super.key, required this.icon, required this.color, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color,
      child: Icon(icon, color: Colors.white),
    );
  }
}
