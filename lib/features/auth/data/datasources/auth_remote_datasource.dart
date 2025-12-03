import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDatasource {
  Future<User> signInWithEmail(String email, String password);
  Future<User> registerWithEmail(String username, String email, String password);
  Future<void> signOut();
  Stream<User?> get currentUser;
}