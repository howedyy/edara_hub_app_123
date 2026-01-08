import 'package:edara_hub_app/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:edara_hub_app/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app/features/auth/data/models/LoginResponse.dart';
import 'package:edara_hub_app/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app/features/auth/data/models/RegisterResponse.dart';
import 'package:edara_hub_app/features/auth/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRemoteDataSource authApiRemoteDataSource;
  AuthRepositoryImpl({required this.authApiRemoteDataSource});

  @override
  Future<RegisterResponse> register(RegisterRequest request) {
   return authApiRemoteDataSource.register(request);
  }

  @override
  Future<LoginResponse> login(LoginRequest request) {
    return authApiRemoteDataSource.login(request);
  }
  
}