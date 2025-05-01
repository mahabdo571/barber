import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritModel {
  final String name;
  final String phone;
  final String uid;
  final Timestamp createdAt;

  FavoritModel({
    required this.name,
    required this.phone,
    required this.uid,
    required this.createdAt,
  });
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'name': name, 'phone': phone, 'createdAt': createdAt};
  }

  factory FavoritModel.fromJson(Map<String, dynamic> json) {
    return FavoritModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      createdAt: json['createdAt'] as Timestamp,
    );
  }
    factory FavoritModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoritModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}
