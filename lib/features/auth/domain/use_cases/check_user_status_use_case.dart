import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';

abstract class CheckUserStatusUseCase {
  Future<Either<Failure, bool>> call(String phoneNumber);
}
