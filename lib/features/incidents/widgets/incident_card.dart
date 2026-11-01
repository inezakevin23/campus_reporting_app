import 'package:campus_reporting_app/core/theme/app_theme.dart';
import 'package:campus_reporting_app/features/incidents/widgets/status_chip.dart';
import 'package:flutter/material.dart';

class IncidentTile extends StatelessWidget {
  final String title;
  final String location;
  final String status;
  final VoidCallback onTap;

  const IncidentTile({
    super.key,
    required this.title,
    required this.location,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.card,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: AppTheme.navy,
          child: Icon(Icons.report_problem_outlined, color: AppTheme.yellow),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: StatusChip(status: status),
      ),
    );
  }
}
