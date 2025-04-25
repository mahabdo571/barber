import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel extends Equatable  {

  final String name;

  final DateTime joinDate;
  final String role;

  const CustomerModel({

    required this.name,

    required this.joinDate,
    required this.role,
  });

  /// تنشئ النموذج من بيانات Firestore
  factory CustomerModel.fromJson(Map<String, dynamic> json, String id) {
    return CustomerModel(

      name: json['name'] as String? ?? '',

      joinDate: (json['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: json['role'] as String? ?? 'customer',
    );
  }

  /// تحوّل النموذج إلى Map لحفظه في Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,

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

            name: name ?? this.name,

      joinDate: joinDate ?? this.joinDate,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [ name, joinDate, role];
}
