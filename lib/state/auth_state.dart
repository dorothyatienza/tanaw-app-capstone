import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tanaw_app/services/auth_service.dart';

class AuthState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthState() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    setLoading(true);
    try {
      final result = await _authService.signUpWithEmailAndPassword(email, password);
      setLoading(false);
      return result != null;
    } catch (e) {
      setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    setLoading(true);
    try {
      final result = await _authService.signInWithEmailAndPassword(email, password);
      setLoading(false);
      return result != null;
    } catch (e) {
      setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    setLoading(true);
    try {
      final result = await _authService.signInWithGoogle();
      setLoading(false);
      return result != null;
    } catch (e) {
      setLoading(false);
      return false;
    }
  }

  // Facebook sign-in removed

  Future<void> signOut() async {
    setLoading(true);
    try {
      await _authService.signOut();
    } finally {
      setLoading(false);
    }
  }
}
