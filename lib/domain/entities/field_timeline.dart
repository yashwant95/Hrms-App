import 'package:equatable/equatable.dart';

class BreadcrumbPoint extends Equatable {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? address;
  final String? activityType;
  final double? speed;

  const BreadcrumbPoint({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.address,
    this.activityType,
    this.speed,
  });

  factory BreadcrumbPoint.fromJson(Map<String, dynamic> json) {
    return BreadcrumbPoint(
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'],
      activityType: json['activityType'] ?? 'IN_TRANSIT',
      speed: (json['speed'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [timestamp, latitude, longitude, address, activityType];
}

class TimelineStop extends Equatable {
  final String id;
  final String name;
  final String type; // 'SHIFT_START', 'CLIENT_VISIT', 'SITE_INSPECTION', 'BREAK', 'SHIFT_END'
  final String? clientName;
  final String? contactPerson;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final int durationMinutes;
  final double distanceCoveredKm;
  final String? notes;
  final bool verifiedWithGps;

  const TimelineStop({
    required this.id,
    required this.name,
    required this.type,
    this.clientName,
    this.contactPerson,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.arrivalTime,
    this.departureTime,
    this.durationMinutes = 0,
    this.distanceCoveredKm = 0.0,
    this.notes,
    this.verifiedWithGps = true,
  });

  factory TimelineStop.fromJson(Map<String, dynamic> json) {
    return TimelineStop(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Stop',
      type: json['type'] ?? 'CLIENT_VISIT',
      clientName: json['clientName'],
      contactPerson: json['contactPerson'],
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      arrivalTime: json['arrivalTime'] != null ? DateTime.parse(json['arrivalTime']).toLocal() : DateTime.now(),
      departureTime: json['departureTime'] != null ? DateTime.parse(json['departureTime']).toLocal() : null,
      durationMinutes: json['durationMinutes'] ?? 0,
      distanceCoveredKm: (json['distanceCoveredKm'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      verifiedWithGps: json['verifiedWithGps'] ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, type, address, arrivalTime, departureTime, durationMinutes];
}

class FieldTimeline extends Equatable {
  final String id;
  final DateTime date;
  final DateTime? startTime;
  final DateTime? endTime;
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final String status;
  final List<BreadcrumbPoint> breadcrumbs;
  final List<TimelineStop> stops;

  const FieldTimeline({
    required this.id,
    required this.date,
    this.startTime,
    this.endTime,
    this.totalDistanceKm = 0.0,
    this.totalDurationMinutes = 0,
    this.status = 'COMPLETED',
    this.breadcrumbs = const [],
    this.stops = const [],
  });

  factory FieldTimeline.fromJson(Map<String, dynamic> json) {
    final stopsList = (json['stops'] as List<dynamic>?)
            ?.map((s) => TimelineStop.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    final breadcrumbsList = (json['breadcrumbs'] as List<dynamic>?)
            ?.map((b) => BreadcrumbPoint.fromJson(b as Map<String, dynamic>))
            .toList() ??
        [];

    return FieldTimeline(
      id: json['_id'] ?? json['id'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']).toLocal() : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']).toLocal() : null,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      totalDurationMinutes: json['totalDurationMinutes'] ?? 0,
      status: json['status'] ?? 'COMPLETED',
      breadcrumbs: breadcrumbsList,
      stops: stopsList,
    );
  }

  @override
  List<Object?> get props => [id, date, totalDistanceKm, totalDurationMinutes, status, stops];
}
