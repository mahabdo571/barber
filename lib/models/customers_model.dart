import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel extends Equatable  {
  final String id;
  final String name;
  final String phone;
  final DateTime joinDate;
  final String role;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.joinDate,
    required this.role,
  });

  /// تنشئ النموذج من بيانات Firestore
  factory CustomerModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerModel(
      id: id,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      joinDate: (json['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: json['role'] as String? ?? 'customer',
    );
  }

  /// تحوّل النموذج إلى Map لحفظه في Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'joinDate': Timestamp.fromDate(joinDate),
      'role': role,
    };
  }

  /// تنشئ نسخة جديدة مع تعديلات اختيارية
  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    DateTime? joinDate,
    String? role,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      joinDate: joinDate ?? this.joinDate,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, joinDate, role];
}
