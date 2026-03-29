import 'package:e_learning/features/comments/data/datasources/comments_data_source.dart';
import 'package:e_learning/features/comments/domain/entities/course_comment.dart';
import 'package:e_learning/features/comments/domain/repositories/comments_repository.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  const CommentsRepositoryImpl({required CommentsDataSource dataSource})
    : _dataSource = dataSource;

  final CommentsDataSource _dataSource;

  @override
  Future<List<CourseComment>> getComments({
    required String courseId,
    String? videoId,
  }) {
    return _dataSource.getComments(courseId: courseId, videoId: videoId);
  }

  @override
  Future<CourseComment> addComment({
    required String courseId,
    required String videoId,
    required String authorName,
    required String courseTitle,
    required String message,
  }) {
    return _dataSource.addComment(
      courseId: courseId,
      videoId: videoId,
      authorName: authorName,
      courseTitle: courseTitle,
      message: message,
    );
  }
}
