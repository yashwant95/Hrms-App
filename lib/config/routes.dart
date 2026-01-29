import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/splash/splash_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/attendance/attendance_screen.dart';
import '../presentation/leave/leave_screen.dart';
import '../presentation/payroll/payroll_screen.dart';
import '../presentation/team/team_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/main_wrapper.dart';
import '../presentation/tasks/tasks_screen.dart';
import '../presentation/announcements/announcement_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    // Sub-screens that should sit ON TOP of tabs (Back button enabled)
    GoRoute(
      path: '/team',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TeamScreen(),
    ),
    GoRoute(
      path: '/leave',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LeaveScreen(),
    ),
    GoRoute(
      path: '/announcements',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AnnouncementScreen(),
    ),
    GoRoute(
      path: '/tasks',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TasksScreen(),
    ),
    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/attendance',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AttendanceScreen(),
    ),
    GoRoute(
      path: '/payroll',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PayrollScreen(),
    ),
  ],
);
