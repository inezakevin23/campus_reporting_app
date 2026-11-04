import 'package:campus_reporting_app/features/auth/providers/auth_provider.dart';
import 'package:campus_reporting_app/features/incidents/widgets/incident_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Welcome, Campus Staff',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          const Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Pending',
                  value: '8',
                  icon: Icons.hourglass_empty,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'In Progress',
                  value: '5',
                  icon: Icons.timelapse,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: SummaryCard(
                  title: 'Resolved',
                  value: '23',
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Review Queue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          IncidentTile(
            title: 'Water shortage',
            location: 'Student Residence - Block A',
            status: 'Submitted',
            onTap: () => context.go('/staff/incident/INC-001'),
          ),

          IncidentTile(
            title: 'Broken classroom projector',
            location: 'Block B - Room 204',
            status: 'In Progress',
            onTap: () => context.go('/staff/incident/INC-002'),
          ),

          IncidentTile(
            title: 'Overflowing bin',
            location: 'Cafeteria',
            status: 'Submitted',
            onTap: () => context.go('/staff/incident/INC-003'),
          ),
        ],
      ),
    );
  }
}
