import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';

class GetFeaturedCoursesUseCase implements UseCase<List<Course>, NoParams> {
  const GetFeaturedCoursesUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<List<Course>> call(NoParams params) {
    return _repository.getFeaturedCourses();
  }
}
