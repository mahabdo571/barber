import 'package:barber/helper/help_metod.dart';
import 'package:barber/widget/provider/form_for_add_edit_service_provider.dart';

import '../../../cubit/service_provider_cubit/service_provider_cubit.dart';
import '../../../models/service_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateServicePage extends StatefulWidget {
  final Service service;

  const UpdateServicePage({Key? key, required this.service}) : super(key: key);

  @override
  State<UpdateServicePage> createState() => _UpdateServicePageState();
}

class _UpdateServicePageState extends State<UpdateServicePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(
      text: widget.service.description,
    );
    _priceController = TextEditingController(
      text: widget.service.price.toString(),
    );
    _durationController = TextEditingController(
      text: widget.service.duration.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedService = widget.service.copyWith(
      name: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      duration: int.tryParse(_durationController.text.trim()) ?? 0,
    );

    await context.read<ServiceProviderCubit>().updateService(updatedService);

    setState(() => _isLoading = false);
    Navigator.pop(context); // رجوع بعد التعديل
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل الخدمة')),
      body: FormForAddEditServiceProvider(
        isLoading: _isLoading,
        submit: () => _submit,
        formKey: _formKey,
        nameController: _titleController,
        descriptionController: _descriptionController,
        priceController: _priceController,
        durationController: _durationController,
      ),
    );
  }
}
