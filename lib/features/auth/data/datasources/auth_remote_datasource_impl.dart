import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRemoteDatasourceImpl(this._auth, this._db);

  @override
  Future<User> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return cred.user!;
  }

  @override
  Future<User> registerWithEmail(String username, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    final appUser = AppUserModel(id: user.uid, username: username, email: email);
    await _db.collection('users').doc(user.uid).set(appUser.toMap());
    return user;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<User?> get currentUser => _auth.authStateChanges();
}