import 'dart:io';

import 'package:e_learning/core/usecases/usecase.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';
import 'package:equatable/equatable.dart';

class AddCourseVideoParams extends Equatable {
  const AddCourseVideoParams({
    required this.courseId,
    required this.title,
    required this.description,
    required this.videoFile,
    this.isPreview = false,
  });

  final String courseId;
  final String title;
  final String description;
  final File videoFile;
  final bool isPreview;

  @override
  List<Object?> get props => [
    courseId,
    title,
    description,
    videoFile,
    isPreview,
  ];
}

class AddCourseVideoUseCase
    implements UseCase<CourseVideo, AddCourseVideoParams> {
  const AddCourseVideoUseCase(this._repository);

  final CoursesRepository _repository;

  @override
  Future<CourseVideo> call(AddCourseVideoParams params) {
    return _repository.addCourseVideo(
      courseId: params.courseId,
      title: params.title,
      description: params.description,
      videoFile: params.videoFile,
      isPreview: params.isPreview,
    );
  }
}
