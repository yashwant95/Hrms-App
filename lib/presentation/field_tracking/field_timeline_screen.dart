import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/app_language.dart';
import 'providers/field_tracking_provider.dart';
import 'widgets/timeline_route_map_card.dart';
import 'widgets/timeline_stop_item.dart';
import 'widgets/log_client_visit_sheet.dart';

class FieldTimelineScreen extends ConsumerWidget {
  const FieldTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fieldTrackingProvider);
    final notifier = ref.read(fieldTrackingProvider.notifier);
    final timeline = state.timeline;
    final stops = timeline?.stops ?? [];

    final dateFormatted = DateFormat(
      'EEE, MMM d, yyyy',
    ).format(state.selectedDate);
    final isToday = _isSameDay(state.selectedDate, DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              appText(context, 'Field work', 'बाहर का काम'),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              dateFormatted,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 90)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                notifier.selectDate(picked);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => notifier.fetchTimeline(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => LogClientVisitSheet(
              onLog:
                  ({
                    required String clientName,
                    required String address,
                    String? contactPerson,
                    String? notes,
                  }) {
                    notifier.logClientVisit(
                      clientName: clientName,
                      address: address,
                      contactPerson: contactPerson,
                      notes: notes,
                    );
                  },
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        icon: const Icon(
          Icons.add_location_alt_rounded,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          appText(context, 'Log a client visit', 'क्लाइंट से मुलाक़ात जोड़ें'),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => notifier.fetchTimeline(),
              color: AppTheme.primary,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // 1. Date Selector Quick Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => notifier.selectDate(
                              state.selectedDate.subtract(
                                const Duration(days: 1),
                              ),
                            ),
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              size: 18,
                            ),
                            label: Text(
                              appText(context, 'Previous day', 'पिछला दिन'),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppTheme.primary.withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isToday
                                  ? appText(context, 'Today', 'आज')
                                  : dateFormatted,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? AppTheme.primary
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: isToday
                                ? null
                                : () => notifier.selectDate(
                                    state.selectedDate.add(
                                      const Duration(days: 1),
                                    ),
                                  ),
                            label: Text(
                              appText(context, 'Next day', 'अगला दिन'),
                              style: const TextStyle(fontSize: 14),
                            ),
                            icon: const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. Interactive Route Map Card
                  SliverToBoxAdapter(
                    child: TimelineRouteMapCard(timeline: timeline),
                  ),

                  // 3. Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timeline_rounded,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                appText(
                                  context,
                                  'VISITS TODAY (${stops.length})',
                                  'आज की मुलाक़ातें (${stops.length})',
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          if (timeline?.totalDistanceKm != null &&
                              timeline!.totalDistanceKm > 0)
                            Text(
                              appText(
                                context,
                                '${timeline.totalDistanceKm.toStringAsFixed(1)} km total',
                                'कुल ${timeline.totalDistanceKm.toStringAsFixed(1)} किमी',
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Stops Timeline List or Empty State
                  if (stops.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.map_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                appText(
                                  context,
                                  'No field work for this day',
                                  'इस दिन बाहर का काम दर्ज नहीं है',
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                appText(
                                  context,
                                  'Your route and client visits will appear here after you check in or add a visit.',
                                  'हाज़िरी लगाने या मुलाक़ात जोड़ने के बाद रास्ता और क्लाइंट की जानकारी यहाँ दिखेगी।',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final stop = stops[index];
                        final isFirst = index == 0;
                        final isLast = index == stops.length - 1;

                        return TimelineStopItem(
                          stop: stop,
                          isFirst: isFirst,
                          isLast: isLast,
                          onCheckout: () =>
                              notifier.checkoutClientVisit(stop.id),
                        );
                      }, childCount: stops.length),
                    ),

                  // FAB clearance
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
