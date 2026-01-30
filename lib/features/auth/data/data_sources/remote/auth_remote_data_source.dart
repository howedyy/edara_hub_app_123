import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginResponse.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterResponse.dart';
import 'package:edara_hub_app_123/features/auth/data/models/UserStatusResponse.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponse> register(RegisterRequest request);
  Future<LoginResponse> login(LoginRequest request);
  
  /// Checks user status from backend API to verify admin approval
  Future<UserStatusResponse> checkUserStatus(String phone);
}