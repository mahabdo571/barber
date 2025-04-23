import 'package:barber/Implementation/provider/firestore_service_repository.dart';
import 'package:barber/cubit/service_provider_cubit/service_provider_cubit.dart';
import 'package:barber/widget/provider/get_all_services_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesPage extends StatelessWidget {
  ServicesPage({super.key});
  

  @override
  Widget build(BuildContext context) {
    return GetAllServicesProvider();
  }
}
