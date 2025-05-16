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
  String? _errorMessage;

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
          if (state is AuthLoading) {
            // Hide any previous error when loading starts
            setState(() {
              _errorMessage = null;
            });
          } else if (state is AuthCodeSent) {
            setState(() {
              _codeSent = true;
              _verificationId = state.verificationId;
              _errorMessage = null;
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
            setState(() {
              _errorMessage = state.message;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (!_codeSent) ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '+966XXXXXXXXX',
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تأكد من إدخال رقم الهاتف بالصيغة الصحيحة مع رمز البلد مثل: +966XXXXXXXXX',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                final phone = _phoneController.text.trim();
                                if (phone.isEmpty) {
                                  setState(() {
                                    _errorMessage = 'يرجى إدخال رقم الهاتف';
                                  });
                                  return;
                                }
                                context.read<AuthCubit>().signInWithPhone(
                                  phone,
                                );
                              },
                      child:
                          isLoading
                              ? const CircularProgressIndicator()
                              : const Text('إرسال رمز التحقق'),
                    ),
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
                    enabled: !isLoading,
                    onCompleted: (otp) {
                      if (_verificationId != null) {
                        context.read<AuthCubit>().verifyOTP(
                          _verificationId!,
                          otp,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _codeSent = false;
                              _verificationId = null;
                              _otpController.clear();
                              _errorMessage = null;
                            });
                          },
                          child: const Text('تغيير رقم الهاتف'),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          onPressed: () {
                            if (_verificationId != null &&
                                _otpController.text.length == 6) {
                              context.read<AuthCubit>().verifyOTP(
                                _verificationId!,
                                _otpController.text,
                              );
                            }
                          },
                          child: const Text('التحقق'),
                        ),
                      ],
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
