import 'package:edara_hub_app_123/features/auth/domain/entities/user_entity.dart';

class DataEntity{
  UserEntity userEntity;
  String token;
  DataEntity({required this.userEntity,required this.token});
}