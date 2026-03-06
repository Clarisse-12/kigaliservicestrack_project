import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user account
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Set display name
      await userCredential.user?.updateDisplayName(displayName);

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Create user profile in Firestore
      await _createUserProfile(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Log in with email and password
  Future<UserCredential> logIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Check if email is verified
      await userCredential.user?.reload();
      if (!userCredential.user!.emailVerified) {
        // Send email verification if not verified
        try {
          await userCredential.user?.sendEmailVerification();
        } catch (e) {
          print('Failed to send verification email: $e');
        }
        // Sign out the user if not verified
        await _firebaseAuth.signOut();
        throw 'Email not verified. Please check your email and click the verification link.';
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw 'Failed to resend email verification: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Failed to sign out: $e';
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user profile: $e';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (displayName != null) {
        updateData['displayName'] = displayName;
      }
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      await _firestore.collection('users').doc(uid).update(updateData);

      // Update Firebase Auth display name
      if (displayName != null) {
        await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      }
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreference(String uid, bool enabled) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'notificationsEnabled': enabled,
      });
    } catch (e) {
      throw 'Failed to update notification preferences: $e';
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    try {
      UserModel userModel = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        emailVerified: false,
        notificationsEnabled: true,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(userModel.toJson());
    } catch (e) {
      throw 'Failed to create user profile: $e';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user account found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
