import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auth_user_model.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get user;
  Future<AuthUser> signInWithGoogle();
  Future<AuthUser> signInWithApple();
  Future<void> signOut();
  Future<AuthUser?> getCurrentUser();
}

class DummyAuthRepository implements AuthRepository {
  final _userController = StreamController<AuthUser?>.broadcast();
  static const _authKey = 'dummy_auth_logged_in';
  AuthUser? _currentUser;

  DummyAuthRepository() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_authKey) ?? false;
    if (isLoggedIn) {
      _currentUser = const AuthUser(
        id: 'dummy_user_123',
        email: 'john.doe@example.com',
        displayName: 'John Doe',
      );
    } else {
      _currentUser = null;
    }
    _userController.add(_currentUser);
  }

  @override
  Stream<AuthUser?> get user => _userController.stream;

  @override
  Future<AuthUser?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return _doDummySignIn('google_user', 'Google User');
  }

  @override
  Future<AuthUser> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 1));
    return _doDummySignIn('apple_user', 'Apple User');
  }

  Future<AuthUser> _doDummySignIn(String id, String name) async {
    final user = AuthUser(
      id: id,
      email: '$id@example.com',
      displayName: name,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, true);
    
    _currentUser = user;
    _userController.add(_currentUser);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, false);
    
    _currentUser = null;
    _userController.add(null);
  }
}
