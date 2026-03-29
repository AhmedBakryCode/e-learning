import 'package:e_learning/features/comments/domain/entities/course_comment.dart';

abstract class CommentsRepository {
  Future<List<CourseComment>> getComments({
    required String courseId,
    String? videoId,
  });

  Future<CourseComment> addComment({
    required String courseId,
    required String videoId,
    required String authorName,
    required String courseTitle,
    required String message,
  });
}
