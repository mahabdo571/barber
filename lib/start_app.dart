import 'package:barber/core/router/app_router.dart';
import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/auth/data/auth_repo.dart';
import 'package:barber/feature/auth/data/auth_repo_impl.dart';
import 'package:barber/feature/company_mode/cubit/service_section_cubit/service_section_cubit.dart';
import 'package:barber/feature/company_mode/data/service_section/service_repository.dart';
import 'package:barber/feature/company_mode/data/service_section/service_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartApp extends StatelessWidget {
  const StartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepo>(create: (_) => AuthRepoImpl()),
        RepositoryProvider<ServiceRepository>(
          create: (_) => ServiceRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) {
              final cubit = AuthCubit(context.read<AuthRepo>());
              Future.microtask(() => cubit.checkAuthAndRole(null));
              return cubit;
            },
          ),
          BlocProvider<ServiceSectionCubit>(
            create: (context) {
              final cubit = ServiceSectionCubit(context.read<ServiceRepository>());
             // Future.microtask(() => cubit.checkAuthAndRole(null));
              return cubit;
            },
          ),
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      ),
    );
  }
}
