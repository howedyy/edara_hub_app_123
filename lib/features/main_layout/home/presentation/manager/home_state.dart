part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<EventEntity> events;
  HomeSuccess(this.events);
}

class HomeFailure extends HomeState {
  final String message;
  HomeFailure(this.message);
}
