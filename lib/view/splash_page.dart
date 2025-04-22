import 'package:barber/helper/help_metod.dart';

import '../cubit/auth/auth_cubit.dart';
import '../cubit/auth/auth_state.dart';
import 'login_page.dart';
import 'selection_page.dart';
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
    Future.delayed(Duration.zero, () {
      context.read<AuthCubit>().checkAuthStatus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          gotoPage(context, SelectionPage());
        } else if (state is AuthInitial || state is AuthError) {
          gotoPage(context, LoginPage());
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
