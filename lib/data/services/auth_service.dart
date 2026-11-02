import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  // Listen to login and logout changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get the currently logged-in user.
  User? get currentUser => _auth.currentUser;

  // Register a new student.
  Future<void> registerStudent({
    required String fullName,
    required String email,
    required String password,
  }) async {
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
    } catch (e) {
      // Remove the Auth account if its profile could not be saved.
      await user.delete();
      rethrow;
    }
  }

  // Login.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Logout.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Retrieve a user's Firestore profile.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final document = await _firestore.collection('users').doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }
}
