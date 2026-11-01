import 'package:campus_reporting_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Submitted' => Colors.blue,
      'In Progress' => AppTheme.yellow,
      'Resolved' => Colors.green,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(status, style: const TextStyle(color: AppTheme.navy)),
      backgroundColor: color,
      side: BorderSide.none,
    );
  }
}
