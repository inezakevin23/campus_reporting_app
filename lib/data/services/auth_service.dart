import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({required this._auth, required this._firestore});

  // Listen to auth state changes that are triggered by reloads and verification updates.
  Stream<User?> get userChanges => _auth.userChanges();

  // Backwards-compatible alias for older code paths.
  Stream<User?> get authStateChanges => _auth.userChanges();

  // Get the currently logged-in user.
  User? get currentUser => _auth.currentUser;

  bool isAllowedAluEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final emailParts = normalizedEmail.split('@');

    if (emailParts.length != 2) {
      return false;
    }

    final domain = emailParts[1];
    return domain == 'alueducation.com' || domain == 'alustudent.com';
  }

  void _validateAluEmail(String email) {
    if (!isAllowedAluEmail(email)) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please use a valid ALU email address (@alueducation.com or @alustudent.com).',
      );
    }
  }

  Future<bool> checkEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    final refreshedUser = _auth.currentUser;

    if (refreshedUser == null) {
      return false;
    }

    if (refreshedUser.emailVerified) {
      await refreshedUser.getIdToken(true);
    }

    return refreshedUser.emailVerified;
  }

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user is currently signed in.',
      );
    }

    await user.sendEmailVerification();
  }

  Future<void> registerStudent({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _validateAluEmail(email);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Account creation failed.');
    }

    try {
      await user.updateDisplayName(fullName.trim());

      await _firestore.collection('users').doc(user.uid).set({
        'fullName': fullName.trim(),
        'email': user.email ?? email.trim(),
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      try {
        await user.sendEmailVerification();
      } catch (_) {
        // Email delivery can fail without blocking the user from requesting it again.
      }
    } catch (e) {
      await user.delete();
      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    _validateAluEmail(email);

    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    _validateAluEmail(email);
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  Future<UserModel?> fetchUserModel(String uid) async {
    final data = await getUserProfile(uid);

    if (data == null) {
      return null;
    }

    return UserModel.fromMap(uid, data);
  }
}
