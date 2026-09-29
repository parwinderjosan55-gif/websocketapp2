class UserModel {
  String uid;
  String name;
  String email;
  String phone;
  String fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'fcmToken': fcmToken,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? json['sender'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fcmToken: json['fcmToken'] ?? '',
    );
  }
}
