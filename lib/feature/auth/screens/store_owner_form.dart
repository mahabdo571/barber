import 'package:flutter/material.dart';

class StoreOwnerForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

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

                CustomTextField(label: 'اسم المحل'),
                CustomTextField(label: 'اسم المالك'),
                CustomTextField(label: 'الموقع'),
                CustomTextField(
                  label: 'رقم إضافي',
                  keyboardType: TextInputType.phone,
                ),
                CustomTextField(
                  label: 'البريد الإلكتروني',
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(label: 'التخصص'),
                CustomTextField(label: 'ملاحظات', maxLines: 3),

                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
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

class CustomTextField extends StatelessWidget {
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;

  CustomTextField({required this.label, this.keyboardType, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator:
            (value) =>
                (value == null || value.isEmpty) ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }
}
