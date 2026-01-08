import 'package:edara_hub_app/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dio/dio.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository}):super(InitialState());

AuthRepository authRepository;
  void register(RegisterRequest request) async {
    try{
      emit(RegisterLoading());
      await authRepository.register(request);
      emit(RegisterSuccess());
    }catch(exception){
      String errorMessage = "An error occurred";
      if (exception is DioException && exception.response != null) {
        var data = exception.response?.data;
        if (data is Map && data.containsKey('errors')) {
          var errors = data['errors'] as Map;
          errorMessage = errors.values.map((e) => (e as List).join(', ')).join('\n');
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
      } else {
        errorMessage = exception.toString();
      }
      emit(RegisterError(message: errorMessage));
    }
  }

  void login(LoginRequest request)async{
   try {
      emit(LoginLoading());
      await authRepository.login(request);
      emit(LoginSuccess());
    }catch(exception){
     emit(LoginError(message: exception.toString()));
   }
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