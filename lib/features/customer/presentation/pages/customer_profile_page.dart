import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/customer.dart';
import '../cubit/customer_cubit.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد الملف الشخصي'),
        centerTitle: true,
      ),
      body: BlocConsumer<CustomerCubit, CustomerState>(
        listener: (context, state) {
          if (state is CustomerProfileCreated) {
            context.go(AppConstants.routeCustomerHome);
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'أدخل معلوماتك الشخصية',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      hintText: 'أدخل اسمك الكامل',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: '+966XXXXXXXXX',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state is CustomerLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              final customer = Customer(
                                id: '',
                                name: _nameController.text,
                                phone: _phoneController.text,
                                favoriteBusinessIds: const [],
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );
                              context.read<CustomerCubit>().createCustomer(
                                customer,
                              );
                            }
                          },
                    child: state is CustomerLoading
                        ? const CircularProgressIndicator()
                        : const Text('إنشاء الملف الشخصي'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 