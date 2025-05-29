import 'dart:async';
import 'dart:developer';

import 'package:barber/core/constants/app_path.dart';
import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/auth/screens/login_screen.dart';
import 'package:barber/feature/auth/screens/otp_screen.dart';
import 'package:barber/feature/auth/screens/selection_screen.dart';
import 'package:barber/feature/auth/screens/splash_screen.dart';
import 'package:barber/feature/auth/screens/store_owner_form.dart';
import 'package:barber/feature/company_mode/models/service_model.dart';
import 'package:barber/feature/company_mode/screens/appointments_page.dart';
import 'package:barber/feature/company_mode/screens/company_home.dart';
import 'package:barber/feature/company_mode/widget/appointment/add_appointments_page.dart';
import 'package:barber/feature/company_mode/widget/service_section/add_service_stepper_page.dart';
import 'package:barber/feature/customer_mode/screens/customer_home.dart';
import 'package:barber/feature/customer_mode/screens/info_data.dart';
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
  initialLocation: AppPath.initial,

  // Define all routes here
  routes: <GoRoute>[
    GoRoute(
      path: AppPath.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppPath.initial,
      name: 'initial',
      builder: (context, state) => SplashScreen(),
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
      builder: (context, state) => CustomerHome(),
    ),
    GoRoute(
      path: AppPath.companyHome,
      name: 'companyHome',
      builder: (context, state) => CompanyHome(),
    ),
    GoRoute(
      path: AppPath.storeOwnerForm,
      name: 'storeOwnerForm',
      builder: (context, state) => StoreOwnerForm(),
    ),
    GoRoute(
      path: AppPath.addService,
      name: AppPath.addService,
      builder: (context, state) {
        if (state.extra is ServiceModel) {
          final extraSM = state.extra as ServiceModel;

          return AddServiceStepperPage(userId: extraSM.userId, model: extraSM);
        } else {
          final extra = state.extra as Map<String, dynamic>;
          final userId = extra['userId'] as String;
          return AddServiceStepperPage(userId: userId);
        }
      },
    ),

    GoRoute(
      path: AppPath.appointmentsAdd,
      name: AppPath.appointmentsAdd,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;

        final userId = extra['userId'] as String;

        return AddAppointmentsPage(userId: userId);
      },
    ),
    GoRoute(
      path: AppPath.infoData,
      name: AppPath.infoData,
      builder: (context, state) {
        return InfoData();
      },
    ),
  ],

  // Redirect logic to guard protected routes
  redirect: (BuildContext context, GoRouterState state) {
    final String location = state.matchedLocation;
    final authState = context.read<AuthCubit>().state;

    // الصفحات التي لا تحتاج مصادقة
    const publicPaths = <String>[
      AppPath.login, // تسجيل الدخول
      AppPath.otp, // التحقق من الرمز
      // التحقق من الرمز
    ];

    // إذا لم يتم تسجيل الدخول ويحاول الوصول لصفحة محمية
    if (authState is AuthUnauthenticated && !publicPaths.contains(location)) {
      return AppPath.login;
    }

    // تم تسجيل الدخول لكن لم يتم تحديد الدور
    if (authState is AuthSuccess) {
      if (location != AppPath.selection) {
        return AppPath.selection;
      }
    }

    // المستخدم زبون - توجيه للصفحة الرئيسية للزبائن
    if (authState is AuthCustomer) {
      // السماح بالبقاء في الصفحة الرئيسية للزبائن
      if (location == AppPath.customerHome) {
        return null;
      }
      // توجيه أي مسار آخر إلى الصفحة الرئيسية للزبائن
      return AppPath.customerHome;
    }

    // المستخدم شركة
    if (authState is AuthCompany) {
      // المسارات المسموحة للشركات
      const companyAllowedPaths = <String>[
        AppPath.companyHome, // الصفحة الرئيسية للشركة
        AppPath.addService, // إضافة خدمة
        AppPath.appointmentsAdd,
        AppPath.infoData, // إضافة موعد
        // يمكنك إضافة مسارات أخرى هنا حسب الحاجة
      ];

      // إذا كان المسار الحالي من المسارات المسموحة للشركات
      if (companyAllowedPaths.contains(location)) {
        return null; // السماح بالبقاء في هذا المسار
      }

      // إذا لم يكن من المسارات المسموحة، توجيه للصفحة الرئيسية للشركة
      return AppPath.companyHome;
    }

    // لا يوجد توجيه مطلوب
    return null;
  },
  // Debug logging
  debugLogDiagnostics: kDebugMode,
);
