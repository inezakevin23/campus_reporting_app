import 'package:campus_reporting_app/core/theme/app_theme.dart';
import 'package:campus_reporting_app/data/models/incident_model.dart';
import 'package:campus_reporting_app/features/incidents/providers/incident_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

String formatIncidentLabel(String value) {
  final normalized = value.trim();

  if (normalized.isEmpty) {
    return '';
  }

  return normalized
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}

String formatIncidentDate(DateTime? date) {
  if (date == null) {
    return 'Date unavailable';
  }

  return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.card,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.yellow),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      '_',
    );

    final color = switch (normalized) {
      'submitted' => Colors.blue,
      'in_progress' => AppTheme.yellow,
      'resolved' => Colors.green,
      _ => Colors.grey,
    };

    final textColor = normalized == 'in_progress'
        ? AppTheme.navy
        : Colors.white;

    return Chip(
      label: Text(
        formatIncidentLabel(normalized),
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
      backgroundColor: color,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

class IncidentStatusChip extends StatelessWidget {
  final String status;

  const IncidentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return StatusChip(status: status);
  }
}

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final bool isStaff;

  const IncidentCard({super.key, required this.incident, this.isStaff = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.card,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final route = isStaff
              ? '/staff/incident/${incident.id}'
              : '/student/incident/${incident.id}';

          context.go(route);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (incident.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: PublicIncidentImage(imagePath: incident.imagePath!),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.report_problem_outlined,
                    color: AppTheme.yellow,
                    size: 28,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${formatIncidentLabel(incident.category)} • '
                      '${formatIncidentDate(incident.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(status: incident.status),
            ],
          ),
        ),
      ),
    );
  }
}

class PublicIncidentImage extends ConsumerWidget {
  final String imagePath;

  const PublicIncidentImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ref.watch(publicImageUrlProvider(imagePath));

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppTheme.card,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, color: Colors.white54),
        );
      },
    );
  }
}

class EmptyIncidentsWidget extends StatelessWidget {
  final String message;

  const EmptyIncidentsWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 55, color: Colors.white38),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class MyReportSummary extends ConsumerWidget {
  const MyReportSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final reportsAsync = ref.watch(myReportsProvider(user.uid));

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, stackTrace) =>
          const Text('Unable to load report summary.'),

      data: (reports) {
        final total = reports.length;

        final inProgress = reports
            .where((report) => report.status == 'in_progress')
            .length;

        final resolved = reports
            .where((report) => report.status == 'resolved')
            .length;

        return Row(
          children: [
            Expanded(
              child: _ReportMetricCard(
                title: 'Total',
                value: total,
                icon: Icons.description_outlined,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _ReportMetricCard(
                title: 'In Progress',
                value: inProgress,
                icon: Icons.timelapse,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _ReportMetricCard(
                title: 'Resolved',
                value: resolved,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _ReportMetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),

      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Icon(icon, color: AppTheme.yellow),

          const SizedBox(height: 8),

          Text(
            value.toString(),
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
