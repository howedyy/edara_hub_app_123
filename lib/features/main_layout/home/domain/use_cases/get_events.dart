import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/repositories/home_repository.dart';

class GetEventsUseCase {
  final HomeRepository repository;

  GetEventsUseCase(this.repository);

  Stream<List<EventEntity>> call(String userId) {
    return repository.getEvents(userId);
  }
}
