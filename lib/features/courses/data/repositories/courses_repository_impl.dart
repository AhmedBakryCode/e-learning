import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/courses/data/datasources/courses_data_source.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';

class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl({required CoursesDataSource dataSource})
    : _dataSource = dataSource;

  final CoursesDataSource _dataSource;

  @override
  Future<List<Course>> getCourses({required UserRole role}) {
    return _dataSource.getCourses(role: role);
  }

  @override
  Future<List<Course>> getFeaturedCourses() {
    return _dataSource.getFeaturedCourses();
  }

  @override
  Future<Course?> getCourseById(String id) {
    return _dataSource.getCourseById(id);
  }

  @override
  Future<Course> createCourse({
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
  }) {
    return _dataSource.createCourse(
      title: title,
      description: description,
      instructorName: instructorName,
      category: category,
      level: level,
      isPublished: isPublished,
    );
  }

  @override
  Future<Course> updateCourse({
    required String id,
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
  }) {
    return _dataSource.updateCourse(
      id: id,
      title: title,
      description: description,
      instructorName: instructorName,
      category: category,
      level: level,
      isPublished: isPublished,
    );
  }

  @override
  Future<void> deleteCourse(String id) {
    return _dataSource.deleteCourse(id);
  }

  @override
  Future<List<CourseVideo>> getCourseVideos(String courseId) {
    return _dataSource.getCourseVideos(courseId);
  }

  @override
  Future<CourseVideo> addCourseVideo({
    required String courseId,
    required String title,
    required String description,
    required String videoUrl,
  }) {
    return _dataSource.addCourseVideo(
      courseId: courseId,
      title: title,
      description: description,
      videoUrl: videoUrl,
    );
  }
}
