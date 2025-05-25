import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final List<String> categories; // تصنيفات الخدمة (اختياري لكن مفيد)
  final double rating; // متوسط التقييمات (افتراضي 0)
  final int ratingCount; // عدد التقييمات (افتراضي 0)
  final String imageUrl; // صورة الخدمة (اختياري)

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.categories = const [],
    this.rating = 0.0,
    this.ratingCount = 0,
    this.imageUrl = '',
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map, String docId) {
    return ServiceModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userId': userId,
      'categories': categories,
      'rating': rating,
      'ratingCount': ratingCount,
      'imageUrl': imageUrl,
    };
  }
}  
