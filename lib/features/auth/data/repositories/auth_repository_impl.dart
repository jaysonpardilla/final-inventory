import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/failures/failure.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;
  final FirebaseFirestore _db;

  AuthRepositoryImpl(this.datasource, this._db);

  @override
  Future<Either<Failure, AppUser>> signInWithEmail(String email, String password) async {
    try {
      final user = await datasource.signInWithEmail(email, password);
      final doc = await _db.collection('users').doc(user.uid).get();
      final appUser = AppUserModel.fromMap(user.uid, doc.data() ?? {});
      return Right(appUser);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUser>> registerWithEmail(String username, String email, String password) async {
    try {
      final user = await datasource.registerWithEmail(username, email, password);
      final doc = await _db.collection('users').doc(user.uid).get();
      final appUser = AppUserModel.fromMap(user.uid, doc.data() ?? {});
      return Right(appUser);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_mapAuthError(e.code)));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await datasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Sign out failed: $e'));
    }
  }

  @override
  Stream<AppUser?> get currentUser {
    return datasource.currentUser.asyncMap((user) async {
      if (user == null) return null;
      final doc = await _db.collection('users').doc(user.uid).get();
      return AppUserModel.fromMap(user.uid, doc.data() ?? {});
    });
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return "The email address is badly formatted.";
      case 'user-disabled':
        return "This account has been disabled.";
      case 'user-not-found':
        return "No user found for this email.";
      case 'wrong-password':
      case 'invalid-credential':
        return "Wrong password. Please try again.";
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'weak-password':
        return "Password is too weak. Try something stronger.";
      default:
        return "Authentication failed: $code";
    }
  }
}