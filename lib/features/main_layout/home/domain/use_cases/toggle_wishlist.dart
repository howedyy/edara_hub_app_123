import 'package:edara_hub_app_123/features/main_layout/home/domain/repositories/home_repository.dart';

class ToggleWishlistUseCase {
  final HomeRepository repository;

  ToggleWishlistUseCase(this.repository);

  Future<void> call(String eventId, String userId, bool isAdding) async {
    return await repository.toggleWishlist(eventId, userId, isAdding);
  }
}
