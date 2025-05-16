import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String businessId;
  final String name;
  final double price;
  final int duration; // in minutes
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Service({
    required this.id,
    required this.businessId,
    required this.name,
    required this.price,
    required this.duration,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Service copyWith({
    String? id,
    String? businessId,
    String? name,
    double? price,
    int? duration,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'price': price,
      'duration': duration,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as String? ?? '',
      businessId: map['businessId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: map['price'] == null ? 0.0 : (map['price'] as num).toDouble(),
      duration: map['duration'] as int? ?? 30,
      isActive: map['isActive'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    name,
    price,
    duration,
    isActive,
    createdAt,
    updatedAt,
  ];
}
