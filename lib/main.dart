import 'package:barber/Implementation/customers/fierstore_customers_repository.dart';
import 'package:barber/Implementation/customers/fierstore_favorit_repository.dart';
import 'package:barber/Implementation/provider/provider_firestore_repository.dart';
import 'package:barber/constants.dart';
import 'package:barber/cubit/auth/auth_state.dart';
import 'package:barber/cubit/customers_cubit/customers_cubit.dart';
import 'package:barber/cubit/favorit_cubit/favorit_cubit_cubit.dart';
import 'package:barber/cubit/provider_search_cubit/provider_search_cubit.dart';
import 'package:barber/helper/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'Implementation/provider/firestore_schedule_repository.dart';
import 'cubit/schedule_cubit/schedule_cubit.dart';

import 'Implementation/provider/firestore_service_repository.dart';
import 'cubit/service_provider_cubit/service_provider_cubit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'cubit/auth/auth_cubit.dart';

final getIt = GetIt.instance;

void main() async {
  await _initialApp();

  runApp(MyApp());
}

Future<void> _initialApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ar', null);
  getIt.registerSingleton<AuthCubit>(AuthCubit()..checkAuthStatus());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authCubit = GetIt.instance<AuthCubit>().state;
    final userId = authCubit is Authenticated ? authCubit.authUser?.uid : '';
    return _multiBlocProvider(userId);
  }

  MultiBlocProvider _multiBlocProvider(String? userId) {
    return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>(create: (_) => AuthCubit()..checkAuthStatus()),
      BlocProvider<ServiceProviderCubit>(
        create:
            (_) =>
                ServiceProviderCubit(repository: FirestoreServiceRepository())
                  ..loadServices(userId.toString()),
      ),
      BlocProvider<ScheduleCubit>(
        create:
            (_) =>
                ScheduleCubit(repository: FirestoreScheduleRepository())
                  ..loadSchedules(),
      ),
      _blocProvider_CustomersCubit(),
      BlocProvider<ProviderSearchCubit>(
        create:
            (_) => ProviderSearchCubit(
              repository: FirestoreProviderRepository(),
            ),
      ),
      BlocProvider<FavoritCubitCubit>(
        create:
            (_) =>
                FavoritCubitCubit(repository: FierstoreFavoritRepository())
                  ..loadFavoritByCoustomerId(),
      ),
    ],
    child: _materialApp_router(),
  );
  }

  BlocProvider<CustomersCubit> _blocProvider_CustomersCubit() {
    return BlocProvider<CustomersCubit>(
      create: (context) {
        final authState = context.read<AuthCubit>().state;
        User? user;
        if (authState is Authenticated) {
          user = authState.authUser;
        }
        final cubit = CustomersCubit(
          repository: FierstoreCustomersRepository(),
        );
        if (user != null) {
          cubit.getCustomerById(user.uid);
        }
        return cubit;
      },
    );
  }

  MaterialApp _materialApp_router() {
    return MaterialApp.router(
    routerConfig: AppRouter.router,
    title: kAppName,
    locale: Locale('ar'),
    supportedLocales: [Locale('ar')],
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],

    debugShowCheckedModeBanner: false,
  );
  }
}
