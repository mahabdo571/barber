import 'package:barber/Implementation/provider/firestore_schedule_repository.dart';
import 'package:barber/Implementation/provider/firestore_service_repository.dart';
import 'package:barber/cubit/schedule_cubit/schedule_cubit.dart';
import 'package:barber/helper/app_router.dart';
import 'package:barber/helper/help_metod.dart';
import 'package:go_router/go_router.dart';

import '../../cubit/service_provider_cubit/service_provider_cubit.dart';
import '../../view/provider/services/update_service_page.dart';
import 'service_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetAllServicesProvider extends StatelessWidget {
  const GetAllServicesProvider({super.key, required this.uid});
  final uid;
  @override
  Widget build(BuildContext context) {
    context.read<ServiceProviderCubit>().loadServices(uid);
    return BlocBuilder<ServiceProviderCubit, ServiceProviderState>(
      builder: (context, state) {
        switch (state.status) {
          case ServiceStatus.loading:
            return Center(child: CircularProgressIndicator());
          case ServiceStatus.failure:
            return Center(child: Text('حدث خط1أ: ${state.errorMessage}'));
          case ServiceStatus.success:
            final services = state.services;
            if (services.isEmpty) {
              return Center(child: Text('لم يتم اضافة خدمات بعد'));
            }
            return ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ServiceCard(
                  service: service,
                  onDelete: () {
                    if (getCurrentUserId() == service.ownerId) {
                      context
                          .read<ServiceProviderCubit>()
                          .deleteServiceFromOwner(service.id);
                    }
                  },
                  onEdit: () {
                    if (getCurrentUserId() == service.ownerId) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UpdateServicePage(service: service),
                        ),
                      );
                    } else {
                      final newRepo = FirestoreScheduleRepository(
                        userId: service.ownerId,
                      );
                      context.read<ScheduleCubit>().changeRepository(newRepo);
                      context.push(AppRouter.schedulePage);
                    }
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
