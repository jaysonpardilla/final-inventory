import '../../domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.username,
    required super.email,
    super.profileUrl,
  });

  factory AppUserModel.fromMap(String id, Map<String, dynamic> map) {
    return AppUserModel(
      id: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profileUrl: map['profileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'profileUrl': profileUrl,
    };
  }
}