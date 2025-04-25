import '../../../cubit/schedule_cubit/schedule_cubit.dart';
import '../../../cubit/schedule_cubit/schedule_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddSchedulePage extends StatefulWidget {
  @override
  _AddSchedulePageState createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _fromDate;
  DateTime? _toDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _intervalController = TextEditingController();

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final today = DateTime.now();
    final initial = isStart ? (_fromDate ?? today) : (_toDate ?? today);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      builder:
          (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(ctx).primaryColor,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() => isStart ? _fromDate = picked : _toDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final now = TimeOfDay.now();
    final initial = isStart ? (_startTime ?? now) : (_endTime ?? now);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() => isStart ? _startTime = picked : _endTime = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_fromDate == null ||
        _toDate == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يرجى تحديد كل الحقول')));
      return;
    }
    if (_fromDate!.isAfter(_toDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تاريخ البداية يجب أن يكون قبل تاريخ النهاية')),
      );
      return;
    }
    final minutes = int.tryParse(_intervalController.text.trim());
    if (minutes == null || minutes <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('الفاصل الزمني غير صالح')));
      return;
    }
    context.read<ScheduleCubit>().generateSchedules(
      from: _fromDate!,
      to: _toDate!,
      start: _startTime!,
      end: _endTime!,
      interval: Duration(minutes: minutes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إنشاء الجداول الزمنية'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state.status == ScheduleStatus.success) {
            Navigator.of(context).pop();
          } else if (state.status == ScheduleStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'حدث خطأ')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == ScheduleStatus.loading;
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Date Range Pickers
                          Text(
                            'الفترة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : () => _pickDate(isStart: true),
                                  icon: Icon(Icons.date_range),
                                  label: Text(
                                    _fromDate == null
                                        ? 'من تاريخ'
                                        : '${_fromDate!.toLocal()}'.split(
                                          ' ',
                                        )[0],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : () => _pickDate(isStart: false),
                                  icon: Icon(Icons.date_range),
                                  label: Text(
                                    _toDate == null
                                        ? 'إلى تاريخ'
                                        : '${_toDate!.toLocal()}'.split(' ')[0],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          // Time Range Pickers
                          Text(
                            'ساعات الدوام',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : () => _pickTime(isStart: true),
                                  icon: Icon(Icons.access_time),
                                  label: Text(
                                    _startTime == null
                                        ? 'بداية'
                                        : _startTime!.format(context),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : () => _pickTime(isStart: false),
                                  icon: Icon(Icons.access_time),
                                  label: Text(
                                    _endTime == null
                                        ? 'نهاية'
                                        : _endTime!.format(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          // Interval Input
                          TextFormField(
                            controller: _intervalController,
                            decoration: InputDecoration(
                              labelText: 'الفاصل بين المواعيد (دقائق)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'أدخل الفاصل الزمني';
                              if (int.tryParse(value.trim()) == null)
                                return 'قيمة غير صالحة';
                              return null;
                            },
                          ),
                          SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child:
                                isLoading
                                    ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : Text(
                                      'توليد الجداول',
                                      style: TextStyle(fontSize: 16),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withAlpha(3),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
