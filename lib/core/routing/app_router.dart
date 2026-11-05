import 'dart:async';

import 'package:campus_reporting_app/features/incidents/screens/incident_details_screen.dart';
import 'package:campus_reporting_app/features/incidents/screens/incident_feed_screen.dart' as incident_feed;
import 'package:campus_reporting_app/features/incidents/screens/report_incident_screen.dart';
import 'package:campus_reporting_app/features/staff/screens/staff_dashboard.dart';
import 'package:campus_reporting_app/features/student/screens/my_report.dart';
import 'package:campus_reporting_app/features/student/screens/student_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final refreshListenable = GoRouterRefreshStream(auth.authStateChanges());

  final router = GoRouter(
    initialLocation: '/login',

    refreshListenable: refreshListenable,

    redirect: (context, state) async {
      final user = auth.currentUser;
      final location = state.matchedLocation;

      final isAuthPage = location == '/login' || location == '/register';

      // 1. User is not logged in.
      if (user == null) {
        return isAuthPage ? null : '/login';
      }

      // 2. An authenticated user with a broken
      // or missing profile needs attention.
      if (location == '/account-error') {
        return null;
      }

      // 3. Retrieve the user's role from Firestore.
      final userDocument = await firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDocument.exists) {
        return '/account-error';
      }

      final role = userDocument.data()?['role'];

      if (role != 'student' && role != 'staff') {
        return '/account-error';
      }

      // 4. Redirect from login/register to
      // the appropriate dashboard.
      if (isAuthPage || location == '/') {
        return role == 'staff' ? '/staff' : '/student';
      }

      // 5. Students cannot access staff pages.
      if (role == 'student' && location.startsWith('/staff')) {
        return '/student';
      }

      // 6. Staff cannot access student pages.
      if (role == 'staff' && location.startsWith('/student')) {
        return '/staff';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/login'),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(
        path: '/account-error',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Your account profile is missing or invalid. '
                'Please contact the campus administrator.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
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
        path: '/student/feed',
        builder: (context, state) => const incident_feed.IncidentFeedScreen(),
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

  ref.onDispose(() {
    refreshListenable.dispose();
    router.dispose();
  });

  return router;
});
