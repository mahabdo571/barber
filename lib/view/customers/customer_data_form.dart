import '../../models/customers_model.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDataForm extends StatefulWidget {
  const CustomerDataForm({Key? key}) : super(key: key);

  @override
  _CustomerDataFormState createState() => _CustomerDataFormState();
}

class _CustomerDataFormState extends State<CustomerDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final customer = CustomerModel(

      name: _nameCtrl.text.trim(),
  
      joinDate: DateTime.now(),
      role: 'customer',
    );

  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('بيانات الزبون')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                        (v) =>
                            v == null || v.trim().isEmpty ? 'أدخل الاسم' : null,
                  ),
                  SizedBox(height: 16),
                  // رقم الجوال
                 
                  SizedBox(height: 24),
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
        ),
      ),
    );
  }
}
