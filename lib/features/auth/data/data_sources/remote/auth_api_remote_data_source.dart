import 'package:dio/dio.dart';
import 'package:edara_hub_app_123/core/errors/app_exception.dart';
import 'package:edara_hub_app_123/core/resources/constants_manager.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/models/login_request.dart';
import 'package:edara_hub_app_123/features/auth/data/models/login_response.dart';
import 'package:edara_hub_app_123/features/auth/data/models/register_request.dart';
import 'package:edara_hub_app_123/features/auth/data/models/register_response.dart';

class AuthApiRemoteDataSource implements AuthRemoteDataSource {
  final Dio dio;

  AuthApiRemoteDataSource({required this.dio});

  @override
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response =
          await dio.post(ApiConstant.registerEndPoint, data: request.toJson());
      if (response.data == null) {
        throw const RemoteException(message: "Empty response from server");
      }
      return RegisterResponse.fromJson(response.data);
    } catch (exception) {
      if (exception is AppException) rethrow;

      String message = "Failed To Register";
      if (exception is DioException) {
        message = _handleDioError(exception);
      }
      throw RemoteException(message: message);
    }
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response =
          await dio.post(ApiConstant.loginEndPoint, data: request.toJson());
      if (response.data == null) {
        throw const RemoteException(message: "Empty response from server");
      }
      return LoginResponse.fromJson(response.data);
    } catch (exception) {
      if (exception is AppException) rethrow;

      String message = "Failed To Login";
      if (exception is DioException) {
        message = _handleDioError(exception);
      }
      throw RemoteException(message: message);
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timeout with API server";
      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        }
        return "Received invalid status code: ${error.response?.statusCode}";
      case DioExceptionType.cancel:
        return "Request to API server was cancelled";
      case DioExceptionType.connectionError:
        return "No internet connection";
      default:
        return "Something went wrong";
    }
  }
  
}