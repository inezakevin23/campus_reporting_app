import 'package:campus_reporting_app/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserModel Tests', () {
    final testDate = DateTime(2026, 11, 1, 10, 30);

    final studentData = {
      'fullName': 'Test Student',
      'email': 'student@aluestudent.com',
      'role': 'student',
      'createdAt': Timestamp.fromDate(testDate),
    };

    test('Creates a student model from Firestore data', () {
      final user = UserModel.fromMap('student-123', studentData);

      expect(user.uid, 'student-123');
      expect(user.fullName, 'Test Student');
      expect(user.email, 'student@aluestudent.com');
      expect(user.role, 'student');
    });

    test('Identifies a student correctly', () {
      final user = UserModel.fromMap('student-123', studentData);

      expect(user.isStudent, isTrue);
      expect(user.isStaff, isFalse);
    });

    test('Identifies a staff member correctly', () {
      final staffData = {
        'fullName': 'Test Staff',
        'email': 'staff@alueducation.com',
        'role': 'staff',
        'createdAt': Timestamp.fromDate(testDate),
      };

      final user = UserModel.fromMap('staff-123', staffData);

      expect(user.uid, 'staff-123');
      expect(user.role, 'staff');
      expect(user.isStaff, isTrue);
      expect(user.isStudent, isFalse);
    });

    test('Creates a student model without department metadata', () {
      final dataWithoutDepartment = {
        'fullName': 'Test Student',
        'email': 'student@aluestudent.com',
        'role': 'student',
        'createdAt': Timestamp.fromDate(testDate),
      };

      final user = UserModel.fromMap('student-456', dataWithoutDepartment);
      expect(user.fullName, 'Test Student');
    });

    test('Converts Firestore timestamp correctly', () {
      final user = UserModel.fromMap('student-123', studentData);

      expect(user.createdAt, testDate);
    });

    test('Preserves user identity and role', () {
      final user = UserModel.fromMap('staff-123', {
        'fullName': 'Campus Staff',
        'email': 'staff@alueducation.com',
        'role': 'staff',
        'createdAt': Timestamp.fromDate(testDate),
      });

      expect(user.uid, 'staff-123');
      expect(user.email, 'staff@alueducation.com');
      expect(user.role, 'staff');
    });
  });
}
