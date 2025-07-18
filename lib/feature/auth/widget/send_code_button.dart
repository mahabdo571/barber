import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Primary action button to send code
class SendCodeButton extends StatelessWidget {
  const SendCodeButton({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
 

        context.read<AuthCubit>().sendOtp(controller.text.trim());
      },
      style: ElevatedButton.styleFrom(
        iconColor: Color(0xFF1C2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: const Text(
        'ارسل الرمز',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
