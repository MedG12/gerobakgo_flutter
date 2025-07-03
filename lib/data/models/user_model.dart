// models/user_model.dart
class User {
  final int id;
  final String name;
  final String email;
  String? photoUrl;
  final String role;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'user_id': id,
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'role': role,
      },
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['data']['user_id'],
      name: json['data']['name'],
      email: json['data']['email'],
      photoUrl: json['data']['photoUrl'],
      role: json['data']['role'],
      token: json['token'],
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['data']['user_id'],
      name: map['data']['name'],
      email: map['data']['email'],
      photoUrl: map['data']['photoUrl'],
      role: map['data']['role'],
      token: map['token'],
    );
  }
}
