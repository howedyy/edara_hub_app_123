import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';

abstract class HomeRepository {
  Stream<List<EventEntity>> getEvents(String userId);
  Future<void> addComment(String eventId, String comment);
  Future<void> toggleWishlist(String eventId, String userId, bool isAdding);
}
