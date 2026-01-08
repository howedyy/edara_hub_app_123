import 'Data.dart';

class LoginResponse {
 const LoginResponse({
   required   this.success,
    required  this.message,
     required this.data,});

  factory LoginResponse.fromJson(dynamic json) {
    return LoginResponse(success: json['success'],
        message: json['message'],
        data: Data.fromJson(json['data'])
    );

  }
  final bool success;
 final String message;
 final Data data;



}