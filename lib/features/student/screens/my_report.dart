import 'package:campus_reporting_app/features/incidents/providers/incident_provider.dart';
import 'package:campus_reporting_app/features/incidents/widgets/incident_widget.dart';
import 'package:campus_reporting_app/features/student/widgets/navigationbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(
        title: const Text('My Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/student');
            }
          },
        ),
      ),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
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
              ],
            ),
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'You have not submitted any reports yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final incident = reports[index];

              return IncidentCard(
                incident: incident,
                isStaff: false,
              );
            },
          );
        },
      ),
      bottomNavigationBar: const StudentNavigationBar(selectedIndex: 1),
    );
  }
}
