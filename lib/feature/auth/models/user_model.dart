class UserModel {
  final String uid;
  final String phone;
  String? name;
  final String otherPhone;
  final String email;
  final String notes;
  final DateTime createAt;
  final DateTime updatedAt;

  UserModel({
    this.name,
    required this.otherPhone,
    required this.email,
    required this.notes,
    required this.createAt,
    required this.updatedAt,
    required this.uid,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'otherPhone': otherPhone,
      'email': email,
      'notes': notes,
      'createAt': createAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phone: map['phone'] ?? '',
      name: map['name'] ?? '',
      otherPhone: map['otherPhone'] ?? '',
      email: map['email'] ?? '',

      notes: map['notes'] ?? '',
      createAt: DateTime.tryParse(map['createAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
