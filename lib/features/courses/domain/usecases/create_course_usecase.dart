import 'dart:io';

import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';
import 'package:equatable/equatable.dart';

class CreateCourseParams extends Equatable {
  const CreateCourseParams({
    required this.title,
    required this.description,
    required this.instructorName,
    required this.category,
    required this.level,
    required this.isPublished,
    this.imageFile,
  });

  final String title;
  final String description;
  final String instructorName;
  final String category;
  final String level;
  final bool isPublished;
  final File? imageFile;

  @override
  List<Object?> get props => [
    title,
    description,
    instructorName,
    category,
    level,
    isPublished,
    imageFile,
  ];
}

class CreateCourseUseCase implements UseCase<Course, CreateCourseParams> {
  const CreateCourseUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<Course> call(CreateCourseParams params) {
    return _repository.createCourse(
      title: params.title,
      description: params.description,
      instructorName: params.instructorName,
      category: params.category,
      level: params.level,
      isPublished: params.isPublished,
      imageFile: params.imageFile,
    );
  }
}
