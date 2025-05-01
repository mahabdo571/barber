import 'package:barber/cubit/auth/auth_cubit.dart';
import 'package:barber/cubit/auth/auth_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cubit/profile_provider_cubit/profile_provider_cubit.dart';
import '../../cubit/profile_provider_cubit/profile_provider_state.dart';
import '../../helper/help_metod.dart';
import '../../models/provider_model.dart';
import '../../view/home_page_provider.dart';

class FormProviderBody extends StatefulWidget {
  const FormProviderBody({super.key, required this.role});
  final String role;

  @override
  State<FormProviderBody> createState() => _FormProviderBodyState();
}

class _FormProviderBodyState extends State<FormProviderBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(
    //  text: kUserAuth?.phoneNumber?.substring(1) ?? '',
  );
  final _locationCtrl = TextEditingController();
  final _zipcode = TextEditingController();
  final _id = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _zipcode.dispose();
    _id.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final barber = ProviderModel(
        uid: _id.text,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        zipcode: _zipcode.text.trim(),
        createdAt: Timestamp.now(),
        role: widget.role,
        isActive: true,
        subscriptionExpirationDate: Timestamp.fromDate(
          DateTime.now().add(Duration(days: 50)),
        ),
      );

      await context.read<ProfileProviderCubit>().addBarber(barber);
    }
  }

  Future<void> _launchMap() async {
    final url = Uri.parse('https://postcode.palestine.ps/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذّر فتح الرابط')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return BlocListener<ProfileProviderCubit, ProfileProviderState>(
      listener: (context, state) {
        if (state is ProfileProviderLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          if (state is ProfileProviderSuccess) {
            gotoPage(context, HomePageProvider());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ البيانات بنجاح!')),
            );
            _formKey.currentState?.reset();
          } else if (state is ProfileProviderFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('خطأ: ${state.error}')));
          }
        }
      },
      child: FillForm(),
    );
  }

  SingleChildScrollView FillForm() {
    final authCubit = context.read<AuthCubit>();
    final currntUser = (authCubit.state as Authenticated).authUser;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // consistent padding
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'الاسم التجاري', // Label on top
                hintText: 'مثال لاسم المعرض او الصالون ',
                prefixIcon: Icon(Icons.person), // clear icon
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم التجاري';
                }
                return null;
              },
            ),
            Offstage(
              offstage: true,
              child: TextFormField(initialValue: currntUser?.uid),
            ),
            const SizedBox(height: 16),

            // Phone field
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone, // numeric keyboard
              decoration: InputDecoration(
                labelText: 'رقم الهاتف او واتساب',
                hintText: currntUser?.phoneNumber,
                prefixIcon: Icon(Icons.phone),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                // basic phone pattern
                final reg = RegExp(r'^\d{7,15}$');
                if (!reg.hasMatch(value.trim())) {
                  return 'رقم غير صالح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location field
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'الموقع',
                hintText: 'المدينة أو العنوان التفصيلي',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال موقع الصالون';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location field
            TextFormField(
              controller: _zipcode,
              decoration: const InputDecoration(
                labelText: 'رقم المبنى',
                hintText: 'رقم المبنى لخرائط جوجل',
                prefixIcon: Icon(Icons.map),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'قم بادخل رقم المبنى';
                }
                return null;
              },
            ),

            const SizedBox(height: 16), // الجملة مع الرابط
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
              child: GestureDetector(
                onTap: _launchMap,
                child: RichText(
                  text: const TextSpan(
                    text: 'لتحديد رقم البناء تفضل بزيارة ',
                    style: TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: 'هذا الرابط',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('حفظ البيانات', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
