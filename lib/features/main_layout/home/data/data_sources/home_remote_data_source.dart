import 'package:edara_hub_app_123/features/main_layout/home/data/models/EventsResponse.dart';

abstract class HomeRemoteDataSource {
  Future<EventsResponse> getEvents({required int page, required int perPage, required int categoryId});
}
