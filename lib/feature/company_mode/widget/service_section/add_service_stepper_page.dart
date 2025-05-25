import 'package:barber/feature/company_mode/cubit/service_section_cubit/service_section_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barber/feature/company_mode/models/service_model.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class AddServiceStepperPage extends StatefulWidget {
  final String userId;
  const AddServiceStepperPage({required this.userId, super.key});

  @override
  State<AddServiceStepperPage> createState() => _AddServiceStepperPageState();
}

class _AddServiceStepperPageState extends State<AddServiceStepperPage> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isAvailable = true;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final service = ServiceModel(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        isAvailable: _isAvailable,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: widget.userId,
      );

      context.read<ServiceSectionCubit>().addService(service);
   GoRouter.of(context).pop(true);
    }
  }

  List<Step> _buildSteps() => [
    Step(
      title: const Text('معلومات أساسية'),
      content: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'اسم الخدمة'),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'أدخل اسم الخدمة' : null,
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'تفاصيل الخدمة'),
            maxLines: 3,
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'أدخل وصفاً للخدمة' : null,
          ),
        ],
      ),
      isActive: _currentStep == 0,
    ),
    Step(
      title: const Text('السعر والتوفر'),
      content: Column(
        children: [
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'سعر الخدمة'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'أدخل سعر الخدمة';
              }
              final price = double.tryParse(value);
              if (price == null || price <= 0) {
                return 'السعر يجب أن يكون رقمًا صالحًا أكبر من صفر';
              }
              return null;
            },
          ),
          SwitchListTile(
            title: const Text('هل الخدمة متاحة؟'),
            value: _isAvailable,
            onChanged: (val) {
              setState(() {
                _isAvailable = val;
              });
            },
          ),
        ],
      ),
      isActive: _currentStep == 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة خدمة جديدة')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < _buildSteps().length - 1) {
              setState(() => _currentStep++);
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
          steps: _buildSteps(),
          controlsBuilder: (context, details) {
            return Row(
              children: [
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(
                    _currentStep == _buildSteps().length - 1 ? 'حفظ' : 'التالي',
                  ),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('السابق'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
