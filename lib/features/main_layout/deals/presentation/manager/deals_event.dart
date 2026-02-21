part of 'deals_bloc.dart';

abstract class DealsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDeals extends DealsEvent {
  final String userId;
  LoadDeals(this.userId);
  @override
  List<Object?> get props => [userId];
}

class UpdateDeals extends DealsEvent {
  final List<DealEntity> deals;
  UpdateDeals(this.deals);
  @override
  List<Object?> get props => [deals];
}

class ToggleDealWishlist extends DealsEvent {
  final String dealId;
  final String userId;
  final bool isAdding;
  
  ToggleDealWishlist(this.dealId, this.userId, this.isAdding);
  
  @override
  List<Object?> get props => [dealId, userId, isAdding];
}
