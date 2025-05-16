import 'package:barber/futuer/splash_screen/pres/splash_screen.dart';
import 'package:barber/futuer/splash_screen/widget/background_layers.dart';
import 'package:barber/futuer/splash_screen/widget/center_content.dart';
import 'package:barber/futuer/splash_screen/widget/left_decor_bars.dart';
import 'package:barber/futuer/splash_screen/widget/right_decor_bars.dart';
import 'package:barber/futuer/splash_screen/widget/top_indicator.dart';
import 'package:flutter/material.dart';

class SplashFrame extends StatelessWidget {
  const SplashFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 442,
      height: 888,
      child: Stack(
        children: const [
          // Background layers
          BackgroundLayers(),
          // Decorative side bars
          LeftDecorBars(),
          RightDecorBars(),
          // Top bar indicator
          TopIndicator(),
          // Center content
          CenterContent(),
        ],
      ),
    );
  }
}
