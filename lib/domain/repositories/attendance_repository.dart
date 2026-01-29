import 'package:dartz/dartz.dart';

abstract class AttendanceRepository {
  Future<Either<String, Map<String, dynamic>>> checkIn(double lat, double long, String address);
  Future<Either<String, Map<String, dynamic>>> checkOut();
  Future<Either<String, Map<String, dynamic>>> getTodayStatus();
}
