import 'package:edara_hub_app_123/features/main_layout/deals/domain/repositories/deals_repository.dart';

class ToggleDealWishlistUseCase {
  final DealsRepository repository;

  ToggleDealWishlistUseCase(this.repository);

  Future<void> call(String dealId, String userId, bool isAdding) {
    return repository.toggleWishlist(dealId, userId, isAdding);
  }
}
