import 'package:barber/core/constants/app_path.dart';
import 'package:barber/feature/auth/auth_cubit/auth_cubit.dart';
import 'package:barber/feature/auth/models/store_model.dart';
import 'package:barber/feature/auth/models/user_model.dart';
import 'package:barber/feature/auth/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InfoData extends StatefulWidget {
  @override
  _InfoDataState createState() => _InfoDataState();
}

class _InfoDataState extends State<InfoData> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _otherPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
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
        title: Text('ادخل البيانات الخاصة بك'),
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
                  Icons.person,
                  size: 80,
                  color: isDark ? Colors.tealAccent : Colors.teal,
                ),
                SizedBox(height: 12),
                Text(
                  'يرجى تعبئة بياناتك  بدقة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                CustomTextField(label: 'اسمك', controller: _nameController),

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
                  label: 'ملاحظات',
                  controller: _notesController,
                  maxLines: 3,
                ),

                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final userModel = UserModel(
                        uid:
                            (context.read<AuthCubit>().state
                                    as isProfileComplete)
                                .user!
                                .uid,
                        phone:
                            (context.read<AuthCubit>().state
                                    as isProfileComplete)
                                .user!
                                .phoneNumber!,
                        name: _nameController.text.trim(),

                        otherPhone: _otherPhoneController.text.trim(),
                        email: _emailController.text.trim(),

                        notes: _notesController.text.trim(),
                        createAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      context.read<AuthCubit>().saveData(userModel);
                      context.go(AppPath.initial);
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
