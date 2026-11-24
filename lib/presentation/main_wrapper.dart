import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_language.dart';
import '../config/theme.dart';
import 'auth/providers/auth_provider.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  static const _destinations = [
    (Icons.home_outlined, Icons.home_rounded, 'Home', 'à¤¹à¥‹à¤®'),
    (Icons.chat_bubble_outline, Icons.chat_bubble, 'Chat', 'à¤šà¥ˆà¤Ÿ'),
    (
      Icons.fingerprint_outlined,
      Icons.fingerprint_rounded,
      'Attendance',
      'à¤¹à¤¾à¤œà¤¼à¤¿à¤°à¥€',
    ),
    (
      Icons.event_available_outlined,
      Icons.event_available_rounded,
      'Leave',
      'à¤›à¥à¤Ÿà¥à¤Ÿà¥€',
    ),
    (
      Icons.grid_view_outlined,
      Icons.grid_view_rounded,
      'More',
      'à¤”à¤° à¤¸à¥‡à¤µà¤¾à¤à¤',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final visibleBranches = <int>[0];
    if (auth.modules.contains('chat') && auth.permissions.contains('CHAT_VIEW'))
      visibleBranches.add(1);
    if (auth.modules.contains('attendance') &&
        (auth.permissions.contains('ATTENDANCE_PUNCH') ||
            auth.permissions.contains('ATTENDANCE_VIEW_SELF') ||
            auth.permissions.contains('ATTENDANCE_VIEW_ALL')))
      visibleBranches.add(2);
    if (auth.modules.contains('leaves') &&
        (auth.permissions.contains('LEAVE_APPLY') ||
            auth.permissions.contains('LEAVE_VIEW_SELF') ||
            auth.permissions.contains('LEAVE_VIEW_ALL')))
      visibleBranches.add(3);
    visibleBranches.add(4);
    final selected = visibleBranches.indexOf(navigationShell.currentIndex);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        onDestinationSelected: (index) => navigationShell.goBranch(
          visibleBranches[index],
          initialLocation:
              visibleBranches[index] == navigationShell.currentIndex,
        ),
        destinations: [
          for (final index in visibleBranches)
            NavigationDestination(
              icon: Icon(_destinations[index].$1, size: 25),
              selectedIcon: Icon(
                _destinations[index].$2,
                size: 26,
                color: AppTheme.primary,
              ),
              label: appText(
                context,
                _destinations[index].$3,
                _destinations[index].$4,
              ),
            ),
        ],
      ),
    );
  }
}
