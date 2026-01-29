import 'package:dartz/dartz.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<String, Map<String, dynamic>>> login(String email, String password) async {
    try {
      final result = await _dataSource.login(email, password);
      return Right(result);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> registerTenant(String companyName, String email, String password) async {
    try {
      final result = await _dataSource.registerTenant(companyName, email, password);
      return Right(result);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
