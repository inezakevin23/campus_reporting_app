import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/phase_one/phase_one_screens.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboardScreen(),
      ),

      GoRoute(
        path: '/student/report',
        builder: (context, state) => const CreateIncidentScreen(),
      ),

      GoRoute(
        path: '/student/reports',
        builder: (context, state) => const MyReportsScreen(),
      ),

      GoRoute(
        path: '/student/incident/:id',
        builder: (context, state) {
          return IncidentDetailsScreen(incidentId: state.pathParameters['id']!);
        },
      ),

      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffDashboardScreen(),
      ),

      GoRoute(
        path: '/staff/incident/:id',
        builder: (context, state) {
          return IncidentDetailsScreen(
            incidentId: state.pathParameters['id']!,
            isStaff: true,
          );
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);

  return router;
});
