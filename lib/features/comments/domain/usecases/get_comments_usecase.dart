import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/comments/domain/entities/course_comment.dart';
import 'package:e_learning/features/comments/domain/repositories/comments_repository.dart';
import 'package:equatable/equatable.dart';

class GetCommentsParams extends Equatable {
  const GetCommentsParams({required this.courseId, this.videoId});

  final String courseId;
  final String? videoId;

  @override
  List<Object?> get props => [courseId, videoId];
}

class GetCommentsUseCase
    implements UseCase<List<CourseComment>, GetCommentsParams> {
  const GetCommentsUseCase(this._repository);

  final CommentsRepository _repository;

  @override
  Future<List<CourseComment>> call(GetCommentsParams params) {
    return _repository.getComments(
      courseId: params.courseId,
      videoId: params.videoId,
    );
  }
}
