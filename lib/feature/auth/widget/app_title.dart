import 'package:barber/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Title section for the screen
class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'حجز - ',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 20),
          ),
          TextSpan(
            text: 'احجز لي',
            style: TextStyle(color: AppColors.primaryText, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
