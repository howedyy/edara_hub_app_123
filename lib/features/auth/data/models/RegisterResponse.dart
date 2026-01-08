import 'Data.dart';

class RegisterResponse {
  const RegisterResponse({
    required  this.success,
     required this.message,
     required this.data,});

  factory RegisterResponse.fromJson(dynamic json) {
    return RegisterResponse(success: json['success'],
        message: json['message'],
        data: Data.fromJson(json['data'])
    );

  }
  final bool success;
  final String message;
  final Data data;



}