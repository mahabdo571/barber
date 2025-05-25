import 'package:barber/feature/company_mode/cubit/service_section_cubit/service_section_cubit.dart';
import 'package:barber/feature/company_mode/widget/service_section/services_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesPage extends StatefulWidget {
  final String userId;
  const ServicesPage({super.key, required this.userId});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceSectionCubit>().getServicesByUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return ServicesWidget(userId: widget.userId);
  }
}
