part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEvents extends HomeEvent {
  final String userId;
  LoadEvents(this.userId);
  @override
  List<Object?> get props => [userId];
}

class UpdateEvents extends HomeEvent {
  final List<EventEntity> events;
  UpdateEvents(this.events);
  @override
  List<Object?> get props => [events];
}

class AddComment extends HomeEvent {
  final String eventId;
  final String comment;
  AddComment(this.eventId, this.comment);
  @override
  List<Object?> get props => [eventId, comment];
}

class ToggleWishlist extends HomeEvent {
  final String eventId;
  final String userId;
  final bool isAdding;
  ToggleWishlist(this.eventId, this.userId, this.isAdding);
  @override
  List<Object?> get props => [eventId, userId, isAdding];
}
