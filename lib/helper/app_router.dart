import '../view/auth/login_page.dart';
import '../view/auth/otp_page.dart';
import '../view/home_page_customer.dart';
import '../view/home_page_provider.dart';
import '../view/provider/selection_page.dart';
import '../view/provider/services/services_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const selectionRoute = '/';
  static const loginRoute = '/login';
  static const otpRoute = '/otp';
  static const homeCustomerRoute = '/homeCustomerRoute';
  static const homeProviderRoute = '/homeProviderRoute';
  static const servicesRoute = '/servicesRoute/:uid';

  static final GoRouter router = GoRouter(
    routes: [
      _buildRoute(
        path: selectionRoute,
        builderFn: (_) => const SelectionPage(),
      ),
      _buildRoute(path: loginRoute, builderFn: (_) => const LoginPage()),
      _buildRoute(path: otpRoute, builderFn: (_) => const OtpPage()),
      _buildRoute(
        path: homeCustomerRoute,
        builderFn: (state) {
          final user = state.extra as User;
          return HomePageCustomer(authUser: user);
        },
      ),
      _buildRoute(
        path: homeProviderRoute,
        builderFn: (state) {
          final user = state.extra as User;
          return HomePageProvider(authUser: user);
        },
      ),
      _buildRoute(
        path: servicesRoute,
        builderFn: (state) {
          String? id = state.extra as String;
          return ServicesPage(uid: id);
        },
      ),
    ],
  );

  static GoRoute _buildRoute({
    required String path,
    required Widget Function(GoRouterState state) builderFn,
  }) {
    return GoRoute(
      path: path,
      builder: (context, state) => builderFn(state),
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: builderFn(state),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    );
  }
}
