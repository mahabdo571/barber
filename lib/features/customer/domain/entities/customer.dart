import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String phone;
  final List<String> favoriteBusinessIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.favoriteBusinessIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    List<String>? favoriteBusinessIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      favoriteBusinessIds: favoriteBusinessIds ?? this.favoriteBusinessIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'favoriteBusinessIds': favoriteBusinessIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      favoriteBusinessIds: List<String>.from(map['favoriteBusinessIds']),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    favoriteBusinessIds,
    createdAt,
    updatedAt,
  ];
}
