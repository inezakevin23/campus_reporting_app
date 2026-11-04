import 'package:campus_reporting_app/features/incidents/providers/incident_provider.dart';
import 'package:campus_reporting_app/features/incidents/widgets/incident_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../staff/widgets/staff_incident_actions.dart';
import '../../../core/theme/app_theme.dart';

class IncidentDetailsScreen extends ConsumerWidget {
  final String incidentId;
  final bool isStaff;

  const IncidentDetailsScreen({
    super.key,
    required this.incidentId,
    this.isStaff = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(incidentDetailsProvider(incidentId));

    final historyAsync = ref.watch(incidentHistoryProvider(incidentId));

    return incidentAsync.when(
      // LOADING
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },

      // ERROR
      error: (error, stackTrace) {
        return Scaffold(
          appBar: AppBar(title: const Text('Incident Details')),

          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),

              child: Text(
                'Unable to retrieve incident details. '
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },

      // INCIDENT DATA
      data: (incident) {
        if (incident == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Incident Details')),

            body: const EmptyIncidentsWidget(
              message: 'This incident could not be found.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Incident Details')),

          body: ListView(
            padding: const EdgeInsets.all(16),

            children: [
              // IMAGE
              if (incident.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),

                  child: SizedBox(
                    width: double.infinity,
                    height: 220,

                    child: PrivateIncidentImage(imagePath: incident.imagePath!),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 170,

                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.image_outlined,
                    size: 55,
                    color: Colors.white38,
                  ),
                ),

              const SizedBox(height: 20),

              // TITLE AND STATUS
              Text(
                incident.title,

                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  IncidentStatusChip(status: incident.status),

                  const SizedBox(width: 8),

                  Text(
                    'ID: ${incident.id}',
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // INCIDENT INFORMATION
              _SectionTitle(title: 'Incident Information'),

              const SizedBox(height: 12),

              _InformationRow(
                icon: Icons.category_outlined,
                label: 'Category',
                value: formatIncidentLabel(incident.category),
              ),

              _InformationRow(
                icon: Icons.flag_outlined,
                label: 'Priority',
                value: formatIncidentLabel(incident.priority),
              ),

              _InformationRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: incident.location,
              ),

              _InformationRow(
                icon: Icons.calendar_today_outlined,
                label: 'Submitted',
                value: formatIncidentDate(incident.createdAt),
              ),

              const SizedBox(height: 24),

              // DESCRIPTION
              _SectionTitle(title: 'Description'),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Text(
                  incident.description,
                  style: const TextStyle(color: Colors.white70, height: 1.6),
                ),
              ),

              const SizedBox(height: 24),

              // STATUS TIMELINE
              _SectionTitle(title: 'Status Timeline'),

              const SizedBox(height: 12),

              historyAsync.when(
                loading: () {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  );
                },

                error: (error, stackTrace) {
                  return const Text(
                    'Unable to load status history.',
                    style: TextStyle(color: Colors.redAccent),
                  );
                },

                data: (history) {
                  if (history.isEmpty) {
                    return const EmptyIncidentsWidget(
                      message: 'No status updates available.',
                    );
                  }

                  return Column(
                    children: history.map((update) {
                      return _TimelineItem(
                        status: update.status,
                        note: update.note,
                        date: update.createdAt,
                        isLast: update.id == history.last.id,
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // STAFF PLACEHOLDER
              if (isStaff) ...[
                const SizedBox(height: 24),

                StaffIncidentActions(incident: incident),
              ],
            ],
          ),
        );
      },
    );
  }
}

// SECTION TITLE
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

// INFORMATION ROW
class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Row(
        children: [
          Icon(icon, color: AppTheme.yellow, size: 20),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// STATUS TIMELINE ITEM
class _TimelineItem extends StatelessWidget {
  final String status;
  final String note;
  final DateTime? date;
  final bool isLast;

  const _TimelineItem({
    required this.status,
    required this.note,
    required this.date,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isResolved = status == 'resolved';
    final isInProgress = status == 'in_progress';

    final color = isResolved
        ? Colors.green
        : isInProgress
        ? AppTheme.yellow
        : Colors.blue;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Timeline indicator and connecting line
          SizedBox(
            width: 30,

            child: Column(
              children: [
                Icon(
                  isResolved
                      ? Icons.check_circle
                      : isInProgress
                      ? Icons.timelapse
                      : Icons.radio_button_checked,

                  color: color,
                  size: 20,
                ),

                if (!isLast)
                  Expanded(child: Container(width: 2, color: Colors.white24)),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Timeline information
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    formatIncidentLabel(status),

                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(note, style: const TextStyle(color: Colors.white70)),

                  const SizedBox(height: 5),

                  Text(
                    formatIncidentDate(date),
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
