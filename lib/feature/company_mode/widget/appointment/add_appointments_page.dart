import 'package:barber/feature/company_mode/cubit/appointment_cubit/appointment_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddAppointmentsPage extends StatefulWidget {
  const AddAppointmentsPage({Key? key}) : super(key: key);

  @override
  _AddAppointmentsPageState createState() => _AddAppointmentsPageState();
}

class _AddAppointmentsPageState extends State<AddAppointmentsPage> {
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final intervalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Appointments')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(
                startDate == null
                    ? 'Select start date'
                    : DateFormat.yMd().format(startDate!),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => startDate = picked);
              },
            ),
            ListTile(
              title: Text(
                endDate == null
                    ? 'Select end date'
                    : DateFormat.yMd().format(endDate!),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: startDate ?? DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => endDate = picked);
              },
            ),
            ListTile(
              title: Text(
                startTime == null
                    ? 'Select start time'
                    : startTime!.format(context),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) setState(() => startTime = picked);
              },
            ),
            ListTile(
              title: Text(
                endTime == null ? 'Select end time' : endTime!.format(context),
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) setState(() => endTime = picked);
              },
            ),
            TextField(
              controller: intervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Interval (minutes)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (startDate != null &&
                    endDate != null &&
                    startTime != null &&
                    endTime != null &&
                    intervalController.text.isNotEmpty) {
                  context.read<AppointmentCubit>().addAppointmentRange(
                    startDate!,
                    endDate!,
                    startTime!,
                    endTime!,
                    int.parse(intervalController.text),
                    'USER_ID', // replace with actual user ID
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
