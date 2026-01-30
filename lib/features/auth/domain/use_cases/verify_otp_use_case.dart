import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/data_entity.dart';

abstract class VerifyOTPUseCase {
  Future<Either<Failure, DataEntity>> call(String verificationId, String otpCode);
}
