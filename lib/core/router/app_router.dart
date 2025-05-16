import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/business/presentation/pages/business_home_page.dart';
import '../../features/business/presentation/pages/business_profile_page.dart';
import '../../features/customer/presentation/pages/customer_home_page.dart';
import '../../features/customer/presentation/pages/customer_profile_page.dart';
import '../../features/customer/presentation/pages/business_details_page.dart';
import '../constants/app_constants.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.routeInitial,
  routes: [
    GoRoute(
      path: AppConstants.routeInitial,
      redirect: (context, state) {
        final authState = context.read<AuthCubit>().state;

        if (authState is AuthAuthenticated) {
          if (authState.role == AppConstants.roleBusiness) {
            return AppConstants.routeBusinessHome;
          } else {
            return AppConstants.routeCustomerHome;
          }
        } else if (authState is AuthNeedsRole) {
          return AppConstants.routeRoleSelection;
        }

        return AppConstants.routeLogin;
      },
    ),
    GoRoute(
      path: AppConstants.routeLogin,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppConstants.routeRoleSelection,
      builder: (context, state) => const RoleSelectionPage(),
    ),
    GoRoute(
      path: AppConstants.routeBusinessProfile,
      builder: (context, state) => const BusinessProfilePage(),
    ),
    GoRoute(
      path: AppConstants.routeCustomerProfile,
      builder: (context, state) => const CustomerProfilePage(),
    ),
    GoRoute(
      path: AppConstants.routeBusinessHome,
      builder: (context, state) => const BusinessHomePage(),
    ),
    GoRoute(
      path: AppConstants.routeCustomerHome,
      builder: (context, state) => const CustomerHomePage(),
    ),
    GoRoute(
      path: '${AppConstants.routeBusinessDetails}/:id',
      builder:
          (context, state) =>
              BusinessDetailsPage(businessId: state.pathParameters['id']!),
    ),
  ],
  redirect: (context, state) {
    final authState = context.read<AuthCubit>().state;
    final isLoginRoute = state.matchedLocation == AppConstants.routeLogin;
    final isInitialRoute = state.matchedLocation == AppConstants.routeInitial;
    final isRoleSelectionRoute =
        state.matchedLocation == AppConstants.routeRoleSelection;
    final isCustomerProfileRoute =
        state.matchedLocation == AppConstants.routeCustomerProfile;
    final isBusinessProfileRoute =
        state.matchedLocation == AppConstants.routeBusinessProfile;

    // If not authenticated, redirect to login
    if (authState is AuthUnauthenticated && !isLoginRoute && !isInitialRoute) {
      return AppConstants.routeLogin;
    }

    // If authenticated but no role, redirect to role selection
    if (authState is AuthNeedsRole && !isRoleSelectionRoute) {
      return AppConstants.routeRoleSelection;
    }

    // If authenticated with role, ensure they're in the correct section
    if (authState is AuthAuthenticated) {
      final isBusiness = authState.role == AppConstants.roleBusiness;
      final isInBusinessSection = state.matchedLocation.startsWith('/business');
      final isInCustomerSection = state.matchedLocation.startsWith('/customer');

      if (isBusiness) {
        if (isInCustomerSection) {
          return AppConstants.routeBusinessHome;
        }
      } else {
        if (isInBusinessSection) {
          return AppConstants.routeCustomerHome;
        }
      }
    }

    return null;
  },
);
