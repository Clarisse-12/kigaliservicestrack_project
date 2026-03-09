import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      await user.updateDisplayName(displayName);

      await user.sendEmailVerification();

      await _createUserProfile(
        uid: user.uid,
        email: email,
        displayName: displayName,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);
  }

  Future<void> updateNotificationPreference(
      String uid, bool enabled) async {
    await _firestore.collection('users').doc(uid).update({
      'notificationsEnabled': enabled,
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    Map<String, dynamic> data = {};

    if (displayName != null) data['displayName'] = displayName;
    if (photoUrl != null) data['photoUrl'] = photoUrl;

    await _firestore.collection('users').doc(uid).update(data);

    if (displayName != null) {
      await _auth.currentUser?.updateDisplayName(displayName);
    }
  }

  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    final user = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      emailVerified: false,
      notificationsEnabled: true,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toJson());
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email already exists';
      case 'invalid-email':
        return 'Invalid email';
      case 'user-not-found':
        return 'User not found';
      case 'wrong-password':
        return 'Wrong password';
      default:
        return e.message ?? 'Authentication error';
    }
  }
}