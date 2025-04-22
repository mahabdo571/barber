import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FormBarberBody extends StatefulWidget {
  const FormBarberBody({super.key});

  @override
  State<FormBarberBody> createState() => _FormBarberBodyState();
}

class _FormBarberBodyState extends State<FormBarberBody> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _zipcode = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _zipcode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // All fields are valid, process the data
      String name = _nameCtrl.text.trim();
      String phone = _phoneCtrl.text.trim();
      String location = _locationCtrl.text.trim();
      String zipcode = _zipcode.text.trim();

      // TODO: send data to backend or move to next screen
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تمّ حفظ البيانات بنجاح!')));
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
                labelText: 'الاسم كامل', // Label on top
                hintText: 'مثال: محمود داوود',
                prefixIcon: Icon(Icons.person), // clear icon
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone field
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone, // numeric keyboard
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف او واتساب',
                hintText: '+970591234567',
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
                labelText: 'موقع الصالون',
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
