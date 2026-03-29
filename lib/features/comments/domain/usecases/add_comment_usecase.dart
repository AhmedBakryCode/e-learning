import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/comments/domain/entities/course_comment.dart';
import 'package:e_learning/features/comments/domain/repositories/comments_repository.dart';
import 'package:equatable/equatable.dart';

class AddCommentParams extends Equatable {
  const AddCommentParams({
    required this.courseId,
    required this.videoId,
    required this.authorName,
    required this.courseTitle,
    required this.message,
  });

  final String courseId;
  final String videoId;
  final String authorName;
  final String courseTitle;
  final String message;

  @override
  List<Object?> get props => [
    courseId,
    videoId,
    authorName,
    courseTitle,
    message,
  ];
}

class AddCommentUseCase implements UseCase<CourseComment, AddCommentParams> {
  const AddCommentUseCase(this._repository);

  final CommentsRepository _repository;

  @override
  Future<CourseComment> call(AddCommentParams params) {
    return _repository.addComment(
      courseId: params.courseId,
      videoId: params.videoId,
      authorName: params.authorName,
      courseTitle: params.courseTitle,
      message: params.message,
    );
  }
}
