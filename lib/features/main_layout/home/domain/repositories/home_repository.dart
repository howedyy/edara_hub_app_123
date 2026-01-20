import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<EventEntity>>> getEvents({required int page, required int perPage, required int categoryId});
}
