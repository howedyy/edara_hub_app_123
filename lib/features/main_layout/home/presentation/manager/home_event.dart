part of 'home_bloc.dart';

abstract class HomeEvent {}

class GetEventsEvent extends HomeEvent {
  final int page;
  final int perPage;
  final int categoryId;

  GetEventsEvent({this.page = 1, this.perPage = 10, this.categoryId = 1});
}
