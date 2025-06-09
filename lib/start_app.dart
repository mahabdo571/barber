import 'package:barber/core/router/app_router.dart';
import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/auth/data/auth_repo.dart';
import 'package:barber/feature/auth/data/auth_repo_impl.dart';
import 'package:barber/feature/company_mode/cubit/appointment_cubit/appointment_cubit.dart';
import 'package:barber/feature/company_mode/cubit/service_section_cubit/service_section_cubit.dart';
import 'package:barber/feature/company_mode/data/appointment/appointment_repository.dart';
import 'package:barber/feature/company_mode/data/appointment/appointment_repository_impl.dart';
import 'package:barber/feature/company_mode/data/service_section/service_repository.dart';
import 'package:barber/feature/company_mode/data/service_section/service_repository_impl.dart';
import 'package:barber/feature/users/cubit/user_search_cubit.dart';
import 'package:barber/feature/users/data/user_repository.dart';
import 'package:barber/feature/users/data/user_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        RepositoryProvider<AppointmentRepository>(
          create: (_) => AppointmentRepositoryImpl(),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepositoryImpl(FirebaseFirestore.instance),
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
          BlocProvider<AppointmentCubit>(
            create: (context) {
              final cubit = AppointmentCubit(
                context.read<AppointmentRepository>(),
              );
              return cubit;
            },
          ),
          BlocProvider<ServiceSectionCubit>(
            create: (context) {
              final cubit = ServiceSectionCubit(
                context.read<ServiceRepository>(),
                context.read<AuthRepo>(),
              );
              return cubit;
            },
          ),
          BlocProvider<UserSearchCubit>(
            create: (context) {
              final cubit = UserSearchCubit(context.read<UserRepository>())
                ..loadFavorites();
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
