import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../domain/entities/field_timeline.dart';
import '../../../widgets/glass_card.dart';

class TimelineStopItem extends StatelessWidget {
  final TimelineStop stop;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onCheckout;

  const TimelineStopItem({
    super.key,
    required this.stop,
    this.isFirst = false,
    this.isLast = false,
    this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final arrivalStr = DateFormat('hh:mm a').format(stop.arrivalTime);
    final departureStr = stop.departureTime != null ? DateFormat('hh:mm a').format(stop.departureTime!) : 'Present';
    final isOngoing = stop.departureTime == null && stop.type != 'SHIFT_START' && stop.type != 'SHIFT_END';

    final Color badgeColor = _getBadgeColor(stop.type);
    final IconData badgeIcon = _getBadgeIcon(stop.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Timeline Indicator Column
          SizedBox(
            width: 48,
            child: Column(
              children: [
                // Upper Line
                Container(
                  width: 2.5,
                  height: isFirst ? 8 : 16,
                  color: isFirst ? Colors.transparent : Colors.grey[300],
                ),

                // Stop Circle Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: badgeColor, width: 2),
                  ),
                  child: Icon(badgeIcon, size: 16, color: badgeColor),
                ),

                // Lower Line
                Expanded(
                  child: Container(
                    width: 2.5,
                    color: isLast ? Colors.transparent : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),

          // Right Stop Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Range & Duration Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded, size: 13, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              isOngoing ? '$arrivalStr (Ongoing)' : '$arrivalStr - $departureStr',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isOngoing ? AppTheme.primary : Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        if (stop.durationMinutes > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Stayed ${_formatDuration(stop.durationMinutes)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Stop Title / Client Name
                    Text(
                      stop.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    // Address with Location Icon
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2, right: 4),
                          child: Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                        ),
                        Expanded(
                          child: Text(
                            stop.address,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),

                    // Contact Person (if any)
                    if (stop.contactPerson != null && stop.contactPerson!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 12, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              stop.contactPerson!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Notes (if any)
                    if (stop.notes != null && stop.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!, width: 0.8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes_rounded, size: 13, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                stop.notes!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Distance Covered & GPS Verified Footer
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (stop.distanceCoveredKm > 0)
                          Row(
                            children: [
                              Icon(Icons.directions_car_rounded, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 4),
                              Text(
                                '${stop.distanceCoveredKm.toStringAsFixed(1)} km from prev stop',
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          )
                        else
                          const SizedBox.shrink(),

                        if (stop.verifiedWithGps)
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 12, color: AppTheme.success),
                              const SizedBox(width: 4),
                              const Text(
                                'GPS Logged',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.success,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    // If visit is currently active, show Checkout button
                    if (isOngoing) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton.icon(
                          onPressed: onCheckout,
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Complete Visit & Depart', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor(String type) {
    switch (type) {
      case 'SHIFT_START':
        return AppTheme.success;
      case 'CLIENT_VISIT':
        return AppTheme.primary;
      case 'SITE_INSPECTION':
        return Colors.indigo;
      case 'BREAK':
        return Colors.amber[800]!;
      case 'SHIFT_END':
        return AppTheme.danger;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getBadgeIcon(String type) {
    switch (type) {
      case 'SHIFT_START':
        return Icons.play_arrow_rounded;
      case 'CLIENT_VISIT':
        return Icons.storefront_rounded;
      case 'SITE_INSPECTION':
        return Icons.construction_rounded;
      case 'BREAK':
        return Icons.coffee_rounded;
      case 'SHIFT_END':
        return Icons.stop_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '${hrs}h';
    return '${hrs}h ${mins}m';
  }
}
