part of 'deals_bloc.dart';

abstract class DealsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DealsInitial extends DealsState {}

class DealsLoading extends DealsState {}

class DealsLoaded extends DealsState {
  final List<DealEntity> deals;
  
  DealsLoaded(this.deals);
  
  @override
  List<Object?> get props => [deals];
}

class DealsError extends DealsState {
  final String message;
  
  DealsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
