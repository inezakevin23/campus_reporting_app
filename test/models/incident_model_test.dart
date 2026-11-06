import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_reporting_app/data/models/incident_model.dart';

void main() {
  group('Incident Model Tests', () {
    test('Creates an incident from Firestore data', () {
      final date = DateTime.utc(2026, 11, 5);

      final data = {
        'title': 'Water shortage',

        'description': 'No water supply in Block A.',

        'category': 'water',

        'location': 'Block A',

        'priority': 'high',

        'status': 'submitted',

        'reporterId': 'student-123',

        'imagePath': 'incidents/incident-1/photo.webp',

        'createdAt': Timestamp.fromDate(date),

        'updatedAt': Timestamp.fromDate(date),
      };

      final incident = Incident.fromMap('incident-1', data);

      expect(incident.id, 'incident-1');

      expect(incident.title, 'Water shortage');

      expect(incident.category, 'water');

      expect(incident.status, 'submitted');

      expect(incident.reporterId, 'student-123');

      expect(incident.imagePath, 'incidents/incident-1/photo.webp');

      expect(incident.createdAt, date);
    });

    test('An incident can exist without a photograph', () {
      final data = {
        'title': 'Broken projector',

        'description': 'The projector does not work.',

        'category': 'facilities',

        'location': 'Room 204',

        'priority': 'medium',

        'status': 'submitted',

        'reporterId': 'student-123',

        'imagePath': null,

        'createdAt': null,

        'updatedAt': null,
      };

      final incident = Incident.fromMap('incident-2', data);

      expect(incident.imagePath, isNull);

      expect(incident.createdAt, isNull);
    });
  });
}
