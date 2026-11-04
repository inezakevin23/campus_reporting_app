import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/incident_model.dart';
import '../providers/incident_provider.dart';
import '../widgets/incident_widget.dart';

// CAMPUS INCIDENT FEED
class IncidentFeedScreen extends ConsumerWidget {
  const IncidentFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(campusIncidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Incidents'),

        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(campusIncidentsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: incidentsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

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
                    'Unable to load campus incidents.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(campusIncidentsProvider);
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        },

        data: (incidents) {
          return IncidentFilterList(
            incidents: incidents,
            emptyMessage: 'No campus incidents have been reported yet.',
          );
        },
      ),
    );
  }
}

// MY REPORTS
class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your reports.')),
      );
    }

    final reportsAsync = ref.watch(myReportsProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),

      body: reportsAsync.when(
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 45,
                    color: Colors.redAccent,
                  ),

                  const SizedBox(height: 12),

                  const Text('Unable to load your reports.'),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(myReportsProvider(currentUser.uid));
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        },

        data: (incidents) {
          return IncidentFilterList(
            incidents: incidents,
            emptyMessage: 'You have not submitted any reports yet.',
          );
        },
      ),
    );
  }
}

// SHARED SEARCH AND FILTER INTERFACE
class IncidentFilterList extends StatefulWidget {
  final List<Incident> incidents;
  final String emptyMessage;

  const IncidentFilterList({
    super.key,
    required this.incidents,
    required this.emptyMessage,
  });

  @override
  State<IncidentFilterList> createState() => _IncidentFilterListState();
}

class _IncidentFilterListState extends State<IncidentFilterList> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'all';
  String _selectedStatus = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // FILTER INCIDENTS

  List<Incident> get filteredIncidents {
    final query = _searchController.text.trim().toLowerCase();

    return widget.incidents.where((incident) {
      final matchesSearch =
          incident.title.toLowerCase().contains(query) ||
          incident.description.toLowerCase().contains(query) ||
          incident.location.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'all' || incident.category == _selectedCategory;

      final matchesStatus =
          _selectedStatus == 'all' || incident.status == _selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  // BUILD FILTER INTERFACE
  @override
  Widget build(BuildContext context) {
    final results = filteredIncidents;

    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),

          child: TextField(
            controller: _searchController,

            onChanged: (_) {
              setState(() {});
            },

            decoration: InputDecoration(
              hintText: 'Search by title, description or location',

              prefixIcon: const Icon(Icons.search),

              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
          ),
        ),

        // Filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          child: Row(
            children: [
              // Category filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,

                  isExpanded: true,

                  decoration: const InputDecoration(
                    labelText: 'Category',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All Categories'),
                    ),

                    DropdownMenuItem(
                      value: 'facilities',
                      child: Text('Facilities'),
                    ),

                    DropdownMenuItem(value: 'water', child: Text('Water')),

                    DropdownMenuItem(
                      value: 'electricity',
                      child: Text('Electricity'),
                    ),

                    DropdownMenuItem(value: 'safety', child: Text('Safety')),

                    DropdownMenuItem(
                      value: 'sanitation',
                      child: Text('Sanitation'),
                    ),

                    DropdownMenuItem(
                      value: 'furniture',
                      child: Text('Furniture'),
                    ),
                  ],

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ),

              const SizedBox(width: 10),

              // Status filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,

                  isExpanded: true,

                  decoration: const InputDecoration(
                    labelText: 'Status',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),

                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Statuses')),

                    DropdownMenuItem(
                      value: 'submitted',
                      child: Text('Submitted'),
                    ),

                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('In Progress'),
                    ),

                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('Resolved'),
                    ),
                  ],

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Incident Results',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Text(
                '${results.length} reports',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),

        // Incident list
        Expanded(
          child: results.isEmpty
              ? EmptyIncidentsWidget(
                  message: widget.incidents.isEmpty
                      ? widget.emptyMessage
                      : 'No incidents match your search or filters.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),

                  itemCount: results.length,

                  itemBuilder: (context, index) {
                    final incident = results[index];

                    return IncidentCard(incident: incident);
                  },
                ),
        ),
      ],
    );
  }
}

// RECENT INCIDENTS PREVIEW FOR STUDENT DASHBOARD
class RecentIncidentsPreview extends ConsumerWidget {
  const RecentIncidentsPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(campusIncidentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const Text(
              'Recent Campus Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            TextButton(
              onPressed: () {
                context.go('/student/feed');
              },
              child: const Text('See all'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        incidentsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),

          error: (error, stackTrace) => const Text(
            'Unable to load recent incidents.',
            style: TextStyle(color: Colors.white70),
          ),

          data: (incidents) {
            if (incidents.isEmpty) {
              return const EmptyIncidentsWidget(
                message: 'No incidents have been reported yet.',
              );
            }

            final recentIncidents = incidents.take(3).toList();

            return Column(
              children: recentIncidents.map((incident) {
                return IncidentCard(incident: incident);
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
