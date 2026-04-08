import 'dart:io';
import 'package:e_learning/features/head/domain/repositories/head_repository.dart';

class CreateHeadUseCase {
  final HeadRepository repository;

  CreateHeadUseCase(this.repository);

  Future<void> call({
    required String title,
    required String name,
    required File image,
  }) async {
    return await repository.createHead(title: title, name: name, image: image);
  }
}
