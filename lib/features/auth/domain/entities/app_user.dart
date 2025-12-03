import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String username;
  final String email;
  final String profileUrl;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.profileUrl = '',
  });

  @override
  List<Object> get props => [id, username, email, profileUrl];
}