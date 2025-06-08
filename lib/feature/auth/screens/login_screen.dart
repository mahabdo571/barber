import 'package:barber/core/constants/app_colors.dart';
import 'package:barber/core/constants/app_path.dart';
import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/auth/widget/app_status_bar.dart';
import 'package:barber/feature/auth/widget/app_title.dart';
import 'package:barber/feature/auth/widget/phone_input_field.dart';
import 'package:barber/feature/auth/widget/send_code_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Main entry point for the Forget Password screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is OtpSent) {
          // انتقل لشاشة إدخال الكود
          context.go(AppPath.otp, extra: state.verificationId);
        }
        if (state is AuthCustomer) {
          // انتقل لشاشة إدخال الكود
          context.go(AppPath.customerHome);
        }
 
        if (state is AuthCompany) {
          // انتقل لشاشة إدخال الكود
          context.go(AppPath.companyHome);
        }
        if (state is AuthLoading) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('جاري ارسال الكود')));
       
        }
        if (state is AuthFailed) {
          // أعرض رسالة خطأ
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.model.errMessage)));
        }
      },
      builder: (ctx, sts) {
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
                  PhoneInputField(controller: _controller),
                  const SizedBox(height: 32),
                  SendCodeButton(controller: _controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
