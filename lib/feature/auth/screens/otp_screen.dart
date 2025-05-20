import 'package:barber/core/constants/app_colors.dart';
import 'package:barber/feature/auth/widget/app_status_bar.dart';
import 'package:barber/feature/auth/widget/app_title.dart';
import 'package:barber/feature/auth/widget/otp_input_field.dart';
import 'package:barber/feature/auth/widget/verify_code_button.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AppStatusBar(),
              AppTitle(),
              const SizedBox(height: 140),
              OtpInputField(controller: _controller),
              SizedBox(height: 16),
              VerifyCodeButton(controller: _controller),
            ],
          ),
        ),
      ),
    );
  }
}
