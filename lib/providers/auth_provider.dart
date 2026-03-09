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
        _userProfile = await _authService.getUserProfile(_currentUser!.uid);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user profile: $e');
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
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> logIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.logIn(email: email, password: password);
      await _checkEmailVerification();
      await _loadUserProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> resendEmailVerification() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resendEmailVerification();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> checkEmailVerificationStatus() async {
    try {
      await _checkEmailVerification();
      if (_isEmailVerified && _currentUser != null) {
        await _loadUserProfile();
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUser != null) {
        await _authService.updateUserProfile(
          uid: _currentUser!.uid,
          displayName: displayName,
          photoUrl: photoUrl,
        );
        await _loadUserProfile();
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreference(bool enabled) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUser != null) {
        await _authService.updateNotificationPreference(
          _currentUser!.uid,
          enabled,
        );
        if (_userProfile != null) {
          _userProfile = _userProfile!.copyWith(notificationsEnabled: enabled);
        }
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _currentUser = null;
      _userProfile = null;
      _isEmailVerified = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
