import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_language.dart';
import '../../config/theme.dart';
import 'providers/attendance_provider.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceProvider);
    final notifier = ref.read(attendanceProvider.notifier);
    final record = state.todayStatus?['attendance'];
    final isCheckedIn = record != null;
    final isCheckedOut = isCheckedIn && record['checkOut'] != null;
    final checkIn = isCheckedIn ? _formatTime(record['checkIn']) : '—';
    final checkOut = isCheckedOut ? _formatTime(record['checkOut']) : '—';
    final buttonLabel = isCheckedOut
        ? appText(context, 'Attendance complete', 'आज की हाज़िरी पूरी हुई')
        : isCheckedIn
        ? appText(context, 'Check out', 'हाज़िरी समाप्त करें')
        : appText(context, 'Check in now', 'अभी हाज़िरी लगाएँ');

    return Scaffold(
      appBar: AppBar(
        title: Text(appText(context, 'Attendance', 'हाज़िरी')),
        actions: [
          IconButton(
            tooltip: appText(context, 'View field work', 'बाहर के काम देखें'),
            icon: const Icon(Icons.route_outlined),
            onPressed: () => context.push('/field-timeline'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.getTodayStatus,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
          children: [
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: TextStyle(
                color: Colors.blueGrey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE1E8EC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F3F2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.primary,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appText(context, 'Work location', 'काम की जगह'),
                              style: TextStyle(
                                color: Colors.blueGrey[700],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              appText(
                                context,
                                'GPS location will be checked',
                                'GPS से जगह की जाँच होगी',
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 130,
                      color: const Color(0xFFE9F0F2),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.map_outlined,
                            size: 58,
                            color: Color(0xFF78909C),
                          ),
                          Positioned(
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                appText(
                                  context,
                                  'Location is used to verify your check-in',
                                  'हाज़िरी की जगह जाँचने के लिए लोकेशन उपयोग होगी',
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE1E8EC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DateFormat('h:mm').format(DateTime.now()),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('a').format(DateTime.now()),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: state.isLoading || isCheckedOut
                        ? null
                        : () async {
                            if (isCheckedIn) {
                              await notifier.checkOut();
                            } else {
                              await notifier.checkIn();
                            }
                            if (context.mounted) {
                              final updated = ref.read(attendanceProvider);
                              if (updated.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(updated.error!)),
                                );
                              }
                            }
                          },
                    icon: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isCheckedOut
                                ? Icons.check_circle_outline
                                : isCheckedIn
                                ? Icons.logout_rounded
                                : Icons.fingerprint_rounded,
                            size: 24,
                          ),
                    label: Text(buttonLabel),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      appText(
                        context,
                        'We could not update attendance. Please try again.',
                        'हाज़िरी अपडेट नहीं हो सकी। कृपया फिर कोशिश करें।',
                      ),
                      style: const TextStyle(color: AppTheme.danger),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeTile(
                          label: appText(context, 'Checked in', 'हाज़िरी लगी'),
                          time: checkIn,
                          icon: Icons.login_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TimeTile(
                          label: appText(
                            context,
                            'Checked out',
                            'हाज़िरी समाप्त',
                          ),
                          time: checkOut,
                          icon: Icons.logout_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => context.push('/field-timeline'),
              icon: const Icon(Icons.route_outlined),
              label: Text(
                appText(
                  context,
                  'View my field work',
                  'बाहर के काम की जानकारी',
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
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

class _TimeTile extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  const _TimeTile({
    required this.label,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 21),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.blueGrey[700], fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
        ],
      ),
    );
  }
}
