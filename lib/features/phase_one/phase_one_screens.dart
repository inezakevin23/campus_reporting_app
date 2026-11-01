import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

// --------------------------------------------------
// LOGIN SCREEN
// --------------------------------------------------

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 64,
                  color: AppTheme.yellow,
                ),

                const SizedBox(height: 16),

                const Text(
                  'CampusAlert',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const Text(
                  'Report. Track. Resolve.',
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 40),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sign in to your account',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 16),

                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email / Student ID',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),

                const SizedBox(height: 24),

                // Temporary navigation for UI testing.
                // Real Firebase login comes in Phase 2.
                FilledButton(
                  onPressed: () => context.go('/student'),
                  child: const Text('Preview Student Dashboard'),
                ),

                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () => context.go('/staff'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Preview Staff Dashboard'),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// REGISTRATION SCREEN
// --------------------------------------------------

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Join CampusAlert',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          const Text(
            'Create an account to report campus issues.',
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 24),

          const TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),

          const SizedBox(height: 16),

          const TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),

          const SizedBox(height: 16),

          const TextField(
            decoration: InputDecoration(
              labelText: 'Student ID',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),

          const SizedBox(height: 16),

          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Registration will be connected to Firebase in Phase 2.',
                  ),
                ),
              );
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// STUDENT DASHBOARD
// --------------------------------------------------

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusAlert'),
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

// --------------------------------------------------
// CREATE INCIDENT SCREEN
// --------------------------------------------------

class CreateIncidentScreen extends StatefulWidget {
  const CreateIncidentScreen({super.key});

  @override
  State<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final _formKey = GlobalKey<FormState>();

  String _category = 'Facilities';
  String _priority = 'Medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Select a category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items:
                  [
                    'Facilities',
                    'Water',
                    'Electricity',
                    'Safety',
                    'Sanitation',
                    'Furniture',
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),

            const SizedBox(height: 20),

            const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Briefly describe the issue',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Provide more details about the issue',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const TextField(
              decoration: InputDecoration(
                hintText: 'e.g. Block A - Room 204',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Priority Level',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ['Low', 'Medium', 'High'].map((priority) {
                return DropdownMenuItem(value: priority, child: Text(priority));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: AppTheme.yellow,
                  ),
                  SizedBox(height: 8),
                  Text('Add a photograph (optional)'),
                  Text(
                    'Photo selection and upload will be connected later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Form validated. Firebase submission comes later.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// MY REPORTS SCREEN
// --------------------------------------------------

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search reports...',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 20),

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
            title: 'Overflowing bin',
            location: 'Cafeteria',
            status: 'Resolved',
            onTap: () => context.go('/student/incident/INC-003'),
          ),
        ],
      ),

      bottomNavigationBar: const StudentNavigationBar(selectedIndex: 1),
    );
  }
}

// --------------------------------------------------
// INCIDENT DETAILS SCREEN
// --------------------------------------------------

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

// --------------------------------------------------
// STAFF DASHBOARD
// --------------------------------------------------

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
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

// --------------------------------------------------
// REUSABLE WIDGETS
// --------------------------------------------------

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

class StudentNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const StudentNavigationBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,

      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/student');
          case 1:
            context.go('/student/reports');
          case 2:
            context.go('/student/report');
        }
      },

      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          label: 'Report',
        ),
      ],
    );
  }
}
