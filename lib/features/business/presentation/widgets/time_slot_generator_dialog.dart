import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/business_cubit.dart';

class TimeSlotGeneratorDialog extends StatefulWidget {
  const TimeSlotGeneratorDialog({super.key});

  @override
  State<TimeSlotGeneratorDialog> createState() =>
      _TimeSlotGeneratorDialogState();
}

class _TimeSlotGeneratorDialogState extends State<TimeSlotGeneratorDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 21, minute: 0);
  int _intervalMinutes = 30;

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إنشاء مواعيد جديدة'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('من تاريخ'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                    onTap: _selectStartDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('إلى تاريخ'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                    onTap: _selectEndDate,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('من الساعة'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: _selectStartTime,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('إلى الساعة'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: _selectEndTime,
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<int>(
              value: _intervalMinutes,
              decoration: const InputDecoration(labelText: 'مدة الفترة'),
              items:
                  [15, 30, 45, 60].map((minutes) {
                    return DropdownMenuItem<int>(
                      value: minutes,
                      child: Text('$minutes دقيقة'),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _intervalMinutes = value!;
                });
              },
            ),
          ],
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
                businessId: 'business_id', // TODO: Get from business
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
