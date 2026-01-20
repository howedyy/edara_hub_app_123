import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/repositories/home_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetEventsUseCase {
  final HomeRepository repository;

  GetEventsUseCase(this.repository);

  Future<Either<Failure, List<EventEntity>>> call({required int page, required int perPage, required int categoryId}) {
    return repository.getEvents(page: page, perPage: perPage, categoryId: categoryId);
  }
}
