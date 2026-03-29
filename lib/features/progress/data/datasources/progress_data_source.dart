import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/features/courses/data/datasources/courses_data_source.dart';
import 'package:e_learning/features/progress/data/models/learning_progress_model.dart';
import 'package:e_learning/features/progress/data/models/video_watch_progress_model.dart';
import 'package:e_learning/features/students/data/datasources/students_data_source.dart';

abstract class ProgressDataSource {
  Future<List<LearningProgressModel>> getProgressItems({String? studentId});

  Future<LearningProgressModel> updateProgress({
    required String progressId,
    required double completionPercent,
    required int currentLesson,
  });

  Future<LearningProgressModel> enrollInCourse({
    required String studentId,
    required String courseId,
  });

  Future<List<VideoWatchProgressModel>> getVideoProgress({
    required String studentId,
    required String courseId,
  });

  Future<VideoWatchProgressModel> saveVideoProgress({
    required String studentId,
    required String courseId,
    required String videoId,
    required int watchedSeconds,
  });

  Future<VideoWatchProgressModel> markVideoCompleted({
    required String studentId,
    required String courseId,
    required String videoId,
  });
}

class MockProgressDataSource implements ProgressDataSource {
  const MockProgressDataSource();

  @override
  Future<List<LearningProgressModel>> getProgressItems({
    String? studentId,
  }) async {
    await Future<void>.delayed(AppDurations.short);

    _ensureSeeded();
    _syncAllStudentMetrics();

    final items = _buildLearningProgressItems();
    if (studentId == null) {
      return List<LearningProgressModel>.from(items);
    }

    return items
        .where((item) => item.studentId == studentId)
        .map((item) => item)
        .toList();
  }

  @override
  Future<LearningProgressModel> updateProgress({
    required String progressId,
    required double completionPercent,
    required int currentLesson,
  }) async {
    await Future<void>.delayed(AppDurations.medium);

    _ensureSeeded();

    final progress = _buildLearningProgressItems().where(
      (item) => item.id == progressId,
    );
    if (progress.isEmpty) {
      throw StateError('Progress item not found');
    }

    final current = progress.first;
    final videos = MockCoursesDataSource.videosForCourse(current.courseId);
    if (videos.isEmpty) {
      throw StateError('Course videos not found');
    }

    final clampedPercent = completionPercent.clamp(0, 1).toDouble();
    final clampedLesson = currentLesson.clamp(0, videos.length).toInt();
    final totalEquivalent = clampedPercent * videos.length;
    final completedCount = totalEquivalent.floor().clamp(0, videos.length);
    final partialFraction = (totalEquivalent - completedCount).clamp(0, 1);

    for (var index = 0; index < videos.length; index++) {
      final video = videos[index];
      final durationSeconds = _durationToSeconds(video.duration);
      var watchedSeconds = 0;
      var isCompleted = false;

      if (index < completedCount || index < clampedLesson - 1) {
        watchedSeconds = durationSeconds;
        isCompleted = true;
      } else if (index == completedCount && index < videos.length) {
        watchedSeconds = (durationSeconds * partialFraction).round();
      }

      final key = _videoKey(current.studentId, current.courseId, video.id);
      _videoProgress[key] =
          (_videoProgress[key] ??
                  VideoWatchProgressModel(
                    id: key,
                    studentId: current.studentId,
                    courseId: current.courseId,
                    videoId: video.id,
                    watchedSeconds: 0,
                    totalDurationSeconds: durationSeconds,
                    isCompleted: false,
                  ))
              .copyWith(
                watchedSeconds: watchedSeconds,
                totalDurationSeconds: durationSeconds,
                isCompleted: isCompleted || watchedSeconds >= durationSeconds,
                lastWatchedAt: index <= clampedLesson - 1
                    ? DateTime.now()
                    : null,
              );
    }

    final updated = _buildLearningProgressItems().firstWhere(
      (item) => item.id == progressId,
    );

    _syncStudentMetrics(updated.studentId);
    return updated;
  }

  @override
  Future<LearningProgressModel> enrollInCourse({
    required String studentId,
    required String courseId,
  }) async {
    await Future<void>.delayed(AppDurations.medium);
    _ensureSeeded();

    final videos = MockCoursesDataSource.videosForCourse(courseId);
    if (videos.isEmpty) {
      throw StateError('Course not found or has no videos');
    }

    // Initialize progress for each video
    for (final video in videos) {
      final key = _videoKey(studentId, courseId, video.id);
      if (!_videoProgress.containsKey(key)) {
        _videoProgress[key] = VideoWatchProgressModel(
          id: key,
          studentId: studentId,
          courseId: courseId,
          videoId: video.id,
          watchedSeconds: 0,
          totalDurationSeconds: _durationToSeconds(video.duration),
          isCompleted: false,
        );
      }
    }

    final items = _buildLearningProgressItems();
    final newProgress = items.firstWhere(
      (item) => item.studentId == studentId && item.courseId == courseId,
    );

    _syncStudentMetrics(studentId);
    return newProgress;
  }

