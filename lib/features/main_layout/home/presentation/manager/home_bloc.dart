import 'package:bloc/bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/use_cases/get_events_use_case.dart';
import 'package:injectable/injectable.dart';

part 'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetEventsUseCase getEventsUseCase;

  HomeBloc(this.getEventsUseCase) : super(HomeInitial()) {
    on<GetEventsEvent>((event, emit) async {
      emit(HomeLoading());
      final result = await getEventsUseCase.call(
        page: event.page,
        perPage: event.perPage,
        categoryId: event.categoryId,
      );
      result.fold(
        (failure) => emit(HomeFailure(failure.message)),
        (events) => emit(HomeSuccess(events)),
      );
    });
  }
}
