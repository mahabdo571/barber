import 'package:barber/constants.dart';
import 'package:barber/cubit/auth/auth_cubit.dart';
import 'package:barber/cubit/auth/auth_state.dart';
import 'package:barber/helper/help_metod.dart';
import 'package:barber/view/auth/login_page.dart';
import 'package:barber/view/auth/otp_page.dart';
import 'package:barber/view/customers/customer_data_form.dart';
import 'package:barber/view/home_page_customer.dart';
import 'package:barber/view/home_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    // عند فتح الصفحة نتأكد من حالة المصادقة
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        // المستخدم غير موثق بعد → اذهب لصفحة تسجيل الدخول
        if (state is Unauthenticated || state is AuthInitial) {
          gotoPage(context, const LoginPage());
        }
        // تم إرسال OTP → اذهب لصفحة إدخال الكود
        else if (state is OtpSent) {
          gotoPage(context, const OtpPage());
        }
  
        // مصادق عليه وملفه مكتمل → توجه للرئيسية حسب الدور
        else if (state is Authenticated) {
          final role = state.role;
          if (role == 'customer') {
            gotoPage(context, HomePageCustomer(authUser: state.authUser));
          } else if (role == 'provider') {
            gotoPage(context, HomePageProvider(authUser: state.authUser));
          }
        }
        // أخطاء أو حالات أخرى يمكن معالجتها هنا...
      },
      builder: (ctx, status) {
        if (status is AuthIncompleteProfile) {
          return _scaffold(theme, context);
        }else{
        return Center(child: CircularProgressIndicator());

        }
      },
    );
  }

  Scaffold _scaffold(ThemeData theme, BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppName), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        child: Column(
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
                          builder: (_) => BarberDataForm(role: 'provider'),
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
                        MaterialPageRoute(builder: (_) => CustomerDataForm()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
