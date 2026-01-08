import 'package:edara_hub_app/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.authRepository}):super(InitialState());

AuthRepository authRepository;
  void register(RegisterRequest request) async {
    try{
      emit(RegisterLoading());
      var response = await authRepository.register(request);
      emit(RegisterSuccess());
    }catch(exception){
      emit(RegisterError(message: exception.toString()));
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