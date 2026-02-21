import 'package:edara_hub_app_123/features/main_layout/deals/domain/entities/deal_entity.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/repositories/deals_repository.dart';

class GetDealsUseCase {
  final DealsRepository repository;

  GetDealsUseCase(this.repository);

  Stream<List<DealEntity>> call(String userId) {
    return repository.getDeals(userId);
  }
}
