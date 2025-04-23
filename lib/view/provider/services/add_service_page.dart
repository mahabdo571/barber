import 'package:barber/helper/help_metod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubit/service_provider_cubit/service_provider_cubit.dart';
import '../../../models/service_model.dart';

class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final duration = int.parse(_durationController.text.trim());

      final service = Service(
        id: '', // Firestore سيولد الـ ID تلقائياً
        name: name,
        description: description,
        price: price,
        duration: duration,
      );

      context.read<ServiceProviderCubit>().addService(service);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة خدمة')),
      body: BlocConsumer<ServiceProviderCubit, ServiceProviderState>(
        listener: (context, state) {
          if (state.status == ServiceStatus.success) {
            Navigator.of(context).pop();
          } else if (state.status == ServiceStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'حدث خطأ')),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == ServiceStatus.loading;
          return FormForAddEditServiceProvider(
            isLoading,
            () => _submit,
            _formKey,
            _nameController,
            _descriptionController,
            _priceController,
            _durationController,
          );
        },
      ),
    );
  }
}
