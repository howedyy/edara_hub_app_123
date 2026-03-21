import 'package:edara_hub_app_123/features/auth/data/models/login_request.dart';
import 'package:edara_hub_app_123/features/auth/data/models/login_response.dart';
import 'package:edara_hub_app_123/features/auth/data/models/register_request.dart';
import 'package:edara_hub_app_123/features/auth/data/models/register_response.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponse> register(RegisterRequest request);
  Future<LoginResponse> login(LoginRequest request);


}