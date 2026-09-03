import 'data.dart';

class RegisterResponse {
  const RegisterResponse({
    required  this.success,
     required this.message,
     this.data,});

  factory RegisterResponse.fromJson(dynamic json) {
    return RegisterResponse(success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null ? Data.fromJson(json['data']) : null,

    );

  }
  final bool success;
  final String message;
  final Data? data;



}