import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<String, Map<String, dynamic>>> login(String email, String password);
  Future<Either<String, Map<String, dynamic>>> registerTenant(String companyName, String email, String password);
}
