import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/features/comments/data/models/course_comment_model.dart';

abstract class CommentsDataSource {
  Future<List<CourseCommentModel>> getComments({
    required String courseId,
    String? videoId,
  });

  Future<CourseCommentModel> addComment({
    required String courseId,
    required String videoId,
    required String authorName,
    required String courseTitle,
    required String message,
  });
}

class MockCommentsDataSource implements CommentsDataSource {
  const MockCommentsDataSource();

  @override
  Future<List<CourseCommentModel>> getComments({
    required String courseId,
    String? videoId,
  }) async {
    await Future<void>.delayed(AppDurations.short);

    return _comments.where((comment) {
      if (comment.courseId != courseId) {
        return false;
      }

      if (videoId != null && comment.videoId != videoId) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<CourseCommentModel> addComment({
    required String courseId,
    required String videoId,
    required String authorName,
    required String courseTitle,
    required String message,
  }) async {
    await Future<void>.delayed(AppDurations.short);

    final now = DateTime.now();
    final comment = CourseCommentModel(
      id: 'comment-${now.microsecondsSinceEpoch}',
      courseId: courseId,
      videoId: videoId,
      authorName: authorName,
      courseTitle: courseTitle,
      message: message,
      timeLabel: 'Just now',
      createdAt: now,
    );

    _comments.insert(0, comment);
    return comment;
  }

  static final List<CourseCommentModel> _comments = [
    CourseCommentModel(
      id: 'comment-001',
      courseId: 'course-001',
      videoId: 'video-002',
      authorName: 'Sophia Lane',
      courseTitle: 'Flutter for Scalable Products',
      message: 'The architecture breakdown around repositories was excellent.',
      timeLabel: 'Today',
      createdAt: DateTime(2026, 3, 26, 10, 30),
    ),
    CourseCommentModel(
      id: 'comment-002',
      courseId: 'course-001',
      videoId: 'video-002',
      authorName: 'Ava Morgan',
      courseTitle: 'Flutter for Scalable Products',
      message: 'Focus on boundaries between data and domain in this lesson.',
      timeLabel: 'Today',
      createdAt: DateTime(2026, 3, 26, 9, 20),
    ),
    CourseCommentModel(
      id: 'comment-003',
      courseId: 'course-002',
      videoId: 'video-202',
      authorName: 'Noah Student',
      courseTitle: 'Design Systems for Learning Apps',
      message: 'The spacing scale explanation made the whole system click.',
      timeLabel: 'Yesterday',
      createdAt: DateTime(2026, 3, 25, 17, 15),
    ),
  ];
}
