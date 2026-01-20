import 'package:dio/dio.dart';
import 'package:edara_hub_app_123/core/errors/app_exception.dart';
import 'package:edara_hub_app_123/core/resources/constants_manager.dart';
import 'package:edara_hub_app_123/features/main_layout/home/data/data_sources/home_remote_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/local/auth_local_data_source.dart';
import 'package:edara_hub_app_123/features/main_layout/home/data/models/EventsResponse.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: HomeRemoteDataSource)
class HomeApiRemoteDataSource implements HomeRemoteDataSource {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstant.baseUrl));
  final AuthLocalDataSource authLocalDataSource;

  HomeApiRemoteDataSource(this.authLocalDataSource);

  @override
  Future<EventsResponse> getEvents({required int page, required int perPage, required int categoryId}) async {
    try {
      final token = await authLocalDataSource.getToken();
      final response = await dio.get(
        ApiConstant.eventsEndPoint,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          'category_id': categoryId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return EventsResponse.fromJson(response.data);
    } catch (exception) {
      String? message;
      if (exception is DioException) {
        if (exception.type == DioExceptionType.connectionTimeout) {
          message = "Connection timeout. Please check your internet or server status.";
        } else if (exception.type == DioExceptionType.connectionError) {
          message = "Connection error. Ensure the server is reachable.";
        } else if (exception.response?.data != null) {
          final data = exception.response?.data;
          if (data is Map && data['message'] != null) {
            message = data['message'];
          }
        }
      }
      throw RemoteException(message: message ?? "Failed To Fetch Events");
    }
  }
}
