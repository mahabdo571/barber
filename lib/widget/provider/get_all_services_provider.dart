import 'package:barber/cubit/service_provider_cubit/service_provider_cubit.dart';
import 'package:barber/widget/provider/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetAllServicesProvider extends StatelessWidget {
  const GetAllServicesProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceProviderCubit, ServiceProviderState>(
      builder: (context, state) {
        switch (state.status) {
          case ServiceStatus.loading:
            return Center(child: CircularProgressIndicator());
          case ServiceStatus.failure:
            return Center(child: Text('حدث خطأ: ${state.errorMessage}'));
          case ServiceStatus.success:
            final services = state.services;
            if (services.isEmpty) {
              return Center(child: Text('ما عندك أي خدمات بعد'));
            }
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ServiceCard(
                  service: service,
                  onDelete: () {
                 
                    // عند السحب لليمين
                    context.read<ServiceProviderCubit>().deleteService(
                      service.id,
                    );
                  },
                  onEdit: () {
                    // عند السحب لليسار
                    // TODO: فتح نافذة تعديل الخدمة وإرسال updatedService
                    // context.read<ServiceCubit>().updateService(updatedService);
                  },
                );
              },
            );
          default:
            return SizedBox.shrink();
        }
      },
    );
  }
}
