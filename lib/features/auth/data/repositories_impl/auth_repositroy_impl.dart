import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/app_exception.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/models/Data.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginResponse.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterResponse.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/data_entity.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/user_entity.dart';
import 'package:edara_hub_app_123/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
@Singleton(as : AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRemoteDataSource remoteDataSource;
  AuthLocalDataSource localDataSource;
  AuthRepositoryImpl({required this.remoteDataSource,
    required this.localDataSource}
      );

  @override
  Future<Either<Failure, DataEntity>> register(RegisterRequest request) async{
    try{
      final response = await remoteDataSource.register(request);
      await localDataSource.saveToken(response.data!.token);
      return Right(response.data!.toDataEntity());
    }on AppException catch(exception){
      return Left(Failure(message: exception.message));
    }
  }

  @override
  Future<Either<Failure, DataEntity>> login(LoginRequest request)async {
   try {
      final response = await remoteDataSource.login(request);
      await localDataSource.saveToken(response.data!.token);
      return Right(response.data.toDataEntity());
    }on AppException catch(exception){
     return Left(Failure(message: exception.message));  
   }
  }

  @override
  Future<Either<Failure, bool>> checkUserApproval(String phoneNumber) {
    // TODO: implement checkUserApproval
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> sendOTP(String phoneNumber) {
    // TODO: implement sendOTP
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, DataEntity>> verifyOTP(String verificationId, String otpCode) {
    // TODO: implement verifyOTP
    throw UnimplementedError();
  }
  
}


