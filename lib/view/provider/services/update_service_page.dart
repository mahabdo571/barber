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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedService = widget.service.copyWith(
      name: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
    );

    await context.read<ServiceProviderCubit>().updateService(updatedService);

    setState(() => _isLoading = false);
    Navigator.pop(context); // رجوع بعد التعديل
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل الخدمة')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'اسم الخدمة'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'أدخل اسم الخدمة'
                            : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'الوصف'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'أدخل وصفاً' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'أدخل السعر' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child:
                    _isLoading
                        ? CircularProgressIndicator()
                        : Text('حفظ التعديلات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
