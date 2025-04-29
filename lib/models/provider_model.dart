import 'package:cloud_firestore/cloud_firestore.dart';

import 'users_model.dart';

class ProviderModel extends UsersModel {
  final String location;
  final String zipcode;
  final bool isActive;
  final Timestamp subscriptionExpirationDate;

  ProviderModel({
    required this.location,
    required this.zipcode,
    required super.name,
    required super.phone,
    required super.role,
    required super.uid,
    required this.isActive,
    required super.createdAt,
    required this.subscriptionExpirationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'role': role,
      'zipcode': zipcode,
      'location': location,
      'isActive': isActive,
      'createdAt': Timestamp.now(),
      'subscriptionExpirationDate': subscriptionExpirationDate,
    };
  }

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      zipcode: json['zipcode'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as Timestamp,

      subscriptionExpirationDate:
          json['subscriptionExpirationDate'] as Timestamp,
    );
  }
}
