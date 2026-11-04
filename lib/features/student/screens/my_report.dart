import 'package:campus_reporting_app/features/incidents/widgets/incident_widget.dart';
import 'package:campus_reporting_app/features/student/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search reports...',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 20),

          IncidentTile(
            title: 'Water shortage',
            location: 'Student Residence - Block A',
            status: 'Submitted',
            onTap: () => context.go('/student/incident/INC-001'),
          ),

          IncidentTile(
            title: 'Broken classroom projector',
            location: 'Block B - Room 204',
            status: 'In Progress',
            onTap: () => context.go('/student/incident/INC-002'),
          ),

          IncidentTile(
            title: 'Overflowing bin',
            location: 'Cafeteria',
            status: 'Resolved',
            onTap: () => context.go('/student/incident/INC-003'),
          ),
        ],
      ),

      bottomNavigationBar: const StudentNavigationBar(selectedIndex: 1),
    );
  }
}
