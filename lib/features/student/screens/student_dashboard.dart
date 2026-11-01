import 'package:campus_reporting_app/core/theme/app_theme.dart';
import 'package:campus_reporting_app/features/incidents/widgets/incident_card.dart';
import 'package:campus_reporting_app/features/incidents/widgets/summary_card.dart';
import 'package:campus_reporting_app/features/student/widgets/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Report'),
        actions: [
          IconButton(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Hello, Alex Moyo 👋',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Report issues and track their resolution.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.yellow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.campaign, color: AppTheme.navy, size: 32),
                const SizedBox(height: 10),
                const Text(
                  'Campus Issue?',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'See something broken or unsafe?',
                  style: TextStyle(color: AppTheme.navy),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.navy,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => context.go('/student/report'),
                  child: const Text('Report an Issue'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Report Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total',
                  value: '12',
                  icon: Icons.description_outlined,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'In Progress',
                  value: '5',
                  icon: Icons.hourglass_top,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'Resolved',
                  value: '4',
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Reports',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
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
            title: 'Overflowing bin near cafeteria',
            location: 'Cafeteria',
            status: 'Resolved',
            onTap: () => context.go('/student/incident/INC-003'),
          ),
        ],
      ),
      bottomNavigationBar: const StudentNavigationBar(selectedIndex: 0),
    );
  }
}
