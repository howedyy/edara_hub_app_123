import 'package:edara_hub_app_123/core/errors/app_exception.dart';
import 'package:edara_hub_app_123/core/resources/constants_manager.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
@Singleton(as: AuthLocalDataSource)
class AuthSharedPrefsLocalDataSource implements AuthLocalDataSource{

  @override
  Future<void> saveToken(String token)async {
    try{
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      sharedPref.setString(CashConstant.tokenKey, token);
    }catch(exception){
      throw LocalException(message: "SomeThingWentWrong");
    }
  }



  @override
  Future<String> getToken() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      String? token = sharedPref.getString(CashConstant.tokenKey);
      if (token != null) {
        return token;
      }
      throw const LocalException(message: "Token Not Found");
    } catch (exception) {
      if (exception is LocalException) rethrow;
      throw const LocalException(message: "Failed to get local data");
    }
  }



}