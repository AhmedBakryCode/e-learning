import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:e_learning/features/progress/domain/repositories/progress_repository.dart';
import 'package:equatable/equatable.dart';

class GetProgressParams extends Equatable {
  const GetProgressParams({this.studentId});

  final String? studentId;

  @override
  List<Object?> get props => [studentId];
}

class GetProgressUseCase
    implements UseCase<List<LearningProgress>, GetProgressParams> {
  const GetProgressUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<List<LearningProgress>> call(GetProgressParams params) {
    return _repository.getProgressItems(studentId: params.studentId);
  }
}
