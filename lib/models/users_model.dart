import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel {
  final String uid;
  final String name;
  final String phone;
  final String role;
  final Timestamp createdAt;

  UsersModel({
    required this.name,
    required this.phone,
    required this.role,
    required this.uid,
    required this.createdAt,
  });
}
