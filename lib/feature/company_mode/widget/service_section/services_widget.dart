import 'package:barber/feature/company_mode/cubit/service_section_cubit/service_section_cubit.dart';
import 'package:barber/feature/company_mode/widget/service_section/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesWidget extends StatelessWidget {
  final String userId;
  const ServicesWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceSectionCubit, ServiceSectionState>(
      builder: (context, state) {
        if (state is ServiceLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ServiceListLoaded) {
          final services = state.services;
          if (services.isEmpty) {
            return const Center(child: Text('لا توجد خدمات حالياً'));
          }
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ServiceCard(service: service);
            },
          );
        } else if (state is ServiceFailure) {
          return Center(child: Text('خطأ: ${state.error}'));
        }
        return const Center(child: Text('خطأ بجلب البيانات'));
      },
    );
  }
}
