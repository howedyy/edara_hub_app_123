import 'package:dio/dio.dart';
import 'package:edara_hub_app_123/core/errors/app_exception.dart';
import 'package:edara_hub_app_123/core/resources/constants_manager.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginResponse.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterResponse.dart';
import 'package:edara_hub_app_123/features/auth/data/models/UserStatusResponse.dart';
import 'package:injectable/injectable.dart';
@Singleton(as: AuthRemoteDataSource)
class AuthApiRemoteDataSource implements AuthRemoteDataSource {
  Dio dio = Dio(BaseOptions(baseUrl: ApiConstant.baseUrl));

  @override
  Future<RegisterResponse> register(RegisterRequest request) async  {
    try{
      final response =
      await dio.post(ApiConstant.registerEndPoint, data: request.toJson());
      return RegisterResponse.fromJson(response.data);
    }catch(exception){


      String? message;
      if(exception is DioException){
      if (exception.response?.data is Map && exception.response?.data['message'] != null) {
        message = exception.response?.data['message'];
      }
      }
      throw RemoteException(message: message?? "Failed To Register");
    }
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      print('Attempting login to: ${ApiConstant.baseUrl}${ApiConstant.loginEndPoint}');
      final response = await dio.post(ApiConstant.loginEndPoint, data: request.toJson());
      print('Login response received: ${response.statusCode}');
      return LoginResponse.fromJson(response.data);
    } catch (exception) {
      print('Login error: $exception');
      String? message;
      if (exception is DioException) {
        print('DioException type: ${exception.type}');
        print('DioException message: ${exception.message}');
        print('DioException response: ${exception.response?.data}');
        
        if (exception.type == DioExceptionType.connectionTimeout) {
          message = "Connection timeout. Please check your internet or server status.";
        } else if (exception.type == DioExceptionType.connectionError) {
          message = "Connection error. If you are using an emulator, ensure the server is reachable.";
        } else if (exception.response?.data != null) {
          final data = exception.response?.data;
          if (data is Map && data['message'] != null) {
            message = data['message'];
          }
        }
      }
      throw RemoteException(message: message ?? "Failed To Login: ${exception.toString()}");
    }
  }
  
  @override
  Future<UserStatusResponse> checkUserStatus(String phone) async {
    try {
      // Call the /api/v1/me endpoint to get user status
      // This requires authentication, so we need to ensure the user has a valid token
      print('Checking user status for phone: $phone');
      final response = await dio.get(ApiConstant.meEndPoint);
      print('User status response received: ${response.statusCode}');
      return UserStatusResponse.fromJson(response.data);
    } catch (exception) {
      print('Check user status error: $exception');
      String? message;
      if (exception is DioException) {
        print('DioException type: ${exception.type}');
        print('DioException response: ${exception.response?.data}');
        
        if (exception.response?.data != null) {
          final data = exception.response?.data;
          if (data is Map && data['message'] != null) {
            message = data['message'];
          }
        }
      }
      throw RemoteException(message: message ?? "Failed to check user status: ${exception.toString()}");
    }
  }
  
}
