import 'package:campus_reporting_app/features/auth/providers/auth_provider.dart';
import 'package:campus_reporting_app/features/incidents/providers/incident_provider.dart';
import 'package:campus_reporting_app/features/incidents/screens/incident_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(staffIncidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),

        actions: [
          IconButton(
            tooltip: 'Refresh incidents',
            onPressed: () {
              ref.invalidate(staffIncidentsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),

          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              try {
                await ref.read(authServiceProvider).signOut();
              } catch (error) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unable to sign out.')),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: incidentsAsync.when(
        // LOADING
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        // ERROR
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 45,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Unable to load the staff dashboard.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(staffIncidentsProvider);
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        },

        // INCIDENT DATA
        data: (incidents) {
          final total = incidents.length;

          final submitted = incidents
              .where((item) => item.status == 'submitted')
              .length;

          final inProgress = incidents
              .where((item) => item.status == 'in_progress')
              .length;

          final resolved = incidents
              .where((item) => item.status == 'resolved')
              .length;

          return Column(
            children: [
              // STAFF HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),

                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: AppTheme.yellow,
                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        color: AppTheme.navy,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Welcome, Campus Staff',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            'Review and manage campus incidents.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // STATISTICS
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: _StaffStatCard(
                        title: 'Total',
                        count: total,
                        icon: Icons.description_outlined,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 7),

                    Expanded(
                      child: _StaffStatCard(
                        title: 'Pending',
                        count: submitted,
                        icon: Icons.hourglass_empty,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 7),

                    Expanded(
                      child: _StaffStatCard(
                        title: 'In Progress',
                        count: inProgress,
                        icon: Icons.timelapse,
                        color: AppTheme.yellow,
                      ),
                    ),

                    const SizedBox(width: 7),

                    Expanded(
                      child: _StaffStatCard(
                        title: 'Resolved',
                        count: resolved,
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              // REVIEW QUEUE
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 18, 16, 6),

                child: Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    'Incident Review Queue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Reuse the same searchable and filterable
              // incident list used by the student screens.
              Expanded(
                child: IncidentFilterList(
                  incidents: incidents,
                  emptyMessage: 'There are no incidents to review.',
                  isStaff: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// STAFF STATISTIC CARD
class _StaffStatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StaffStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),

      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Icon(icon, color: color, size: 21),

          const SizedBox(height: 8),

          Text(
            count.toString(),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

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
