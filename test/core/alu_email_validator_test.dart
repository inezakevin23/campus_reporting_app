import 'package:campus_reporting_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ALU Email Validation Tests', () {
    test('Accepts valid ALU email', () {
      expect(isValidAluEmail('student@aluestudent.com'), true);
    });

    test('Accepts uppercase ALU email domain', () {
      expect(isValidAluEmail('STUDENT@ALUEDUCATION.COM'), true);
    });

    test('Rejects Gmail address', () {
      expect(isValidAluEmail('student@gmail.com'), false);
    });

    test('Rejects another institutional domain', () {
      expect(isValidAluEmail('student@example.com'), false);
    });

    test('Rejects fake ALU domain', () {
      expect(isValidAluEmail('student@fakealueducation.com'), false);
    });

    test('Rejects email without domain', () {
      expect(isValidAluEmail('student'), false);
    });
  });
}
