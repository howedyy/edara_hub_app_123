import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/data_entity.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/user_entity.dart';
import 'package:edara_hub_app_123/features/auth/domain/repositories/auth_repository.dart';

import 'package:injectable/injectable.dart';

@singleton
class RegisterUseCase{

AuthRepository authRepository;
RegisterUseCase({required this.authRepository});
Future<Either<Failure, DataEntity>>call(RegisterRequest request){
  return authRepository.register(request);
  }
}