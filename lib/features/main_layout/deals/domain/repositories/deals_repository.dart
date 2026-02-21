import 'package:edara_hub_app_123/features/main_layout/deals/domain/entities/deal_entity.dart';

abstract class DealsRepository {
  Stream<List<DealEntity>> getDeals(String userId);
  Future<void> toggleWishlist(String dealId, String userId, bool isAdding);
}
