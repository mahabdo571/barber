class Barber {
  final String name;
  final String phone;
  final String location;
  final String zipcode;

  Barber({
    required this.name,
    required this.phone,
    required this.location,
    required this.zipcode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'location': location,
      'zipcode': zipcode,
      'createdAt': DateTime.now(),
    };
  }

  factory Barber.fromJson(Map<String, dynamic> json) {
    return Barber(
      name: json['name'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      zipcode: json['zipcode'] as String,
    );
  }
}
