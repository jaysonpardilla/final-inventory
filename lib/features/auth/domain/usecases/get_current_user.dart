import '../repositories/auth_repository.dart';
import '../entities/app_user.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Stream<AppUser?> call() {
    return repository.currentUser;
  }
}