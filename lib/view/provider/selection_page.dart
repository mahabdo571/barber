import '../../constants.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../helper/app_router.dart';
import '../../helper/help_metod.dart';
import '../auth/login_page.dart';
import '../auth/otp_page.dart';
import '../customers/customer_data_form.dart';
import '../home_page_customer.dart';
import '../home_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'profile/provider_data_form.dart';

/// الصفحة الرئيسية الاختيارية.
/// تتولى التحقق من الحالة وعرض واجهة اختيار الحساب للمستخدمين الذين لم يكملوا بياناتهم.
/// توجه المستخدم إلى صفحة تسجيل الدخول أو الـ OTP أو الصفحة المناسبة بناءً على الحالة.
class SelectionPage extends StatefulWidget {
  const SelectionPage({Key? key}) : super(key: key);

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  @override
  void initState() {
    super.initState();

    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated || state is AuthInitial) {
          context.go(AppRouter.loginRoute);
          // gotoPage_pushReplacement(context, const LoginPage());
        }
        // تم إرسال OTP → اذهب لصفحة إدخال الكود
        else if (state is OtpSent) {
          context.go(AppRouter.otpRoute);

          // gotoPage_pushReplacement(context, const OtpPage());
        }
        // مصادق عليه وملفه مكتمل → توجه للرئيسية حسب الدور
        else if (state is Authenticated) {
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
          }
        } else if (state is AuthError) {
          print('Error in Auth ${state.message}');
        }
        // أخطاء أو حالات أخرى يمكن معالجتها هنا...
      },
      builder: (ctx, status) {
        return _scaffold(theme, context, status);
      },
    );
  }

  Scaffold _scaffold(ThemeData theme, BuildContext context, AuthState status) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppName), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        child:
            (status is AuthIncompleteProfile)
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'اختر نوع الحساب',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: Column(
                        children: [
                          _buildOptionCard(
                            context,
                            icon: Icons.storefront_rounded,
                            label: 'صاحب عمل',
                            color: Colors.indigo,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => BarberDataForm(role: 'provider'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildOptionCard(
                            context,
                            icon: Icons.person_rounded,
                            label: 'زبون',
                            color: Colors.teal,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CustomerDataForm(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: color.withAlpha(1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(1)),
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
