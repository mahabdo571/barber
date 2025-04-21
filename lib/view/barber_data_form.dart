import 'package:barber/constants.dart';
import 'package:barber/widget/form_barber_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BarberDataForm extends StatelessWidget {
  const BarberDataForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kAppName)),
      body: Center(
        child: Column(
          children: [
            Text(
              'قم بتعبئة البيانات التالية',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            FormBarberBody(),
          ],
        ),
      ),
    );
  }
}
