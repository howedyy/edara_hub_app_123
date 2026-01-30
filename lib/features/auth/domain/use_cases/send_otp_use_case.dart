import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class SendOTPUseCase {
  Future<Either<Failure, String>> call(String phoneNumber);
}
