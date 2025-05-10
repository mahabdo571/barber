import 'Implementation/customers/fierstore_customers_repository.dart';
import 'Implementation/customers/fierstore_favorit_repository.dart';
import 'Implementation/provider/firestore_schedule_repository.dart';
import 'Implementation/provider/firestore_service_repository.dart';
import 'Implementation/provider/provider_firestore_repository.dart';
import 'constants.dart';
import 'cubit/auth/auth_cubit.dart';
import 'cubit/auth/auth_state.dart';
import 'cubit/customers_cubit/customers_cubit.dart';
import 'cubit/favorit_cubit/favorit_cubit_cubit.dart';
import 'cubit/provider_search_cubit/provider_search_cubit.dart';
import 'cubit/schedule_cubit/schedule_cubit.dart';
import 'cubit/service_provider_cubit/service_provider_cubit.dart';
import 'helper/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

class AppointmentApp extends StatelessWidget {
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
