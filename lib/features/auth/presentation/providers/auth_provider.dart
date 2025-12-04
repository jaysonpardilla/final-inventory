import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/get_current_user.dart';

class AuthProvider extends ChangeNotifier {
  final SignInWithEmail signInWithEmail;
  final RegisterWithEmail registerWithEmail;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  AuthProvider({
    required this.signInWithEmail,
    required this.registerWithEmail,
    required this.signOut,
    required this.getCurrentUser,
  }) {
    _init();
  }

  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Stream<AppUser?> get userStream => getCurrentUser();

  void _init() {
    userStream.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await signInWithEmail(email, password);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (user) {
        _user = user;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await registerWithEmail(username, email, password);
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (user) {
        _user = user;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await signOut();
    result.fold(
      (failure) {
        _error = failure.message;
      },
      (_) {
        _user = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}