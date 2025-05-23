import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/auth/models/store_model.dart';
import 'package:barber/feature/auth/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreOwnerForm extends StatefulWidget {
  @override
  _StoreOwnerFormState createState() => _StoreOwnerFormState();
}

class _StoreOwnerFormState extends State<StoreOwnerForm> {
  final _formKey = GlobalKey<FormState>();

  final _storeNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _otherPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _storeNameController.dispose();
    _ownerNameController.dispose();
    _locationController.dispose();
    _otherPhoneController.dispose();
    _emailController.dispose();
    _specialtyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('بيانات صاحب المحل'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.store,
                  size: 80,
                  color: isDark ? Colors.tealAccent : Colors.teal,
                ),
                SizedBox(height: 12),
                Text(
                  'يرجى تعبئة بيانات صاحب المحل بدقة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                CustomTextField(
                  label: 'اسم المحل',
                  controller: _storeNameController,
                ),
                CustomTextField(
                  label: 'اسم المالك',
                  controller: _ownerNameController,
                ),
                CustomTextField(
                  label: 'الموقع',
                  controller: _locationController,
                ),
                CustomTextField(
                  label: 'رقم إضافي',
                  controller: _otherPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                CustomTextField(
                  label: 'البريد الإلكتروني',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  label: 'التخصص',
                  controller: _specialtyController,
                ),
                CustomTextField(
                  label: 'ملاحظات',
                  controller: _notesController,
                  maxLines: 3,
                ),

                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final storeModel = StoreModel(
                        uid:
                            (context.read<AuthCubit>().state
                                    as isProfileComplete)
                                .user
                                !.uid,
                        phone:
                            (context.read<AuthCubit>().state
                                    as isProfileComplete)
                                .user
                                !.phone,
                        storeName: _storeNameController.text.trim(),
                        ownerName: _ownerNameController.text.trim(),
                        location: _locationController.text.trim(),
                        otherPhone: _otherPhoneController.text.trim(),
                        email: _emailController.text.trim(),
                        specialty: _specialtyController.text.trim(),
                        notes: _notesController.text.trim(),
                        createAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      context.read<AuthCubit>().saveData(storeModel);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم حفظ البيانات')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('حفظ', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
