import 'package:barber/cubit/schedule_cubit/schedule_cubit.dart';
import 'package:barber/cubit/schedule_cubit/schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleCubit, ScheduleState>(
      builder: (context, state) {
        switch (state.status) {
          case ScheduleStatus.loading:
            return Center(child: CircularProgressIndicator());
          case ScheduleStatus.failure:
            return Center(child: Text('حدث خطأ: ${state.errorMessage}'));
          case ScheduleStatus.success:
            final schedules = state.schedules;
            if (schedules.isEmpty) {
              return Center(child: Text('لم يتم اضافة خدمات بعد'));
            }
            return ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final service = schedules[index];
                return Text(
                  service.date,
                ); // Assuming ScheduleModel has a name property
              },
            );
          default:
            return SizedBox.shrink();
        }
      },
    );
  }
}
