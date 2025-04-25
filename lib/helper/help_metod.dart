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




  


