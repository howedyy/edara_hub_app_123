import 'package:edara_hub_app_123/features/main_layout/home/domain/repositories/home_repository.dart';

class AddCommentUseCase {
  final HomeRepository repository;

  AddCommentUseCase(this.repository);

  Future<void> call(String eventId, String comment) async {
    return await repository.addComment(eventId, comment);
  }
}
