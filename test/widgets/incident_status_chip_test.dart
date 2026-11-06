import 'package:campus_reporting_app/features/incidents/widgets/incident_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Incident Status Chip Tests', () {
    testWidgets('Displays Submitted correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: IncidentStatusChip(status: 'submitted')),
        ),
      );

      expect(find.text('Submitted'), findsOneWidget);
    });

    testWidgets('Displays In Progress correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: IncidentStatusChip(status: 'in_progress')),
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('Displays Resolved correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: IncidentStatusChip(status: 'resolved')),
        ),
      );

      expect(find.text('Resolved'), findsOneWidget);
    });
  });
}
