import 'package:barber/constants.dart';
import 'package:barber/cubit/auth/auth_cubit.dart';
import 'package:barber/cubit/auth/auth_state.dart';
import 'package:barber/cubit/customers_cubit/customers_cubit.dart';
import 'package:barber/helper/help_metod.dart';
import 'package:barber/view/home_page_customer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../models/customers_model.dart';
import 'package:flutter/material.dart';

class CustomerDataForm extends StatefulWidget {
  const CustomerDataForm({Key? key}) : super(key: key);

  @override
  _CustomerDataFormState createState() => _CustomerDataFormState();
}

class _CustomerDataFormState extends State<CustomerDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _authCubit = GetIt.I<AuthCubit>();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    final currentUser = (_authCubit.state as Authenticated).authUser!;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final customer = CustomerModel(
      uid: currentUser.uid,
      phone: currentUser.phoneNumber as String,
      name: _nameCtrl.text.trim(),
      createdAt: Timestamp.now(),
      role: 'customer',
    );
    await context.read<CustomersCubit>().addCustomer(customer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('بيانات الزبون')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<CustomersCubit, CustomersState>(
          listener: (context, state) {
            if (state.status == CustomerStatus.loading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (_) => const Center(child: CircularProgressIndicator()),
              );
            } else {
              Navigator.of(context, rootNavigator: true).pop();
              if (state.status == CustomerStatus.success) {
                gotoPage_pushReplacement(context, HomePageCustomer());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ البيانات بنجاح!')),
                );
                _formKey.currentState?.reset();
              } else if (state.status == CustomerStatus.failure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ: ${state.errorMessage}')),
                );
              }
            }
          },
          builder: (context, state) {
            return _cardName();
          },
        ),
      ),
    );
  }

  Card _cardName() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // الاسم
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator:
                    (v) => v == null || v.trim().isEmpty ? 'أدخل الاسم' : null,
              ),
              SizedBox(height: 16),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child:
                      _isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text('حفظ البيانات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
