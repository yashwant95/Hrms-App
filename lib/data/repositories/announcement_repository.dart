import 'package:dartz/dartz.dart';
import '../../domain/entities/announcement.dart';
import '../datasources/announcement_remote_data_source.dart';

class AnnouncementRepository {
  final AnnouncementRemoteDataSource _dataSource;

  AnnouncementRepository(this._dataSource);

  Future<Either<String, List<Announcement>>> getAnnouncements() async {
    try {
      final data = await _dataSource.getAnnouncements();
      final items = data.map((e) => Announcement.fromJson(e)).toList();
      return Right(items);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
