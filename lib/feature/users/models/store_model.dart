import 'package:barber/feature/users/models/user_model.dart';

class StoreModel extends UserModel {
  final String storeName;
  final String ownerName;
  final String location;
  final String specialty;


  StoreModel({
    required super.uid,
    required super.phone,
    required this.storeName,
    required this.ownerName,
    required this.location,
    required super.otherPhone,
    required super.email,
    required this.specialty,
    required super.notes,
    required super.role,
    required super.createAt,
    required super.updatedAt,
     
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'storeName': storeName,
      'ownerName': ownerName,
      'location': location,
      'otherPhone': otherPhone,
      'email': email,
      'specialty': specialty,
      'notes': notes,
      'role': role,
      'createAt': createAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory StoreModel.fromMap(Map<String, dynamic> map) {
    return StoreModel(
      uid: map['uid'] ?? '',
      phone: map['phone'] ?? '',
      storeName: map['storeName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      location: map['location'] ?? '',
      otherPhone: map['otherPhone'] ?? '',
      email: map['email'] ?? '',
      specialty: map['specialty'] ?? '',
      notes: map['notes'] ?? '',
      role: map['role'] ?? '',
      createAt: DateTime.tryParse(map['createAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
} 
