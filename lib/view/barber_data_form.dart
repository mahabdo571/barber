import 'package:barber/cubit/barber_cubit/barber_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants.dart';
import '../widget/form_barber_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BarberDataForm extends StatelessWidget {
  const BarberDataForm({super.key, required this.isBarber});
  final bool isBarber;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BarberCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text(kAppName)),
        body: Center(
          child: Column(
            children: [
              Text(
                'قم بتعبئة البيانات التالية',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              FormBarberBody(isBarber:isBarber),
            ],
          ),
        ),
      ),
    );
  }
}
