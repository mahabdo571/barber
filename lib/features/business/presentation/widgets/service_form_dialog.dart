import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/service.dart';
import '../cubit/business_cubit.dart';

class ServiceFormDialog extends StatefulWidget {
  final Service? service;
  final String businessId;

  const ServiceFormDialog({super.key, this.service, required this.businessId});

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _priceController.text = widget.service!.price.toString();
      _durationController.text = widget.service!.duration.toString();
      _isActive = widget.service!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.service == null ? 'إضافة خدمة' : 'تعديل الخدمة'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الخدمة',
                hintText: 'أدخل اسم الخدمة',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم الخدمة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'السعر',
                hintText: 'أدخل سعر الخدمة',
                suffixText: 'ريال',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال السعر';
                }
                if (double.tryParse(value) == null) {
                  return 'الرجاء إدخال رقم صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المدة',
                hintText: 'أدخل مدة الخدمة',
                suffixText: 'دقيقة',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال المدة';
                }
                if (int.tryParse(value) == null) {
                  return 'الرجاء إدخال رقم صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('متاحة للحجز'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
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
              final service = Service(
                id: widget.service?.id ?? '',
                businessId: widget.service?.businessId ?? widget.businessId,
                name: _nameController.text,
                price: double.parse(_priceController.text),
                duration: int.parse(_durationController.text),
                isActive: _isActive,
                createdAt: widget.service?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );

              if (widget.service == null) {
                context.read<BusinessCubit>().createService(service);
              } else {
                context.read<BusinessCubit>().updateService(service);
              }

              Navigator.pop(context);
            }
          },
          child: Text(widget.service == null ? 'إضافة' : 'تعديل'),
        ),
      ],
    );
  }
}
