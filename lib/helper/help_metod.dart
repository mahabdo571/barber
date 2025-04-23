import '../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void gotoPage(BuildContext context, Widget widget) {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => widget,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

Future<Map<String, dynamic>?> getUserData() async {
  final user = await  getCurrentUser();
  final doc =
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid.toString())
          .get();

  if (doc.exists) {
    return doc.data();
  } else {
    return null;
  }
}

Future<User?> getCurrentUser() async {
  final user = await FirebaseAuth.instance.idTokenChanges().first;

  return user;
}




  SingleChildScrollView FormForAddEditServiceProvider(
    bool isLoading,
    Function submit,
     GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController priceController,
    TextEditingController durationController,

  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'اسم الخدمة',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال اسم الخدمة';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'وصف الخدمة',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال وصف الخدمة';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'السعر',
                      prefixText: '₪ ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال السعر';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'السعر غير صالح';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: durationController,
                    decoration: InputDecoration(
                      labelText: 'المدة (دقائق)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال المدة';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'المدة غير صالحة';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : submit(),
              child:
                  isLoading
                      ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text('حفظ'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


