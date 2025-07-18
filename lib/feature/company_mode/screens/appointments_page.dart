import 'package:barber/feature/company_mode/cubit/appointment_cubit/appointment_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key, required this.userId}) : super(key: key);
final String userId;

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void initState() {
    context.read<AppointmentCubit>().loadAppointments(widget.userId);
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AppointmentLoaded) {
          final dates = state.dates;
          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final dateModel = dates[index];
              return Dismissible(
                key: Key(dateModel.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  context.read<AppointmentCubit>().deleteAppointmentDate(
                    dateModel.id,
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ExpansionTile(
                  title: Text(
                    DateFormat.yMMMMd().format(dateModel.date.toDate()),
                  ),
                  subtitle: Text(
                    DateFormat.EEEE().format(dateModel.date.toDate()),
                  ),
                  children:
                      dateModel.slots.map((slot) {
                        return ListTile(
                          title: Text(slot.time),
                          trailing: Switch(
                            value: slot.isActive,
                            onChanged: (_) {
                              context.read<AppointmentCubit>().toggleTimeSlot(
                                dateModel.id,
                                slot.time,
                              );
                            },
                          ),
                        );
                      }).toList(),
                ),
              );
            },
          );
        } else if (state is AppointmentError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
