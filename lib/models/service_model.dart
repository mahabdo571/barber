import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration; // بالدقائق

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
  });

  factory Service.fromJson(Map<String, dynamic> json, String id) => Service(
    id: id,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    duration: (json['duration'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'duration': duration,
  };

  @override
  List<Object> get props => [id, name, description, price, duration];
}
