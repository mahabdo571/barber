import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../helper/help_metod.dart';
import 'otp_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final phoneController = TextEditingController();

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          gotoPage(context, OtpPage());
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (BuildContext context, AuthState state) {
        return ScaffoldLogin(phoneController: phoneController);
      },
    );
  }
}

class ScaffoldLogin extends StatelessWidget {
  const ScaffoldLogin({super.key, required this.phoneController});

  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                'مرحبا بك 👋',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سجّل دخولك باستخدام رقم جوالك',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Text(
                      '+970',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,

                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '5XXXXXXXX',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFDAA520), // ذهبي أنيق
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // هنا تضيف منطق التحقق أو الانتقال
                    final phone = phoneController.text.trim();
                    if (phone.length == 9) {
                      context.read<AuthCubit>().sendOtp(phone);
                    }
                    print('+970${phoneController.text}');
                  },
                  child: const Text(
                    'إرسال رمز التحقق',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
