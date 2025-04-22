import 'package:barber/constants.dart';
import 'package:barber/view/barber_data_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: Text(kAppName)),
      body: Center(
        child: Column(
          children: [
            Text(
              'قم بالاختيار',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (_, __, ___) => const BarberDataForm(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              child: Image.asset(
                height: screenWidth - 100,
                'assets/images/barber.webp',
              ),
            ),
            SizedBox(height: 24),

            GestureDetector(
              onTap: () {},
              child: Image.asset(
                height: screenWidth - 100,
                'assets/images/person.webp',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
