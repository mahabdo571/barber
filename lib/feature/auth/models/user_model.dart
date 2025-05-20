class UserModel {
  final String uid;
  final String phone;
  final String? name;

  UserModel({required this.uid, required this.phone, this.name});

  Map<String, dynamic> toMap() => {'uid': uid, 'phone': phone, 'name': name};

  factory UserModel.fromMap(Map<String, dynamic> map) =>
      UserModel(uid: map['uid'], phone: map['phone'], name: map['name']);
}
