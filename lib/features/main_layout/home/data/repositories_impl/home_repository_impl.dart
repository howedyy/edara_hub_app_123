import 'package:dartz/dartz.dart';
import 'package:edara_hub_app_123/core/errors/app_exception.dart';
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/features/main_layout/home/data/data_sources/home_remote_data_source.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/repositories/home_repository.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<EventEntity>>> getEvents({required int page, required int perPage, required int categoryId}) async {
    try {
      final response = await remoteDataSource.getEvents(page: page, perPage: perPage, categoryId: categoryId);
      if (response.data != null && response.data!.events != null) {
        final entities = response.data!.events.map((e) => e.toEntity()).toList();
        return Right(entities);
      } else {
        return Right([]); 
      }
    } on AppException catch (exception) {
      return Left(Failure(message: exception.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
