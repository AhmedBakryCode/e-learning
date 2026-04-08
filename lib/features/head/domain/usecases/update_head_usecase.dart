import 'dart:io';
import 'package:e_learning/features/head/domain/repositories/head_repository.dart';

class UpdateHeadUseCase {
  final HeadRepository repository;

  UpdateHeadUseCase(this.repository);

  Future<void> call({
    required String id,
    required String title,
    required String name,
    File? image,
  }) async {
    return await repository.updateHead(id: id, title: title, name: name, image: image);
  }
}
