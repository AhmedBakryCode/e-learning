import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';
import 'package:e_learning/features/courses/domain/usecases/get_course_by_id_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_course_videos_usecase.dart';
import 'package:e_learning/features/courses/presentation/cubit/video_session_state.dart';
import 'package:e_learning/features/progress/domain/entities/video_watch_progress.dart';
import 'package:e_learning/features/progress/domain/usecases/get_video_progress_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/mark_video_completed_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/save_video_progress_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoSessionCubit extends Cubit<VideoSessionState> {
  VideoSessionCubit({
    required GetCourseByIdUseCase getCourseById,
    required GetCourseVideosUseCase getCourseVideos,
    required GetVideoProgressUseCase getVideoProgress,
    required SaveVideoProgressUseCase saveVideoProgress,
    required MarkVideoCompletedUseCase markVideoCompleted,
  }) : _getCourseById = getCourseById,
       _getCourseVideos = getCourseVideos,
       _getVideoProgress = getVideoProgress,
       _saveVideoProgress = saveVideoProgress,
       _markVideoCompleted = markVideoCompleted,
       super(const VideoSessionState());

  final GetCourseByIdUseCase _getCourseById;
  final GetCourseVideosUseCase _getCourseVideos;
  final GetVideoProgressUseCase _getVideoProgress;
  final SaveVideoProgressUseCase _saveVideoProgress;
  final MarkVideoCompletedUseCase _markVideoCompleted;

  late String _studentId;
  late String _courseId;

  Future<void> loadSession({
    required String studentId,
    required String courseId,
    required String videoId,
  }) async {
    emit(
      state.copyWith(status: ViewStateStatus.loading, clearErrorMessage: true),
    );

    _studentId = studentId;
    _courseId = courseId;

    try {
      final course = await _getCourseById(GetCourseByIdParams(courseId));
      if (course == null) {
        throw StateError('Course not found');
      }

      final videos = await _getCourseVideos(GetCourseVideosParams(courseId));
      final progressItems = await _getVideoProgress(
        GetVideoProgressParams(studentId: studentId, courseId: courseId),
      );

      emit(
        _buildState(
          course: course,
          videos: videos,
          progressItems: progressItems,
          videoId: videoId,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load this video right now.',
        ),
      );
    }
  }

  Future<void> savePlayback(int watchedSeconds) async {
    if (state.currentVideo == null) {
      return;
    }

    try {
      final updated = await _saveVideoProgress(
        SaveVideoProgressParams(
          studentId: _studentId,
          courseId: _courseId,
          videoId: state.currentVideo!.id,
          watchedSeconds: watchedSeconds,
        ),
      );
      _emitUpdatedProgress(
        updated,
        actionMessage: null,
        actionStatus: ViewStateStatus.initial,
      );
    } catch (e) {
      // Ignore background save errors, or log them
    }
  }

  Future<void> markCompleted() async {
    if (state.currentVideo == null) {
      return;
    }

    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final updated = await _markVideoCompleted(
        MarkVideoCompletedParams(
          studentId: _studentId,
          courseId: _courseId,
          videoId: state.currentVideo!.id,
        ),
      );
      _emitUpdatedProgress(
        updated,
        actionMessage: 'Video marked as completed.',
        actionStatus: ViewStateStatus.success,
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to mark this video as completed.',
        ),
      );
    }
  }

  Future<void> switchVideo(String videoId) async {
    if (state.course == null) {
      return;
    }

    emit(
      _buildState(
        course: state.course!,
        videos: state.videos,
        progressItems: state.videoProgress,
        videoId: videoId,
      ),
    );
  }

  void clearActionState() {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.initial,
        clearActionMessage: true,
      ),
    );
  }

  void _emitUpdatedProgress(
    VideoWatchProgress updatedProgress, {
    required String? actionMessage,
    required ViewStateStatus actionStatus,
  }) {
    final updatedItems = state.videoProgress.map((item) {
      if (item.videoId != updatedProgress.videoId) {
        return item;
      }
      return updatedProgress;
    }).toList();

    emit(
      _buildState(
        course: state.course!,
        videos: state.videos,
        progressItems: updatedItems,
        videoId: state.currentVideo!.id,
        actionMessage: actionMessage,
        actionStatus: actionStatus,
      ),
    );
  }

  VideoSessionState _buildState({
    required Course course,
    required List<CourseVideo> videos,
    required List<VideoWatchProgress> progressItems,
    required String videoId,
    String? actionMessage,
    ViewStateStatus actionStatus = ViewStateStatus.initial,
  }) {
    final progressByVideo = {
      for (final item in progressItems) item.videoId: item,
    };
    final enrichedVideos = videos.map((video) {
      final progress = progressByVideo[video.id];
      return video.copyWith(progress: progress?.watchedFraction ?? 0);
    }).toList();
    final currentIndex = enrichedVideos.indexWhere(
      (video) => video.id == videoId,
    );
    final currentVideo = currentIndex == -1
        ? enrichedVideos.first
        : enrichedVideos[currentIndex];
    final currentProgress = progressByVideo[currentVideo.id];
    final courseProgress = progressItems.isEmpty
        ? 0.0
        : progressItems.fold<double>(
                0,
                (sum, item) => sum + item.watchedFraction,
              ) /
              progressItems.length;

    return state.copyWith(
      status: ViewStateStatus.success,
      actionStatus: actionStatus,
      course: course.copyWith(
        completionPercent: courseProgress,
        totalLessons: enrichedVideos.length,
      ),
      videos: enrichedVideos,
      videoProgress: progressItems,
      currentVideo: currentVideo,
      resumePositionSeconds: currentProgress?.watchedSeconds ?? 0,
      courseProgressPercent: courseProgress,
      actionMessage: actionMessage,
      clearErrorMessage: true,
      clearActionMessage: actionMessage == null,
    );
  }
}
