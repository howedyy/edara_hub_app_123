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
import 'package:edara_hub_app_123/features/auth/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRemoteDataSource remoteDataSource;
  AuthLocalDataSource localDataSource;
  AuthRepositoryImpl({required this.remoteDataSource,
    required this.localDataSource}
      );

  @override
  Future<Either<Failure, Data>> register(RegisterRequest request) async{
    try{
      final response = await remoteDataSource.register(request);
      await localDataSource.saveToken(response.data!.token);
      return Right(response.data!);
    }on AppException catch(exception){
      return Left(Failure(message: exception.message));
    }
  }

  @override
  Future<Either<Failure, Data>> login(LoginRequest request)async {
   try {
      final response = await remoteDataSource.login(request);
      await localDataSource.getToken(response.data!.token);
      return Right(response.data);
    }on AppException catch(exception){
     return Left(Failure(message: exception.message));
   }
  }
  
}


