import 'dart:async';
import 'dart:developer';

import 'package:barber/feature/auth/screens/otp_screen.dart';
import 'package:barber/feature/auth/screens/selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../feature/auth/screens/login_screen.dart';

final GoRouter router = GoRouter(
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  routes: [
    GoRoute(path: '/', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/SelectionScreen',
      builder: (_, __) => const SelectionScreen(),
    ),
    GoRoute(path: '/otp', builder: (_, __) => const OtpScreen()),
  ],
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isGoingToOtp = state.uri.toString() == '/otp';
    log(state.uri.toString());
    final loggingIn = state.uri.toString() == '/';
    if (user == null && !loggingIn && isGoingToOtp) return '/otp';
    if (user != null && loggingIn) return '/SelectionScreen';
    return null;
  },
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
