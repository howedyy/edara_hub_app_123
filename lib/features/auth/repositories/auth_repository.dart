import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/features/auth/data/models/data.dart';
import 'package:edara_hub_app_123/features/auth/data/models/login_request.dart';
import 'package:edara_hub_app_123/features/auth/data/models/login_response.dart';
import 'package:edara_hub_app_123/features/auth/data/models/register_request.dart';
import 'package:edara_hub_app_123/features/auth/data/models/register_response.dart';

abstract class AuthRepository {
 Future<Either<Failure, Data>> register(RegisterRequest request);
 Future<Either<Failure,Data>> login(LoginRequest request);

}