import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // بالدقائق
  final String ownerId; // بالدقائق

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.ownerId,
  });

  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? duration,
    String? ownerId,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  factory Service.fromJson(Map<String, dynamic> json, String id) => Service(
    id: id,
    name: json['name'] as String,
    ownerId: json['ownerId'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    duration: (json['duration'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'duration': duration,
    'ownerId': ownerId,
  };

  @override
  List<Object> get props => [id, name, description, price, duration, ownerId];
}
