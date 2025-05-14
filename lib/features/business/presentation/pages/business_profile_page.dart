import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/business.dart';
import '../cubit/business_cubit.dart';

class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.userId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد الملف الشخصي'),
        centerTitle: true,
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(AppConstants.routeLogin);
          } else if (state is AuthAuthenticated) {
            _currentUserId = state.userId;
          }
        },
        child: BlocConsumer<BusinessCubit, BusinessState>(
          listener: (context, state) {
            if (state is BusinessProfileCreated) {
              context.go(AppConstants.routeBusinessHome);
            } else if (state is BusinessError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
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
                      'أدخل معلومات صالونك',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'يجب إكمال معلومات الصالون للوصول إلى لوحة التحكم',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الصالون',
                        hintText: 'أدخل اسم الصالون',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم الصالون';
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
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال رقم الهاتف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        hintText: 'أدخل عنوان الصالون',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال عنوان الصالون';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'الوصف',
                        hintText: 'أدخل وصف الصالون',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال وصف الصالون';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            state is BusinessLoading
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate() &&
                                      _currentUserId != null) {
                                    final business = Business(
                                      id: '',
                                      ownerId: _currentUserId!,
                                      name: _nameController.text,
                                      phone: _phoneController.text,
                                      address: _addressController.text,
                                      description: _descriptionController.text,
                                      images: const [],
                                      isActive: true,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    );
                                    context
                                        .read<BusinessCubit>()
                                        .createBusiness(business);
                                  }
                                },
                        child:
                            state is BusinessLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text('إنشاء الملف الشخصي'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
