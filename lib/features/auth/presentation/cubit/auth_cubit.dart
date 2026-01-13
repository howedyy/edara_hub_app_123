import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app_123/features/auth/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
@singleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository}):super(InitialState());

AuthRepository authRepository;
  void register(RegisterRequest request) async {

      emit(RegisterLoading());
      var result = await  authRepository.register(request);
      result.fold((failure){
       emit(RegisterError(message: failure.message));
      }, (user){
        emit(RegisterSuccess());
      });
  }

  void login(LoginRequest request)async{

      emit(LoginLoading());
    var result =   await authRepository.login(request);
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