import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/constants/app_constants.dart';
import '../cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _codeSent = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول'), centerTitle: true),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthCodeSent) {
            setState(() {
              _codeSent = true;
              _verificationId = state.verificationId;
            });
          } else if (state is AuthNeedsRole) {
            context.go(AppConstants.routeRoleSelection);
          } else if (state is AuthAuthenticated) {
            if (state.role == AppConstants.roleBusiness) {
              context.go(AppConstants.routeBusinessHome);
            } else {
              context.go(AppConstants.routeCustomerHome);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_codeSent) ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '+966XXXXXXXXX',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        state is AuthLoading
                            ? null
                            : () {
                              context.read<AuthCubit>().signInWithPhone(
                                _phoneController.text,
                              );
                            },
                    child:
                        state is AuthLoading
                            ? const CircularProgressIndicator()
                            : const Text('إرسال رمز التحقق'),
                  ),
                ] else ...[
                  const Text(
                    'أدخل رمز التحقق المرسل إلى هاتفك',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: _otpController,
                    onChanged: (value) {},
                    onCompleted: (otp) {
                      if (_verificationId != null) {
                        context.read<AuthCubit>().verifyOTP(
                          _verificationId!,
                          otp,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _codeSent = false;
                        _verificationId = null;
                        _otpController.clear();
                      });
                    },
                    child: const Text('تغيير رقم الهاتف'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
