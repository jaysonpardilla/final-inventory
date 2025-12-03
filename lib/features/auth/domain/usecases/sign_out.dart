import 'package:dartz/dartz.dart';

import '../repositories/auth_repository.dart';
import '../../core/failures/failure.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}













