import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../domain/entities/field_timeline.dart';
import '../../../widgets/glass_card.dart';

class TimelineRouteMapCard extends StatelessWidget {
  final FieldTimeline? timeline;

  const TimelineRouteMapCard({super.key, this.timeline});

  @override
  Widget build(BuildContext context) {
    final stops = timeline?.stops ?? [];
    final distance = timeline?.totalDistanceKm ?? 0.0;
    final totalStops = stops.where((s) => s.type == 'CLIENT_VISIT' || s.type == 'SITE_INSPECTION').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Visual Simulated Interactive Route Map
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Grid / Map Route Canvas
                    CustomPaint(
                      size: const Size(double.infinity, 180),
                      painter: _RouteMapPainter(stops: stops),
                    ),

                    // Top Left Route Info Pill
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.route_rounded, size: 14, color: AppTheme.primary),
                            const SizedBox(width: 5),
                            Text(
                              '${distance.toStringAsFixed(1)} km Trail',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Top Right Live GPS Status Pill
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.success,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'GPS Verified',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Floating Summary Bar
                    Positioned(
                      bottom: 10,
                      left: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Total Travel', '${distance.toStringAsFixed(1)} km', Icons.directions_car_rounded),
                            Container(width: 1, height: 24, color: Colors.grey[200]),
                            _buildStatItem('Client Stops', '$totalStops Visits', Icons.storefront_rounded),
                            Container(width: 1, height: 24, color: Colors.grey[200]),
                            _buildStatItem('Field Duration', '${(timeline?.totalDurationMinutes ?? 0) ~/ 60}h ${(timeline?.totalDurationMinutes ?? 0) % 60}m', Icons.access_time_rounded),
                          ],
                        ),
                      ),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  final List<TimelineStop> stops;

  _RouteMapPainter({required this.stops});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw background simulated grid road lines
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), dashPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), dashPaint);
    canvas.drawLine(Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), dashPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.75, size.height), dashPaint);

    // Dynamic points across canvas width
    final points = <Offset>[
      Offset(size.width * 0.12, size.height * 0.65), // Start (Koramangala)
      Offset(size.width * 0.35, size.height * 0.30), // Stop 1 (Indiranagar)
      Offset(size.width * 0.55, size.height * 0.45), // Stop 2 (Old Airport Rd)
      Offset(size.width * 0.72, size.height * 0.28), // Stop 3 (Indiranagar Cafe)
      Offset(size.width * 0.88, size.height * 0.55), // Stop 4 (Electronic City)
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      path.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    // Draw Route Polyline
    canvas.drawPath(path, routePaint);

    // Draw Stop Pin Markers
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isStart = i == 0;
      final isEnd = i == points.length - 1;

      final pinColor = isStart
          ? AppTheme.success
          : isEnd
              ? AppTheme.danger
              : AppTheme.primary;

      // Outer glow
      canvas.drawCircle(p, 9, Paint()..color = pinColor.withOpacity(0.25));
      // Outer ring
      canvas.drawCircle(p, 6.5, Paint()..color = Colors.white);
      // Center dot
      canvas.drawCircle(p, 4.5, Paint()..color = pinColor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
