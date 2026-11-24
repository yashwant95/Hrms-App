import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../widgets/glass_card.dart';
import '../../config/app_language.dart';
import 'providers/announcement_provider.dart';

class AnnouncementScreen extends ConsumerWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(appText(context, 'Company updates', 'कंपनी की सूचनाएँ')),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.announcements.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.announcements.length,
              itemBuilder: (context, index) {
                final item = state.announcements[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(
                                  item.priority,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _getPriorityIcon(item.priority),
                                    size: 14,
                                    color: _getPriorityColor(item.priority),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _priorityText(context, item.priority),
                                    style: TextStyle(
                                      color: _getPriorityColor(item.priority),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM d, h:mm a',
                              ).format(item.createdAt.toLocal()),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.content,
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/illustrations/empty_announcements.svg',
            width: 160,
            height: 124,
            semanticsLabel: appText(
              context,
              'No announcements illustration',
              'सूचना उपलब्ध नहीं है',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            appText(context, 'No announcements yet', 'अभी कोई सूचना नहीं है'),
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _priorityText(BuildContext context, String priority) {
    switch (priority) {
      case 'CRITICAL':
        return appText(context, 'Urgent', 'ज़रूरी');
      case 'WARNING':
        return appText(context, 'Warning', 'चेतावनी');
      default:
        return appText(context, 'Information', 'जानकारी');
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'CRITICAL':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      case 'INFO':
      default:
        return Colors.blue;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'CRITICAL':
        return Icons.error_outline;
      case 'WARNING':
        return Icons.warning_amber;
      case 'INFO':
      default:
        return Icons.info_outline;
    }
  }
}
