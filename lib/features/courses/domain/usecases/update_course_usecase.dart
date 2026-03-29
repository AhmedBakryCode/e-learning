import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateCourseParams extends Equatable {
  const UpdateCourseParams({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorName,
    required this.category,
    required this.level,
    required this.isPublished,
  });

  final String id;
  final String title;
  final String description;
  final String instructorName;
  final String category;
  final String level;
  final bool isPublished;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    instructorName,
    category,
    level,
    isPublished,
  ];
}

class UpdateCourseUseCase implements UseCase<Course, UpdateCourseParams> {
  const UpdateCourseUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Course> call(UpdateCourseParams params) {
    return _repository.updateCourse(
      id: params.id,
      title: params.title,
      description: params.description,
      instructorName: params.instructorName,
      category: params.category,
      level: params.level,
      isPublished: params.isPublished,
    );
  }
}
