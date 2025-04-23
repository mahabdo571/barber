import 'package:barber/Implementation/provider/firestore_service_repository.dart';
import 'package:barber/cubit/service_provider_cubit/service_provider_cubit.dart';
import 'package:barber/models/service_model.dart';
import 'package:barber/widget/provider/service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesPage extends StatelessWidget {
  ServicesPage({super.key});
  List<Service> services = [
    Service(
      id: '1',
      name: 'حلاقة رجالية',
      description: 'قص وتحديد وتشذيب لحية مع بخار',
      price: 30,
      duration: 40,
    ),

    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
    Service(
      id: '2',
      name: 'حلاقة نسوان',
      description: 'قص وتحديد وتشذيب بوتكس مع بخار',
      price: 22,
      duration: 11,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ServiceProviderCubit(repository: FirestoreServiceRepository())
                ..loadServices(),
      child: GetAllServicesProvider(),
    );
  }
}

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
