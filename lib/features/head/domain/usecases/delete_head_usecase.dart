import 'package:e_learning/features/head/domain/repositories/head_repository.dart';

class DeleteHeadUseCase {
  final HeadRepository repository;

  DeleteHeadUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteHead(id);
  }
}
