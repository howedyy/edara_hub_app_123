import 'package:dio/dio.dart';
import 'package:edara_hub_app/core/resources/constants_manager.dart';
import 'package:edara_hub_app/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:edara_hub_app/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app/features/auth/data/models/LoginResponse.dart';
import 'package:edara_hub_app/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app/features/auth/data/models/RegisterResponse.dart';

class AuthApiRemoteDataSource implements AuthRemoteDataSource {
  Dio dio = Dio(BaseOptions(baseUrl: ApiConstant.baseUrl));

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await dio.post(ApiConstant.registerEndPoint, data: request.toJson());
    return RegisterResponse.fromJson(response.data);
  }

  @override
  Future<LoginResponse> login(LoginRequest request)async {
   final response = await dio.post(ApiConstant.loginEndPoint, data: request.toJson());
   return LoginResponse.fromJson(response.data);
  }
  
}