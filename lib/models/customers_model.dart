import 'package:barber/models/users_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel extends UsersModel {
  CustomerModel({
    required super.name,
    required super.phone,
    required super.role,
    required super.uid,
    required super.createdAt,
  });

  /// تنشئ النموذج من بيانات Firestore
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      createdAt: json['createdAt'] as Timestamp? ?? Timestamp.now(),
      role: json['role'] as String? ?? 'customer',
    );
  }

  /// تحوّل النموذج إلى Map لحفظه في Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'createdAt': createdAt,
      'role': role,
    };
  }

  /// تنشئ نسخة جديدة مع تعديلات اختيارية
  CustomerModel copyWith({
    String? uid,
    String? name,
    String? phone,
    Timestamp? createdAt,
    String? role,
  }) {
    return CustomerModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [uid, name, phone, createdAt, role];
}
