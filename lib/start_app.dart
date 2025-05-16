import 'package:barber/futuer/splash_screen/pres/splash_screen.dart';
import 'package:flutter/material.dart';

class StartApp extends StatelessWidget {
  const StartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(child: Scaffold(body: SplashScreen())),
    );
  }
}
