import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_language.dart';
import '../../config/theme.dart';
import '../attendance/providers/attendance_provider.dart';
import '../auth/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    if (user?['role'] == 'SUPER_ADMIN') {
      return Scaffold(
        appBar: AppBar(title: const Text('Platform workspace')),
        body: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Platform administration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tenant creation, administrator setup and subscription plans are managed in the web platform console.',
                    style: TextStyle(color: Colors.white, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Card(
              child: ListTile(
                leading: Icon(Icons.apartment_rounded),
                title: Text('Tenant workspaces'),
                subtitle: Text(
                  'Create organizations and issue their first Org Admin invite.',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.layers_rounded),
                title: Text('Subscription plans'),
                subtitle: Text(
                  'Set chat, attendance and other modules per plan.',
                ),
              ),
            ),
          ],
        ),
      );
    }
    final attendance = ref.watch(attendanceProvider);
    final notifier = ref.read(attendanceProvider.notifier);
    final record = attendance.todayStatus?['attendance'];
    final checkedIn = record != null;
    final checkedOut = checkedIn && record['checkOut'] != null;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? appText(context, 'Good morning', 'सुप्रभात')
        : hour < 17
        ? appText(context, 'Good afternoon', 'नमस्कार')
        : appText(context, 'Good evening', 'शुभ संध्या');
    final date = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              appText(
                context,
                'Your workday at a glance',
                'आज के काम की जानकारी',
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: appText(context, 'Announcements', 'सूचनाएँ'),
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/announcements'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.getTodayStatus,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (auth.modules.contains('attendance') && (auth.permissions.contains('ATTENDANCE_PUNCH') || auth.permissions.contains('ATTENDANCE_VIEW_SELF') || auth.permissions.contains('ATTENDANCE_VIEW_ALL'))) _AttendanceCard(
              isLoading: attendance.isLoading,
              checkedIn: checkedIn,
              checkedOut: checkedOut,
              checkInTime: checkedIn ? _formatTime(record['checkIn']) : null,
              onTap: () => context.push('/attendance'),
            ),
            if (auth.modules.contains('attendance') && attendance.error != null) ...[
              const SizedBox(height: 10),
              Text(
                appText(
                  context,
                  'Could not refresh attendance. Pull down to try again.',
                  'हाज़िरी की जानकारी नहीं मिली। फिर से देखने के लिए नीचे खींचें।',
                ),
                style: const TextStyle(color: AppTheme.danger, fontSize: 14),
              ),
            ],
            const SizedBox(height: 22),
            Text(
              appText(context, 'Quick actions', 'ज़रूरी काम'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.62,
              children: [
                if (auth.modules.contains('leaves') && auth.permissions.contains('LEAVE_APPLY')) _ActionCard(
                  icon: Icons.event_available_outlined,
                  title: appText(
                    context,
                    'Apply for leave',
                    'छुट्टी के लिए आवेदन',
                  ),
                  subtitle: appText(
                    context,
                    'Choose dates and reason',
                    'तारीख़ और कारण चुनें',
                  ),
                  color: const Color(0xFF9A5B00),
                  onTap: () => context.push('/leave'),
                ),
                if (auth.modules.contains('payroll') && auth.permissions.contains('PAYROLL_VIEW_SELF')) _ActionCard(
                  icon: Icons.payments_outlined,
                  title: appText(context, 'My payslips', 'मेरी वेतन पर्ची'),
                  subtitle: appText(
                    context,
                    'View monthly salary',
                    'महीने की तनख़्वाह देखें',
                  ),
                  color: AppTheme.primary,
                  onTap: () => context.push('/payroll'),
                ),
                if (auth.modules.contains('tasks')) _ActionCard(
                  icon: Icons.checklist_rounded,
                  title: appText(context, 'My tasks', 'मेरे काम'),
                  subtitle: appText(
                    context,
                    'See what is pending',
                    'बाक़ी काम देखें',
                  ),
                  color: AppTheme.secondary,
                  onTap: () => context.push('/tasks'),
                ),
                if (auth.modules.contains('core_hr')) _ActionCard(
                  icon: Icons.campaign_outlined,
                  title: appText(context, 'Updates', 'कंपनी की सूचना'),
                  subtitle: appText(
                    context,
                    'News from your company',
                    'कंपनी की ताज़ा ख़बरें',
                  ),
                  color: const Color(0xFF6554A4),
                  onTap: () => context.push('/announcements'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (auth.modules.contains('attendance') && auth.permissions.contains('ATTENDANCE_PUNCH')) _HelpfulCard(onTap: () => context.push('/attendance')),
          ],
        ),
      ),
    );
  }

  static String _formatTime(dynamic value) {
    try {
      return DateFormat(
        'h:mm a',
      ).format(DateTime.parse(value.toString()).toLocal());
    } catch (_) {
      return '—';
    }
  }
}

class _AttendanceCard extends StatelessWidget {
  final bool isLoading;
  final bool checkedIn;
  final bool checkedOut;
  final String? checkInTime;
  final VoidCallback onTap;

  const _AttendanceCard({
    required this.isLoading,
    required this.checkedIn,
    required this.checkedOut,
    required this.checkInTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = checkedOut
        ? appText(context, 'Day completed', 'आज की हाज़िरी पूरी हुई')
        : checkedIn
        ? appText(context, 'You are checked in', 'आपकी हाज़िरी लग गई है')
        : appText(
            context,
            'You have not checked in yet',
            'आज की हाज़िरी अभी नहीं लगी',
          );
    final action = checkedOut
        ? appText(context, 'View attendance', 'हाज़िरी देखें')
        : checkedIn
        ? appText(context, 'Check out', 'हाज़िरी समाप्त करें')
        : appText(context, 'Mark attendance', 'हाज़िरी लगाएँ');

    return Material(
      color: const Color(0xFFE7F3F2),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.fingerprint_rounded,
                          color: AppTheme.primary,
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appText(
                              context,
                              'Today’s attendance',
                              'आज की हाज़िरी',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    if (checkInTime != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${appText(context, 'Check-in time', 'हाज़िरी का समय')}: $checkInTime',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.touch_app_rounded, size: 21),
                      label: Text(action),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 82,
                height: 100,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SvgPicture.asset(
                        'assets/illustrations/attendance.svg',
                        semanticsLabel: appText(
                          context,
                          'Attendance calendar illustration',
                          'हाज़िरी कैलेंडर का चित्र',
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE1E8EC)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontSize: 12,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpfulCard extends StatelessWidget {
  final VoidCallback onTap;
  const _HelpfulCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE1E8EC)),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/attendance_welcome.png',
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appText(
                        context,
                        'Need help with attendance?',
                        'हाज़िरी में मदद चाहिए?',
                      ),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      appText(
                        context,
                        'See your check-in time and location.',
                        'हाज़िरी का समय और जगह देखें।',
                      ),
                      style: TextStyle(
                        color: Colors.blueGrey[700],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 28,
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
