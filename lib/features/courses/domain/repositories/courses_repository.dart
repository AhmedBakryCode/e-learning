import 'dart:io';

import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';

abstract class CoursesRepository {
  Future<List<Course>> getCourses({required UserRole role});

  Future<List<Course>> getFeaturedCourses();

  Future<Course?> getCourseById(String id);

  Future<Course> createCourse({
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
  });

  Future<Course> updateCourse({
    required String id,
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
  });

  Future<void> deleteCourse(String id);

  Future<List<CourseVideo>> getCourseVideos(String courseId);

  Future<CourseVideo> addCourseVideo({
    required String courseId,
    required String title,
    required String description,
    required File videoFile,
    required bool isPreview,
  });
}
