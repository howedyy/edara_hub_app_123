import 'package:edara_hub_app_123/features/main_layout/deals/data/data_sources/deals_remote_data_source.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/entities/deal_entity.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/repositories/deals_repository.dart';

class DealsRepositoryImpl implements DealsRepository {
  final DealsRemoteDataSource remoteDataSource;

  DealsRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<DealEntity>> getDeals(String userId) {
    return remoteDataSource.getDeals(userId);
  }

  @override
  Future<void> toggleWishlist(String dealId, String userId, bool isAdding) {
    return remoteDataSource.toggleWishlist(dealId, userId, isAdding);
  }
}
