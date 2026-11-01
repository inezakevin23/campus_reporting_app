import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
