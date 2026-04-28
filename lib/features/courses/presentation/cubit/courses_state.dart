import 'package:e_learning/core/constants/view_state_status.dart';
import 'package:e_learning/features/courses/domain/entities/course.dart';
import 'package:e_learning/features/courses/domain/entities/course_video.dart';
import 'package:equatable/equatable.dart';

class CoursesState extends Equatable {
  const CoursesState({
    this.status = ViewStateStatus.initial,
    this.actionStatus = ViewStateStatus.initial,
    this.courses = const [],
    this.featuredCourses = const [],
    this.courseVideos = const [],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.selectedCourse,
    this.errorMessage,
    this.actionMessage,
  });

  final ViewStateStatus status;
  final ViewStateStatus actionStatus;
  final List<Course> courses;
  final List<Course> featuredCourses;
  final List<CourseVideo> courseVideos;
  final String selectedCategory;
  final String searchQuery;
  final Course? selectedCourse;
  final String? errorMessage;
  final String? actionMessage;

  List<String> get categories {
    final values = courses.map((course) => course.category).toSet().toList()
      ..sort();
    return ['All', ...values];
  }

  List<Course> get filteredCourses {
    var result = courses;
    
    if (selectedCategory != 'All') {
      result = result.where((course) => course.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((course) => 
        course.title.toLowerCase().contains(query) ||
        course.category.toLowerCase().contains(query) ||
        course.instructorName.toLowerCase().contains(query)
      ).toList();
    }

    return result;
  }

  CoursesState copyWith({
    ViewStateStatus? status,
    ViewStateStatus? actionStatus,
    List<Course>? courses,
    List<Course>? featuredCourses,
    List<CourseVideo>? courseVideos,
    String? selectedCategory,
    String? searchQuery,
    Course? selectedCourse,
    String? errorMessage,
    String? actionMessage,
    bool clearErrorMessage = false,
    bool clearActionMessage = false,
    bool clearSelectedCourse = false,
  }) {
    return CoursesState(
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      courses: courses ?? this.courses,
      featuredCourses: featuredCourses ?? this.featuredCourses,
      courseVideos: courseVideos ?? this.courseVideos,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCourse: clearSelectedCourse
          ? null
          : selectedCourse ?? this.selectedCourse,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    actionStatus,
    courses,
    featuredCourses,
    courseVideos,
    selectedCategory,
    searchQuery,
    selectedCourse,
    errorMessage,
    actionMessage,
  ];
}
