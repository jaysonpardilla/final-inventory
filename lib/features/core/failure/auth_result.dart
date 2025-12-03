import 'package:inventory/features/core/failure/auth_failure.dart';

class AuthResult<T> {
final T? data;
final AuthFailure? failure;


const AuthResult._({this.data, this.failure});


bool get isSuccess => failure == null;


factory AuthResult.success(T? data) => AuthResult._(data: data);
factory AuthResult.failure(AuthFailure failure) => AuthResult._(failure: failure);
}