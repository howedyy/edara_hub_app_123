import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app_123/core/resources/constants_manager.dart';
import 'package:edara_hub_app_123/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edara_hub_app_123/features/auth/domain/use_cases/login_use_case.dart';
import 'package:edara_hub_app_123/features/auth/domain/use_cases/register_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.registerUseCase, required this.loginUseCase})
      : super(InitialState());

  RegisterUseCase registerUseCase;
  LoginUseCase loginUseCase;

  void register(RegisterRequest request) async {
    emit(RegisterLoading());
    var result = await registerUseCase(request);
    result.fold((failure) {
      emit(RegisterError(message: failure.message));
    }, (user) {
      // Registration successful but pending approval
      emit(RegisterPendingApproval(
        message: 'Registration successful! Your account is pending admin approval. '
            'You will be notified once your account is approved.',
      ));
    });
  }

  void login(LoginRequest request) async {
    emit(LoginLoading());
    final result = await loginUseCase(request);
    result.fold((failure) {
      // Check if it's an approval pending error
      if (failure.message.contains('pending approval')) {
        emit(LoginPendingApproval(message: failure.message));
      } else {
        emit(LoginError(message: failure.message));
      }
    }, (dataEntity) async {
      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(CashConstant.tokenKey, dataEntity.token);
      emit(LoginSuccess());
    });
  }
}

abstract class AuthState {}

class InitialState extends AuthState {}

class RegisterLoading extends AuthState {}

class RegisterError extends AuthState {
  String message;
  RegisterError({required this.message});
}

class RegisterSuccess extends AuthState {}

/// New state for registration pending approval
class RegisterPendingApproval extends AuthState {
  String message;
  RegisterPendingApproval({required this.message});
}

class LoginLoading extends AuthState {}

class LoginError extends AuthState {
  String message;
  LoginError({required this.message});
}

/// New state for login when account is pending approval
class LoginPendingApproval extends AuthState {
  String message;
  LoginPendingApproval({required this.message});
}

class LoginSuccess extends AuthState {}