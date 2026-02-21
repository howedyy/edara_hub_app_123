import 'package:equatable/equatable.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/use_cases/get_events.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/use_cases/add_comment.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/use_cases/toggle_wishlist.dart';
import 'dart:async';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetEventsUseCase getEventsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final ToggleWishlistUseCase toggleWishlistUseCase;
  StreamSubscription? _eventsSubscription;

  HomeBloc({
    required this.getEventsUseCase,
    required this.addCommentUseCase,
    required this.toggleWishlistUseCase,
  }) : super(HomeInitial()) {
    on<LoadEvents>((event, emit) {
      emit(HomeLoading());
      _eventsSubscription?.cancel();
      _eventsSubscription = getEventsUseCase(event.userId).listen(
        (events) => add(UpdateEvents(events)),
        onError: (error) => emit(HomeError(error.toString())),
      );
    });

    on<UpdateEvents>((event, emit) {
      emit(HomeLoaded(event.events));
    });

    on<AddComment>((event, emit) async {
      try {
        await addCommentUseCase(event.eventId, event.comment);
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });

    on<ToggleWishlist>((event, emit) async {
      try {
        await toggleWishlistUseCase(event.eventId, event.userId, event.isAdding);
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _eventsSubscription?.cancel();
    return super.close();
  }
}
