import 'package:dartz/dartz.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource _dataSource;

  AttendanceRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, Map<String, dynamic>>> checkIn(double lat, double long, String address) async {
    try {
      final result = await _dataSource.checkIn(lat, long, address);
      return Right(result);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> checkOut() async {
    try {
      final result = await _dataSource.checkOut();
      return Right(result);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> getTodayStatus() async {
    try {
      final result = await _dataSource.getTodayStatus();
      return Right(result);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
