import 'appointment_app.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
