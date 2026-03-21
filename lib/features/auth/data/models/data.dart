import 'user.dart';

class Data {
  const Data({
     required this.user,required this.token});

  factory Data.fromJson(dynamic json) {
    return Data(user: User.fromJson(json['user']),token: json['token']);
  }
  final User user;
  final String token;



}