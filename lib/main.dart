import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/business/presentation/cubit/business_cubit.dart';
import 'features/customer/presentation/cubit/customer_cubit.dart';
import 'firebase_options.dart';

void main() async {
  await _initializeApp();
  runApp(const BarberApp());
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Setup dependency injection
  await setupServiceLocator(prefs);
}

class BarberApp extends StatelessWidget {
  const BarberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => GetIt.I<AuthCubit>()),
        BlocProvider<BusinessCubit>(
          create: (context) => GetIt.I<BusinessCubit>(),
        ),
        BlocProvider<CustomerCubit>(
          create: (context) => GetIt.I<CustomerCubit>(),
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', ''), // Arabic
          Locale('en', ''), // English
        ],
        locale: const Locale('ar', ''), // Default to Arabic
      ),
    );
  }
}
