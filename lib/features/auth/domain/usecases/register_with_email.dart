import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../../core/failures/failure.dart';
import '../entities/app_user.dart';

class RegisterWithEmail {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  Future<Either<Failure, AppUser>> call(String username, String email, String password) {
    return repository.registerWithEmail(username, email, password);
  }
}