import 'package:barber/models/users_model.dart';

class ProviderModel extends Users {

  final String location;
  final String zipcode;

  ProviderModel({
    required this.location,
   required this.zipcode,
    required super.uid,
    required super.name,
    required super.phone,
    required super.role,
  });

  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'role': role,
      'zipcode': zipcode,
      'location': location,
      'createdAt': DateTime.now(),
    };
  }

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      zipcode: json['zipcode'] as String,
      role: json['role'] as bool,
    );
  }
}


