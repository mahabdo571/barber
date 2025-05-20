import 'package:barber/core/constants/app_colors.dart';
import 'package:barber/feature/auth/widget/app_status_bar.dart';
import 'package:barber/feature/auth/widget/app_title.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [AppStatusBar(), AppTitle(), const SizedBox(height: 140)],
          ),
        ),
      ),
    );
  }
}
