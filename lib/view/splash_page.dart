import '../constants.dart';
import '../helper/help_metod.dart';
import 'home_page.dart';

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
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          gotoPage(context, HomePage());
        } else if (state is AuthInitial || state is AuthError) {
          gotoPage(context, LoginPage());
        } else if (state is AuthSlowConnection) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('الاتصال بالانترنت غير مستقر')),
          );
        } else if (state is AuthNoInternet) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('لا يوجد اتصال بالانترنت')));
        } else if (state is AuthIncompleteProfile) {
          gotoPage(context, SelectionPage());
        }
      },
      builder: (context, state) {
        return const Scaffold(
          backgroundColor: Color(0xFF1C1C1E),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFDAA520)),
          ),
        );
      },
    );
  }
}
