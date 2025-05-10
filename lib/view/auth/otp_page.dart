import 'package:barber/helper/app_router.dart';
import 'package:barber/view/home_page_customer.dart';
import 'package:barber/view/home_page_provider.dart';
import 'package:barber/view/provider/selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../helper/help_metod.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String otpCode = "";

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final role = state.role;
          if (role == 'customer') {
            context.go(AppRouter.homeCustomerRoute, extra: state.authUser);
            // gotoPage_pushReplacement(
            //   context,
            //   HomePageCustomer(authUser: state.authUser),
            // );
          } else if (role == 'provider') {
            context.go(AppRouter.homeProviderRoute, extra: state.authUser);
            // gotoPage_pushReplacement(
            //   context,
            //   HomePageProvider(authUser: state.authUser),
            // );
          } else {
            context.go(AppRouter.selectionRoute);
            //gotoPage_pushReplacement(context, SelectionPage());
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AuthIncompleteProfile) {
          context.go(AppRouter.selectionRoute);

          //gotoPage_pushReplacement(context, const SelectionPage());
        }
      },
      child: _scaffoldOtp(context),
    );
  }

  Scaffold _scaffoldOtp(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                'أدخل رمز التحقق',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'تم إرسال رمز إلى رقمك +970********',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              PinCodeTextField(
                appContext: context,
                length: 6,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                textStyle: const TextStyle(color: Colors.white, fontSize: 20),
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 55,
                  fieldWidth: 45,
                  activeColor: const Color(0xFFDAA520),
                  selectedColor: const Color(0xFFDAA520),
                  inactiveColor: Colors.grey[700]!,
                  activeFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  inactiveFillColor: Colors.transparent,
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: false,
                onChanged: (value) {
                  setState(() {
                    otpCode = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // هنا تتحقق من صحة الكود أو ترسله للسيرفر
                    if (otpCode.length == 6) {
                      setState(() {
                        context.read<AuthCubit>().verifyOtp(otpCode);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDAA520),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تأكيد',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  // هنا تضيف منطق إعادة الإرسال
                  print("إعادة إرسال الرمز");
                },
                child: const Text(
                  'لم يصلك الرمز؟ أعد الإرسال',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
