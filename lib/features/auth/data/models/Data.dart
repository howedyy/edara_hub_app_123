import 'package:edara_hub_app_123/features/auth/domain/entities/data_entity.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/user_entity.dart';

import 'User.dart';

class Data {
  const Data({
    required this.user, required this.token});

  factory Data.fromJson(dynamic json) {
    return Data(user: User.fromJson(json['user']), token: json['token']);
  }

  final User user;
  final String token;


DataEntity toDataEntity()=> DataEntity(userEntity: user.toUserEntity(), token: token);

}