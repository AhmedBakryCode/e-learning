import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';
import 'package:equatable/equatable.dart';

class GetCourseVideosParams extends Equatable {
  const GetCourseVideosParams(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}

class GetCourseVideosUseCase
    implements UseCase<List<CourseVideo>, GetCourseVideosParams> {
  const GetCourseVideosUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<List<CourseVideo>> call(GetCourseVideosParams params) {
    return _repository.getCourseVideos(params.courseId);
  }
}
