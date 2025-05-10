import 'Implementation/customers/fierstore_customers_repository.dart';
import 'Implementation/customers/fierstore_favorit_repository.dart';
import 'Implementation/provider/provider_firestore_repository.dart';
import 'appointment_app.dart';
import 'constants.dart';
import 'cubit/auth/auth_state.dart';
import 'cubit/customers_cubit/customers_cubit.dart';
import 'cubit/favorit_cubit/favorit_cubit_cubit.dart';
import 'cubit/provider_search_cubit/provider_search_cubit.dart';
import 'helper/app_router.dart';
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

  runApp(AppointmentApp());
}

Future<void> _initialApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ar', null);
  getIt.registerSingleton<AuthCubit>(AuthCubit()..checkAuthStatus());
}
