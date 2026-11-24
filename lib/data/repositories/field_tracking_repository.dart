import 'package:dartz/dartz.dart';
import '../../domain/entities/field_timeline.dart';
import '../datasources/field_tracking_remote_data_source.dart';

class FieldTrackingRepository {
  final FieldTrackingRemoteDataSource _dataSource;

  FieldTrackingRepository(this._dataSource);

  Future<Either<String, FieldTimeline>> getDayTimeline({String? date, String? userId}) async {
    try {
      final data = await _dataSource.getDayTimeline(date: date, userId: userId);
      return Right(FieldTimeline.fromJson(data));
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Either<String, TimelineStop>> logClientVisit(Map<String, dynamic> data) async {
    try {
      final res = await _dataSource.logClientVisit(data);
      return Right(TimelineStop.fromJson(res['stop']));
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Either<String, TimelineStop>> checkoutClientVisit(String visitId, {String? notes}) async {
    try {
      final res = await _dataSource.checkoutClientVisit(visitId, notes: notes);
      return Right(TimelineStop.fromJson(res['stop']));
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<Either<String, void>> recordBreadcrumb(Map<String, dynamic> data) async {
    try {
      await _dataSource.recordBreadcrumb(data);
      return const Right(null);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
