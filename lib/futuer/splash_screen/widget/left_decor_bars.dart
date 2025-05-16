import 'package:barber/futuer/splash_screen/widget/decor_bar.dart';
import 'package:flutter/material.dart';

class LeftDecorBars extends StatelessWidget {
  const LeftDecorBars({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        DecorBar(left: 0, top: 171, height: 33),
        DecorBar(left: 0, top: 234, height: 65),
        DecorBar(left: 0, top: 319, height: 65),
      ],
    );
  }
}
