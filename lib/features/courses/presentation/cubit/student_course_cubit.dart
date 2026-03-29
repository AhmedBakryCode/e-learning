import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/courses/domain/usecases/get_course_by_id_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_course_videos_usecase.dart';
import 'package:e_learning/features/courses/presentation/cubit/student_course_state.dart';
import 'package:e_learning/features/progress/domain/entities/learning_progress.dart';
import 'package:e_learning/features/progress/domain/usecases/get_progress_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/get_video_progress_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentCourseCubit extends Cubit<StudentCourseState> {
  StudentCourseCubit({
    required GetCourseByIdUseCase getCourseById,
    required GetCourseVideosUseCase getCourseVideos,
    required GetProgressUseCase getProgress,
    required GetVideoProgressUseCase getVideoProgress,
  }) : _getCourseById = getCourseById,
       _getCourseVideos = getCourseVideos,
       _getProgress = getProgress,
       _getVideoProgress = getVideoProgress,
       super(const StudentCourseState());

  final GetCourseByIdUseCase _getCourseById;
  final GetCourseVideosUseCase _getCourseVideos;
  final GetProgressUseCase _getProgress;
  final GetVideoProgressUseCase _getVideoProgress;

  Future<void> loadCourse({
    required String studentId,
    required String courseId,
  }) async {
    emit(
      state.copyWith(status: ViewStateStatus.loading, clearErrorMessage: true),
    );

    try {
      final course = await _getCourseById(GetCourseByIdParams(courseId));
      if (course == null) {
        throw StateError('Course not found');
      }

      final videos = await _getCourseVideos(GetCourseVideosParams(courseId));
      final watchItems = await _getVideoProgress(
        GetVideoProgressParams(studentId: studentId, courseId: courseId),
      );
      final progressItems = await _getProgress(
        GetProgressParams(studentId: studentId),
      );
      final progress = _findProgress(progressItems, courseId);
      final progressByVideo = {
        for (final item in watchItems) item.videoId: item,
      };

      final enrichedVideos = videos.map((video) {
        final watch = progressByVideo[video.id];
        return video.copyWith(progress: watch?.watchedFraction ?? 0);
      }).toList();

      emit(
        state.copyWith(
          status: ViewStateStatus.success,
          course: course.copyWith(
            completionPercent: progress?.completionPercent ?? 0,
            totalLessons: videos.length,
          ),
          videos: enrichedVideos,
          progress: progress,
          lastWatchedVideoId: progress?.lastVideoId,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load this course right now.',
        ),
      );
    }
  }

  LearningProgress? _findProgress(
    List<LearningProgress> progressItems,
    String courseId,
  ) {
    final index = progressItems.indexWhere((item) => item.courseId == courseId);
    return index == -1 ? null : progressItems[index];
  }
}
