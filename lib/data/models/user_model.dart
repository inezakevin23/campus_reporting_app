import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    final timestamp = data['createdAt'];

    return UserModel(
      uid: uid,
      fullName: data['fullName'] as String,
      email: data['email'] as String,
      role: data['role'] as String,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }

  bool get isStudent => role == 'student';

  bool get isStaff => role == 'staff';
}
