import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app_123/features/auth/domain/repositories/auth_repository.dart';

import 'package:edara_hub_app_123/features/auth/domain/use_cases/login_use_case.dart';
import 'package:edara_hub_app_123/features/auth/domain/use_cases/register_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
@singleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.registerUseCase, required this.loginUseCase}):super(InitialState());

RegisterUseCase registerUseCase;
LoginUseCase loginUseCase;


  void register(RegisterRequest request) async {

      emit(RegisterLoading());
      var result = await  registerUseCase(request);
      result.fold((failure){
       emit(RegisterError(message: failure.message));
      }, (user){
        emit(RegisterSuccess());
      });
  }

  void login(LoginRequest request)async{

      emit(LoginLoading());
    final result = await loginUseCase(request);
    result.fold((failure){
      emit(LoginError(message: failure.message));
    }, (user){
      emit(LoginSuccess());
    });
    }


}


abstract class AuthState{}

class InitialState extends AuthState {}

class RegisterLoading extends AuthState {}

class RegisterError extends AuthState {
  String message;
  RegisterError({required this.message});
}

class RegisterSuccess extends AuthState{

}

class LoginLoading extends AuthState{}

class LoginError extends AuthState {
  String message;
  LoginError({required this.message});
}

class LoginSuccess extends AuthState{}