import 'package:edara_hub_app/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app/features/auth/data/models/LoginResponse.dart';
import 'package:edara_hub_app/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app/features/auth/data/models/RegisterResponse.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponse> register(RegisterRequest request);
  Future<LoginResponse> login(LoginRequest request);


}