  @override
  Future<List<VideoWatchProgressModel>> getVideoProgress({
    required String studentId,
    required String courseId,
  }) async {
    await Future<void>.delayed(AppDurations.short);
    _ensureSeeded();

    final videos = MockCoursesDataSource.videosForCourse(courseId);
    return videos.map((video) {
      final key = _videoKey(studentId, courseId, video.id);
      return _videoProgress[key] ??
          VideoWatchProgressModel(
            id: key,
            studentId: studentId,
            courseId: courseId,
            videoId: video.id,
            watchedSeconds: 0,
            totalDurationSeconds: _durationToSeconds(video.duration),
            isCompleted: false,
          );
    }).toList();
  }

  @override
  Future<VideoWatchProgressModel> saveVideoProgress({
    required String studentId,
    required String courseId,
    required String videoId,
    required int watchedSeconds,
  }) async {
    await Future<void>.delayed(AppDurations.short);
    _ensureSeeded();

    final video = MockCoursesDataSource.findVideo(courseId, videoId);
    if (video == null) {
      throw StateError('Video not found');
    }

    final durationSeconds = _durationToSeconds(video.duration);
    final clampedSeconds = watchedSeconds.clamp(0, durationSeconds).toInt();
    final key = _videoKey(studentId, courseId, videoId);
    final updated =
        (_videoProgress[key] ??
                VideoWatchProgressModel(
                  id: key,
                  studentId: studentId,
                  courseId: courseId,
                  videoId: videoId,
                  watchedSeconds: 0,
                  totalDurationSeconds: durationSeconds,
                  isCompleted: false,
                ))
            .copyWith(
              watchedSeconds: clampedSeconds,
              totalDurationSeconds: durationSeconds,
              isCompleted: clampedSeconds >= durationSeconds,
              lastWatchedAt: DateTime.now(),
            );

    _videoProgress[key] = updated;
    _syncStudentMetrics(studentId);
    return updated;
  }

  @override
  Future<VideoWatchProgressModel> markVideoCompleted({
    required String studentId,
    required String courseId,
    required String videoId,
  }) async {
    await Future<void>.delayed(AppDurations.short);
    _ensureSeeded();

    final video = MockCoursesDataSource.findVideo(courseId, videoId);
    if (video == null) {
      throw StateError('Video not found');
    }

    final durationSeconds = _durationToSeconds(video.duration);
    final key = _videoKey(studentId, courseId, videoId);
    final updated =
        (_videoProgress[key] ??
                VideoWatchProgressModel(
                  id: key,
                  studentId: studentId,
                  courseId: courseId,
                  videoId: videoId,
                  watchedSeconds: 0,
                  totalDurationSeconds: durationSeconds,
                  isCompleted: false,
                ))
            .copyWith(
              watchedSeconds: durationSeconds,
              totalDurationSeconds: durationSeconds,
              isCompleted: true,
              lastWatchedAt: DateTime.now(),
            );

    _videoProgress[key] = updated;
    _syncStudentMetrics(studentId);
    return updated;
  }

  static final Map<String, VideoWatchProgressModel> _videoProgress = {};
  static bool _isSeeded = false;

  static List<LearningProgressModel> catalogForStudent(String studentId) {
    return List<LearningProgressModel>.unmodifiable(
      _buildLearningProgressItems().where(
        (item) => item.studentId == studentId,
      ),
    );
  }

  static void _syncAllStudentMetrics() {
    final studentIds = _videoProgress.values
        .map((item) => item.studentId)
        .toSet();
    for (final studentId in studentIds) {
      _syncStudentMetrics(studentId);
    }
  }

  static void _syncStudentMetrics(String studentId) {
    final items = _buildLearningProgressItems().where(
      (item) => item.studentId == studentId,
    );
    if (items.isEmpty) {
      MockStudentsDataSource.updateMetrics(
        studentId: studentId,
        activeCourses: 0,
        completionRate: 0,
      );
      return;
    }

    final itemList = items.toList();
    final average =
        itemList.fold<double>(0, (sum, item) => sum + item.completionPercent) /
        itemList.length;

    MockStudentsDataSource.updateMetrics(
      studentId: studentId,
      activeCourses: itemList.length,
      completionRate: average,
    );
  }

