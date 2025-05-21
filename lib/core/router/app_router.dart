import 'dart:async';
import 'dart:developer';

import 'package:barber/core/constants/app_path.dart';
import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/auth/models/user_model.dart';
import 'package:barber/feature/auth/screens/login_screen.dart';
import 'package:barber/feature/auth/screens/otp_screen.dart';
import 'package:barber/feature/auth/screens/selection_screen.dart';
import 'package:barber/feature/home/screens/company_home.dart';
import 'package:barber/feature/home/screens/customer_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    GoRoute(
      path: AppPath.customerHome,
      name: 'customerHome',
      builder: (context, state) => const CustomerHome(),
    ),
    GoRoute(
      path: AppPath.companyHome,
      name: 'companyHome',
      builder: (context, state) => const CompanyHome(),
    ),
  ],

  // Redirect logic to guard protected routes
  redirect: (BuildContext context, GoRouterState state) {
    //  final User user = FirebaseAuth.instance.currentUser!;
    final String location = state.matchedLocation;
    final authState = context.read<AuthCubit>().state;

    // Pages that don't require authentication
    const publicPaths = <String>[
      AppPath.login, // login
      AppPath.otp, // otp verification
    ];

    // If user is not signed in, and tries to access protected route, send to login
    if (authState is AuthUnauthenticated && !publicPaths.contains(location)) {
        return AppPath.login;
    }

    // تم تسجيل الدخول لكن لم يتم تحديد الدور
    if (authState is AuthSuccess) {
      if (location != AppPath.selection) {
        return AppPath.selection;
      }
    }

    // المستخدم زبون
    if (authState is AuthCustomer) {
      if (location != AppPath.customerHome) {
        return AppPath.customerHome;
      }
    }

    // المستخدم شركة
    if (authState is AuthCompany) {
      if (location != AppPath.companyHome) {
        return AppPath.companyHome;
      }
    }

    // لا يوجد توجيه
    return null;
  },

  // Debug logging
  debugLogDiagnostics: kDebugMode,
);
