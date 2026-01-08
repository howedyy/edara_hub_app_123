import 'User.dart';

class Data {
  const Data({
     required this.user,});

  factory Data.fromJson(dynamic json) {
    return Data(user: User.fromJson(json['user']));
  }
  final User user;



}