  static void _ensureSeeded() {
    if (_isSeeded) {
      return;
    }

    const seed = <String, Map<String, int>>{
      'student-001|course-001': {
        'video-001': 492,
        'video-002': 620,
        'video-003': 180,
        'video-004': 0,
      },
      'student-001|course-002': {
        'video-201': 505,
        'video-202': 330,
        'video-203': 0,
        'video-204': 0,
      },
      'student-002|course-003': {
        'video-301': 455,
        'video-302': 615,
        'video-303': 290,
        'video-304': 0,
      },
      'student-002|course-006': {
        'video-601': 420,
        'video-602': 210,
        'video-603': 0,
        'video-604': 0,
      },
      'student-003|course-002': {
        'video-201': 505,
        'video-202': 602,
        'video-203': 544,
        'video-204': 430,
      },
      'student-003|course-004': {
        'video-401': 738,
        'video-402': 930,
        'video-403': 340,
      },
      'student-003|course-005': {
        'video-501': 460,
        'video-502': 688,
        'video-503': 722,
        'video-504': 601,
      },
    };

    for (final entry in seed.entries) {
      final parts = entry.key.split('|');
      final studentId = parts[0];
      final courseId = parts[1];
      for (final videoEntry in entry.value.entries) {
        final video = MockCoursesDataSource.findVideo(courseId, videoEntry.key);
        if (video == null) {
          continue;
        }

        final durationSeconds = _durationToSeconds(video.duration);
        final watchedSeconds = videoEntry.value.clamp(0, durationSeconds);
        final key = _videoKey(studentId, courseId, video.id);
        _videoProgress[key] = VideoWatchProgressModel(
          id: key,
          studentId: studentId,
          courseId: courseId,
          videoId: video.id,
          watchedSeconds: watchedSeconds,
          totalDurationSeconds: durationSeconds,
          isCompleted: watchedSeconds >= durationSeconds,
          lastWatchedAt: watchedSeconds == 0
              ? null
              : DateTime.now().subtract(
                  Duration(minutes: (durationSeconds - watchedSeconds).abs()),
                ),
        );
      }
    }

    _isSeeded = true;
  }

  static List<LearningProgressModel> _buildLearningProgressItems() {
    final grouped = <String, List<VideoWatchProgressModel>>{};
    for (final item in _videoProgress.values) {
      grouped.putIfAbsent(item.studentId, () => <VideoWatchProgressModel>[]);
    }

    for (final item in _videoProgress.values) {
      final key = '${item.studentId}|${item.courseId}';
      grouped.putIfAbsent(key, () => <VideoWatchProgressModel>[]);
      grouped[key]!.add(item);
    }

    final progressItems = <LearningProgressModel>[];
    for (final entry in grouped.entries) {
      if (!entry.key.contains('|')) {
        continue;
      }

      final parts = entry.key.split('|');
      final studentId = parts[0];
      final courseId = parts[1];
      final course = MockCoursesDataSource.findCourse(courseId);
      if (course == null) {
        continue;
      }

      final videoProgress = entry.value;
      if (videoProgress.isEmpty) {
        continue;
      }

      final watchedVideos = videoProgress
          .where((item) => item.watchedSeconds > 0)
          .length;
      final completionPercent =
          videoProgress.fold<double>(
            0,
            (sum, item) => sum + item.watchedFraction,
          ) /
          videoProgress.length;
      final lastItem = _lastWatched(videoProgress);
      final currentLesson = lastItem == null
          ? 1
          : (MockCoursesDataSource.videosForCourse(
                      courseId,
                    ).indexWhere((video) => video.id == lastItem.videoId) +
                    1)
                .clamp(1, videoProgress.length);

      progressItems.add(
        LearningProgressModel(
          id: 'progress-$studentId-$courseId',
          studentId: studentId,
          courseId: courseId,
          courseTitle: course.title,
          completionPercent: completionPercent,
          currentLesson: currentLesson,
          totalLessons: videoProgress.length,
          watchedVideos: watchedVideos,
          lastVideoId: lastItem?.videoId,
          lastVideoTitle: lastItem == null
              ? null
              : MockCoursesDataSource.findVideo(
                  courseId,
                  lastItem.videoId,
                )?.title,
        ),
      );
    }

    progressItems.sort((a, b) => a.courseTitle.compareTo(b.courseTitle));
    return progressItems;
  }

  static VideoWatchProgressModel? _lastWatched(
    List<VideoWatchProgressModel> items,
  ) {
    final watchedItems = items
        .where((item) => item.lastWatchedAt != null)
        .toList();
    if (watchedItems.isEmpty) {
      return null;
    }

    watchedItems.sort((a, b) => b.lastWatchedAt!.compareTo(a.lastWatchedAt!));
    return watchedItems.first;
  }

  static String _videoKey(String studentId, String courseId, String videoId) {
    return '$studentId|$courseId|$videoId';
  }

  static int _durationToSeconds(String duration) {
    final parts = duration.split(':');
    if (parts.length != 2) {
      return 0;
    }

    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    return minutes * 60 + seconds;
  }
}
