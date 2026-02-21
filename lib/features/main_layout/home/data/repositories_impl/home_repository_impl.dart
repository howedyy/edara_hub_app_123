import 'package:edara_hub_app_123/features/main_layout/home/data/data_sources/home_remote_data_source.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<EventEntity>> getEvents(String userId) {
    return remoteDataSource.getEvents(userId);
  }

  @override
  Future<void> addComment(String eventId, String comment) {
    return remoteDataSource.addComment(eventId, comment);
  }

  @override
  Future<void> toggleWishlist(String eventId, String userId, bool isAdding) {
    return remoteDataSource.toggleWishlist(eventId, userId, isAdding);
  }
}
