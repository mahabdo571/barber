import 'dart:async';
import 'dart:developer';

import 'package:barber/core/constants/app_path.dart';
import 'package:barber/feature/auth/screens/login_screen.dart';
import 'package:barber/feature/auth/screens/otp_screen.dart';
import 'package:barber/feature/auth/screens/selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A ChangeNotifier that listens to a Stream and notifies GoRouter to refresh
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

/// App-wide router configuration
final GoRouter router = GoRouter(
  // Listen to Firebase Auth state changes
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),

  // Initial route when app launches
  initialLocation: AppPath.login,

  // Define all routes here
  routes: <GoRoute>[
    GoRoute(
      path: AppPath.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppPath.otp,
      name: 'otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: AppPath.selection,
      name: 'selection',
      builder: (context, state) => const SelectionScreen(),
    ),
    // TODO: Add new routes below
    // GoRoute(path: '/home', name: 'home', builder: (_, __) => const HomeScreen()),
  ],

  // Redirect logic to guard protected routes
  redirect: (BuildContext context, GoRouterState state) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String location = state.uri.toString();

    // Pages that don't require authentication
    const publicPaths = <String>[
      AppPath.login, // login
      AppPath.otp, // otp verification
    ];

    // If user is not signed in, and tries to access protected route, send to login
    if (user == null && !publicPaths.contains(location)) {
      return AppPath.login;
    }

    // If user is signed in, prevent going back to login or otp
    if (user != null && publicPaths.contains(location)) {
      return AppPath.selection;
    }

    // no redirect
    return null;
  },

  // Debug logging
  debugLogDiagnostics: kDebugMode,
);
