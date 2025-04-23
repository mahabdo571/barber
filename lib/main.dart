import 'Implementation/provider/firestore_service_repository.dart';
import 'cubit/service_provider_cubit/service_provider_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'view/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'cubit/auth/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ar', null);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(), // كيوبت الأوث
        ),
        BlocProvider<ServiceProviderCubit>(
          create:
              (_) =>
                  ServiceProviderCubit(repository: FirestoreServiceRepository())
                    ..loadServices(), // كيوبت الخدمات
        ),
      ],
      child: const MaterialApp(
        title: 'حجوزات',
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        debugShowCheckedModeBanner: false,
        home: SplashPage(),
      ),
    );
  }
}
