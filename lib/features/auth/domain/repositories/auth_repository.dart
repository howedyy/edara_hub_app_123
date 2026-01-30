import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/features/auth/data/models/Data.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginResponse.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterResponse.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/data_entity.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
 Future<Either<Failure, DataEntity>> register(RegisterRequest request);
 Future<Either<Failure,DataEntity>> login(LoginRequest request);
  
  // Phone OTP Authentication methods
  Future<Either<Failure, String>> sendOTP(String phoneNumber);
  Future<Either<Failure, DataEntity>> verifyOTP(String verificationId, String otpCode);
  Future<Either<Failure, bool>> checkUserApproval(String phoneNumber);
}