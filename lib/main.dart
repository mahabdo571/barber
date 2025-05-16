import 'package:barber/futuer/splash_screen/pres/splash_screen.dart';
import 'package:barber/start_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async {
  await _initializeApp();
  runApp(
    StartApp(),
  );
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
