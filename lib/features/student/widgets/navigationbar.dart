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
            break;
          case 1:
            context.go('/student/reports');
            break;
          case 2:
            context.go('/student/feed');
            break;
          case 3:
            context.go('/student/report');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          label: 'Reports',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          label: 'Feed',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          label: 'Report',
        ),
      ],
    );
  }
}
