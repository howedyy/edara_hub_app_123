import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/data_entity.dart';
import 'package:edara_hub_app_123/features/auth/domain/repositories/auth_repository.dart';

import 'package:injectable/injectable.dart';

@singleton
class LoginUseCase{
  AuthRepository authRepository;
  LoginUseCase({required this.authRepository});

  Future<Either<Failure, DataEntity>>call(LoginRequest request){
  return authRepository.login(request);


  }



}


