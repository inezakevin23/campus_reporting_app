import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';

// Firebase Authentication instance.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Firestore instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Authentication Service.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// Observe login and logout changes.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Retrieve a user's Firestore profile.
final userProfileProvider = FutureProvider.family<UserModel?, String>((
  ref,
  uid,
) async {
  final data = await ref.watch(authServiceProvider).getUserProfile(uid);

  if (data == null) {
    return null;
  }

  return UserModel.fromMap(uid, data);
});
