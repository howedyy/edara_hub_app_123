import 'package:edara_hub_app_123/core/errors/app_exception.dart';
import 'package:edara_hub_app_123/core/resources/constants_manager.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSecureLocalDataSource implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  AuthSecureLocalDataSource({required this.secureStorage});

  @override
  Future<void> saveToken(String token) async {
    try {
      await secureStorage.write(key: CacheConstant.tokenKey, value: token);
    } catch (exception) {
      throw const LocalException(message: "Failed to save secure token");
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await secureStorage.read(key: CacheConstant.tokenKey);
    } catch (exception) {
      throw const LocalException(message: "Failed to read secure token");
    }
  }
}
