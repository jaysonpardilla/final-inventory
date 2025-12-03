import 'package:equatable/equatable.dart';


abstract class AuthFailure extends Equatable implements Exception {
final String message;
const AuthFailure([this.message = 'Authentication Failure']);


@override
List<Object?> get props => [message];
}


class ServerFailure extends AuthFailure {
const ServerFailure([super.message = 'Server Failure']);
}


class EmailAlreadyInUseFailure extends AuthFailure {
const EmailAlreadyInUseFailure([super.message = 'Email already in use']);
}


class WeakPasswordFailure extends AuthFailure {
const WeakPasswordFailure([super.message = 'Weak password']);
}


class UserNotFoundFailure extends AuthFailure {
const UserNotFoundFailure([super.message = 'User not found']);
}


class WrongPasswordFailure extends AuthFailure {
const WrongPasswordFailure([super.message = 'Wrong password']);
}


class UnknownFailure extends AuthFailure {
  const UnknownFailure([super.message = 'Unknown error']);
}