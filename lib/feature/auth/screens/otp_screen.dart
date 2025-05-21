import 'dart:developer';

import 'package:barber/core/constants/app_colors.dart';
import 'package:barber/core/constants/app_path.dart';
import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/auth/widget/app_status_bar.dart';
import 'package:barber/feature/auth/widget/app_title.dart';
import 'package:barber/feature/auth/widget/otp_input_field.dart';
import 'package:barber/feature/auth/widget/verify_code_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go(AppPath.selection);
        }

        if (state is AuthFailed) {
          log(state.model.errMessage);
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
