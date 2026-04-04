import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/usecases/add_course_video_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/create_course_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/delete_course_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_course_by_id_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_course_videos_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_featured_courses_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/update_course_usecase.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit({
    required GetCoursesUseCase getCourses,
    required GetFeaturedCoursesUseCase getFeaturedCourses,
    required GetCourseByIdUseCase getCourseById,
    required CreateCourseUseCase createCourse,
    required UpdateCourseUseCase updateCourse,
    required DeleteCourseUseCase deleteCourse,
    required GetCourseVideosUseCase getCourseVideos,
    required AddCourseVideoUseCase addCourseVideo,
  }) : _getCourses = getCourses,
       _getFeaturedCourses = getFeaturedCourses,
       _getCourseById = getCourseById,
       _createCourse = createCourse,
       _updateCourse = updateCourse,
       _deleteCourse = deleteCourse,
       _getCourseVideos = getCourseVideos,
       _addCourseVideo = addCourseVideo,
       super(const CoursesState());

  final GetCoursesUseCase _getCourses;
  final GetFeaturedCoursesUseCase _getFeaturedCourses;
  final GetCourseByIdUseCase _getCourseById;
  final CreateCourseUseCase _createCourse;
  final UpdateCourseUseCase _updateCourse;
  final DeleteCourseUseCase _deleteCourse;
  final GetCourseVideosUseCase _getCourseVideos;
  final AddCourseVideoUseCase _addCourseVideo;

  Future<void> loadCourses(UserRole role) async {
    emit(
      state.copyWith(status: ViewStateStatus.loading, clearErrorMessage: true),
    );

    try {
      final courses = await _getCourses(GetCoursesParams(role: role));
      final featuredCourses = await _getFeaturedCourses(const NoParams());
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ViewStateStatus.success,
          courses: courses,
          featuredCourses: featuredCourses
              .where((course) => courses.any((item) => item.id == course.id))
              .toList(),
          courseVideos: state.courseVideos,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load courses right now.',
        ),
      );
    }
  }

  Future<void> loadCourseDetails(String courseId) async {
    emit(
      state.copyWith(
        status: ViewStateStatus.loading,
        clearErrorMessage: true,
        clearSelectedCourse: true,
      ),
    );

    try {
      final course = await _getCourseById(GetCourseByIdParams(courseId));
      if (course == null) {
        throw StateError('Course not found');
      }

      final videos = await _getCourseVideos(GetCourseVideosParams(courseId));
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ViewStateStatus.success,
          selectedCourse: course,
          courseVideos: videos,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ViewStateStatus.failure,
          errorMessage: 'Unable to load course details right now.',
          clearSelectedCourse: true,
          courseVideos: const [],
        ),
      );
    }
  }

  Future<void> createCourse(CreateCourseParams params) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final course = await _createCourse(params);
      if (isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Course created successfully.',
          selectedCourse: course,
          courses: [course, ...state.courses],
          featuredCourses: _syncFeaturedCourses(course),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to create this course right now.',
        ),
      );
    }
  }

  Future<void> updateCourse(UpdateCourseParams params) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final course = await _updateCourse(params);
      if (isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Course updated successfully.',
          selectedCourse: course,
          courses: _replaceCourse(state.courses, course),
          featuredCourses: _replaceCourse(state.featuredCourses, course),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to update this course right now.',
        ),
      );
    }
  }

  Future<void> deleteCourse(String courseId) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      await _deleteCourse(DeleteCourseParams(courseId));
      if (isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Course deleted successfully.',
          courses: state.courses
              .where((course) => course.id != courseId)
              .toList(),
          featuredCourses: state.featuredCourses
              .where((course) => course.id != courseId)
              .toList(),
          clearSelectedCourse: true,
          courseVideos: const [],
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to delete this course right now.',
        ),
      );
    }
  }

  Future<void> addVideo(AddCourseVideoParams params) async {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.loading,
        clearActionMessage: true,
      ),
    );

    try {
      final video = await _addCourseVideo(params);
      final refreshedCourse = await _getCourseById(
        GetCourseByIdParams(params.courseId),
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.success,
          actionMessage: 'Video added successfully.',
          selectedCourse: refreshedCourse ?? state.selectedCourse,
          courseVideos: [...state.courseVideos, video],
          courses: refreshedCourse == null
              ? state.courses
              : _replaceCourse(state.courses, refreshedCourse),
          featuredCourses: refreshedCourse == null
              ? state.featuredCourses
              : _replaceCourse(state.featuredCourses, refreshedCourse),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          actionStatus: ViewStateStatus.failure,
          actionMessage: 'Unable to attach this video right now.',
        ),
      );
    }
  }

  void changeCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }

  void clearActionState() {
    emit(
      state.copyWith(
        actionStatus: ViewStateStatus.initial,
        clearActionMessage: true,
      ),
    );
  }

  List<Course> _replaceCourse(List<Course> courses, Course updatedCourse) {
    final index = courses.indexWhere((course) => course.id == updatedCourse.id);
    if (index == -1) {
      return courses;
    }

    return [...courses.take(index), updatedCourse, ...courses.skip(index + 1)];
  }

  List<Course> _syncFeaturedCourses(Course course) {
    if (course.isFeatured) {
      return [course, ...state.featuredCourses];
    }

    return state.featuredCourses;
  }
}
