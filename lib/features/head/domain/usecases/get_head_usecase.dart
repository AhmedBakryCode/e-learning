import 'package:e_learning/features/head/domain/entities/head.dart';
import 'package:e_learning/features/head/domain/repositories/head_repository.dart';

class GetHeadUseCase {
  final HeadRepository repository;

  GetHeadUseCase(this.repository);

  Future<List<Head>> call() async {
    return await repository.getHeads();
  }
}
