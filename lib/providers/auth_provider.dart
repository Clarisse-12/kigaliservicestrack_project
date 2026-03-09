import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  UserModel? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _isEmailVerified = false;

  User? get currentUser => _currentUser;
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null && _isEmailVerified;
  bool get isEmailVerified => _isEmailVerified;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _currentUser = user;

      if (user != null) {
        await _checkEmailVerification();
        await _loadUserProfile();
      } else {
        _userProfile = null;
        _isEmailVerified = false;
      }

      notifyListeners();
    });
  }

  Future<void> _checkEmailVerification() async {
    if (_currentUser != null) {
      await _currentUser!.reload();
      _isEmailVerified = _currentUser!.emailVerified;
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      if (_currentUser != null) {
        final profile =
            await _authService.getUserProfile(_currentUser!.uid);

        if (profile != null) {
          _userProfile = profile;
        }
      }
    } catch (e) {
      print("Profile loading error: $e");
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      _error = "Account created. Please verify your email.";
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.logIn(email: email, password: password);

      await _checkEmailVerification();

      if (!_isEmailVerified) {
        _error = "Please verify your email before logging in.";
        await _authService.signOut();
      } else {
        await _loadUserProfile();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      await _authService.resendEmailVerification();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();

      _currentUser = null;
      _userProfile = null;
      _isEmailVerified = false;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateNotificationPreference(bool enabled) async {
    if (_currentUser == null) return;

    try {
      await _authService.updateNotificationPreference(
        _currentUser!.uid,
        enabled,
      );

      if (_userProfile != null) {
        _userProfile =
            _userProfile!.copyWith(notificationsEnabled: enabled);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}