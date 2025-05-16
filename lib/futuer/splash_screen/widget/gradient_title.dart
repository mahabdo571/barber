import 'package:flutter/material.dart';

class GradientTitle extends StatelessWidget {
  const GradientTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 92,
      top: 68,
      child: Container(
        width: 392,
        height: 844,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
          ),
        ),
        child: const Center(
          child: Text(
            'دکترمن',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 24,
              fontFamily: 'Yekan Bakh',
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
