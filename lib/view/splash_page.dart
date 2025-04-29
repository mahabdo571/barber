import 'package:barber/view/auth/otp_page.dart';
import 'package:barber/view/home_page_customer.dart';

import '../constants.dart';
import '../helper/help_metod.dart';
import 'home_page_provider.dart';

import '../cubit/auth/auth_cubit.dart';
import '../cubit/auth/auth_state.dart';
import 'auth/login_page.dart';
import 'provider/selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    loadData();
    Future.delayed(Duration.zero, () {
      context.read<AuthCubit>().checkAuthStatus();
    });

    super.initState();
  }

  Future<void> loadData() async {
    setState(() async {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading ||
            state is AuthChecking ||
            state is AuthSlowConnection) {
          return Scaffold(
            backgroundColor: Color(0xFF1C1C1E),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is Authenticated) {
          final checkRole = state.role;

          if (checkRole == 'customer') {
            gotoPage(context, HomePageCustomer(authUser: state.authUser));
          } else if (checkRole == 'provider') {
            gotoPage(context, HomePageProvider(authUser: state.authUser));
          }
        }
        if (state is AuthIncompleteProfile) {
          gotoPage(context, SelectionPage());
        }
        if (state is OtpSent) {
          gotoPage(context, OtpPage());
        }
        return LoginPage();
      },
    );

    // return BlocBuilder<AuthCubit, AuthState>(

    //   builder: (context, state) {
    //     if (state is Authenticated) {
    //       final checkRole = state.role;

    //       if (checkRole == 'customer') {
    //         gotoPage(context, HomePageCustomer(authUser: state.authUser));
    //       } else if (checkRole == 'provider') {
    //         gotoPage(context, HomePageProvider(authUser: state.authUser));
    //       }
    //     } else if (state is AuthInitial || state is AuthError) {
    //       gotoPage(context, LoginPage());
    //     } else if (state is AuthSlowConnection) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('الاتصال بالانترنت غير مستقر')),
    //       );
    //     } else if (state is AuthNoInternet) {
    //       ScaffoldMessenger.of(
    //         context,
    //       ).showSnackBar(SnackBar(content: Text('لا يوجد اتصال بالانترنت')));
    //     } else if (state is AuthIncompleteProfile) {
    //       gotoPage(context, SelectionPage());
    //     }
    //     return const Scaffold(
    //       backgroundColor: Color(0xFF1C1C1E),
    //       body: Center(
    //         child: CircularProgressIndicator(color: Color(0xFFDAA520)),
    //       ),
    //     );
    //   },
    // );
  }
}
