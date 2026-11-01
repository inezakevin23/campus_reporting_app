import 'package:campus_reporting_app/core/theme/app_theme.dart';
import 'package:campus_reporting_app/features/incidents/widgets/status_chip.dart';
import 'package:flutter/material.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final String incidentId;
  final bool isStaff;

  const IncidentDetailsScreen({
    super.key,
    required this.incidentId,
    this.isStaff = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident Details')),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 60,
              color: Colors.white54,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Water shortage',
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 8),

          Text('Incident ID: $incidentId'),

          const SizedBox(height: 12),

          const StatusChip(status: 'In Progress'),

          const SizedBox(height: 24),

          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'There has been no water supply in the student residence '
            'since this morning. The issue is affecting students '
            'living in Block A.',
          ),

          const SizedBox(height: 24),

          const Text(
            'Status Timeline',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Submitted'),
            subtitle: Text('Incident received'),
          ),

          const ListTile(
            leading: Icon(Icons.timelapse, color: AppTheme.yellow),
            title: Text('In Progress'),
            subtitle: Text('Maintenance team notified'),
          ),

          const ListTile(
            leading: Icon(Icons.circle_outlined, color: Colors.white38),
            title: Text('Resolved'),
            subtitle: Text('Pending'),
          ),

          if (isStaff) ...[
            const SizedBox(height: 24),

            const Text(
              'Staff Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Status updates will be connected in Phase 5.',
                    ),
                  ),
                );
              },
              child: const Text('Update Incident Status'),
            ),
          ],
        ],
      ),
    );
  }
}
