import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
final String id;
final String username;
final String email;

const AuthUser({required this.id, required this.username, required this.email});

@override
List<Object?> get props => [id, username, email];
}