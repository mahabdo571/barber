import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../constants.dart';
import '../../../cubit/profile_provider_cubit/profile_provider_cubit.dart';
import '../../../widget/provider/form_provider_body.dart';

class BarberDataForm extends StatelessWidget {
  const BarberDataForm({super.key, required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileProviderCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text(kAppName)),
        body: Center(
          child: Column(
            children: [
              Text(
                'قم بتعبئة البيانات التالية',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              FormProviderBody(role: role),
            ],
          ),
        ),
      ),
    );
  }
}
