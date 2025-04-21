import 'package:barber/cubit/auth/auth_cubit.dart';
import 'package:barber/cubit/auth/auth_state.dart';
import 'package:barber/view/login_page.dart';
import 'package:barber/view/selection_page.dart';
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
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<AuthCubit>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => const SelectionPage(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else if (state is AuthInitial || state is AuthError) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (_, __, ___) => const LoginPage(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
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
