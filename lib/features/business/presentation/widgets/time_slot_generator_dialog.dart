import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/business.dart';
import '../cubit/business_cubit.dart';

class TimeSlotGeneratorDialog extends StatefulWidget {
  final Business business;

  const TimeSlotGeneratorDialog({super.key, required this.business});

  @override
  State<TimeSlotGeneratorDialog> createState() =>
      _TimeSlotGeneratorDialogState();
}

class _TimeSlotGeneratorDialogState extends State<TimeSlotGeneratorDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  int _intervalMinutes = 30;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إنشاء مواعيد جديدة'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('تاريخ البداية'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                      if (_endDate.isBefore(_startDate)) {
                        _endDate = _startDate;
                      }
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('تاريخ النهاية'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('وقت البداية'),
                subtitle: Text(_startTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                  );
                  if (time != null) {
                    setState(() {
                      _startTime = time;
                    });
                  }
                },
              ),
              ListTile(
                title: const Text('وقت النهاية'),
                subtitle: Text(_endTime.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _endTime,
                  );
                  if (time != null) {
                    setState(() {
                      _endTime = time;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _intervalMinutes,
                decoration: const InputDecoration(
                  labelText: 'مدة الموعد',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 دقيقة')),
                  DropdownMenuItem(value: 30, child: Text('30 دقيقة')),
                  DropdownMenuItem(value: 45, child: Text('45 دقيقة')),
                  DropdownMenuItem(value: 60, child: Text('60 دقيقة')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _intervalMinutes = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final startDateTime = DateTime(
                _startDate.year,
                _startDate.month,
                _startDate.day,
                _startTime.hour,
                _startTime.minute,
              );

              final endDateTime = DateTime(
                _endDate.year,
                _endDate.month,
                _endDate.day,
                _endTime.hour,
                _endTime.minute,
              );

              context.read<BusinessCubit>().generateTimeSlots(
                businessId: widget.business.id,
                startDate: startDateTime,
                endDate: endDateTime,
                startTime: startDateTime,
                endTime: endDateTime,
                intervalMinutes: _intervalMinutes,
              );

              Navigator.pop(context);
            }
          },
          child: const Text('إنشاء'),
        ),
      ],
    );
  }
}
