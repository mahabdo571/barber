import '../../models/customers_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDataForm extends StatefulWidget {
  const CustomerDataForm({Key? key}) : super(key: key);

  @override
  _CustomerDataFormState createState() => _CustomerDataFormState();
}

class _CustomerDataFormState extends State<CustomerDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime _joinDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickJoinDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _joinDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final customer = CustomerModel(
      id: '', // سيملأّه Firestore تلقائيًا
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      joinDate: _joinDate,
      role: 'customer',
    );

    try {
      final doc = FirebaseFirestore.instance.collection('customers').doc();
      await doc.set(customer.copyWith(id: doc.id).toJson());
      Navigator.of(context).pop(); // العودة بعد الإضافة
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل الحفظ: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMd('ar').format(_joinDate);
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
