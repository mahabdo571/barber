import 'package:barber/futuer/splash_screen/pres/splash_screen.dart';
import 'package:barber/futuer/splash_screen/widget/gradient_title.dart';
import 'package:barber/futuer/splash_screen/widget/image_rows.dart';
import 'package:flutter/material.dart';

class CenterContent extends StatelessWidget {
  const CenterContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 26,
      top: 22,
      child: Container(
        width: 390,
        height: 844,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(54),
          ),
        ),
        child: Stack(
          children: [
            // Placeholder rows/images
            const ImageRows(),
            // Gradient overlay and title
            const GradientTitle(),
          ],
        ),
      ),
    );
  }
}
