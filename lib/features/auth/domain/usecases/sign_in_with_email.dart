import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../../core/failures/failure.dart';
import '../entities/app_user.dart';

class SignInWithEmail {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  Future<Either<Failure, AppUser>> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}