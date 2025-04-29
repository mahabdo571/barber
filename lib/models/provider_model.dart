import 'users_model.dart';

class ProviderModel extends UsersModel {
  final String location;
  final String zipcode;
  final bool isActive;
  final DateTime subscriptionExpirationDate;

  ProviderModel({
    required this.location,
    required this.zipcode,
    required super.name,
    required super.phone,
    required super.role,
    required this.isActive,
    required this.subscriptionExpirationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'zipcode': zipcode,
      'location': location,
      'isActive': isActive,
      'createdAt': DateTime.now(),
      'subscriptionExpirationDate': subscriptionExpirationDate,
    };
  }

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      name: json['name'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      zipcode: json['zipcode'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool,
      subscriptionExpirationDate:
          json['subscriptionExpirationDate'] as DateTime,
    );
  }
}
