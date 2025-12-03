import 'package:dartz/dartz.dart';

import '../entities/app_user.dart';
import '../../core/failures/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password);
  Future<Either<Failure, AppUser>> registerWithEmail(String username, String email, String password);
  Future<Either<Failure, void>> signOut();
  Stream<AppUser?> get currentUser;
}