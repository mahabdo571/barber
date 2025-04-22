class Users {
  final String uid;
  final String name;
  final String phone;
  final String location;
  final String zipcode;
  final bool isBarber;

  Users({
    required this.uid,
    required this.name,
    required this.phone,
    required this.location,
    required this.zipcode,
    required this.isBarber,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'location': location,
      'zipcode': zipcode,
      'isBarber': isBarber,
      'createdAt': DateTime.now(),
    };
  }

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      uid: json['uid'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      zipcode: json['zipcode'] as String,
      isBarber: json['isBarber'] as bool,
    );
  }
}
