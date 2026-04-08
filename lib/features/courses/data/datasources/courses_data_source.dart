import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/constants/endpoint_constants.dart';
import 'package:e_learning/core/network/api_service.dart';
import 'package:e_learning/features/auth/domain/entities/app_user.dart';
import 'package:e_learning/features/courses/data/models/course_model.dart';
import 'package:e_learning/features/courses/data/models/course_video_model.dart';

abstract class CoursesDataSource {
  Future<List<CourseModel>> getCourses({required UserRole role});

  Future<List<CourseModel>> getFeaturedCourses();

  Future<CourseModel?> getCourseById(String id);

  Future<CourseModel> createCourse({
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
    File? imageFile,
  });

  Future<CourseModel> updateCourse({
    required String id,
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
    File? imageFile,
  });

  Future<void> deleteCourse(String id);

  Future<List<CourseVideoModel>> getCourseVideos(String courseId);

  Future<CourseVideoModel> addCourseVideo({
    required String courseId,
    required String title,
    required String description,
    required File videoFile,
    required bool isPreview,
  });
}

class RemoteCoursesDataSource implements CoursesDataSource {
  const RemoteCoursesDataSource({required ApiService apiService})
    : _apiService = apiService;

  final ApiService _apiService;

  @override
  Future<List<CourseModel>> getCourses({required UserRole role}) async {
    final response = await _apiService.get('/courses');
    final List<dynamic> data = response.data;
    return data.map((json) => CourseModel.fromJson(json)).toList();
  }

  @override
  Future<List<CourseModel>> getFeaturedCourses() async {
    final response = await _apiService.get('/courses');
    final List<dynamic> data = response.data;
    return data
        .map((json) => CourseModel.fromJson(json))
        .where((course) => course.isFeatured)
        .toList();
  }

  @override
  Future<CourseModel?> getCourseById(String id) async {
    final response = await _apiService.get('/courses/$id');
    return CourseModel.fromJson(response.data);
  }

  @override
  Future<CourseModel> createCourse({
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
    File? imageFile,
  }) async {
    final formData = FormData.fromMap({
      'Title': title,
      'Description': description,
      'InstructorName': instructorName,
      'Category': category,
      'Level': level,
      'IsPublished': isPublished,
      if (imageFile != null)
        'Image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });

    final response = await _apiService.post('/courses', data: formData);
    return CourseModel.fromJson(response.data);
  }

  @override
  Future<CourseModel> updateCourse({
    required String id,
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
    File? imageFile,
  }) async {
    final formData = FormData.fromMap({
      'Title': title,
      'Description': description,
      'InstructorName': instructorName,
      'Category': category,
      'Level': level,
      'IsPublished': isPublished,
      if (imageFile != null)
        'Image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });

    final response = await _apiService.put('/courses/$id', data: formData);
    return CourseModel.fromJson(response.data);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await _apiService.delete('/courses/$id');
  }

  @override
  Future<List<CourseVideoModel>> getCourseVideos(String courseId) async {
    final response = await _apiService.get(
      EndpointConstants.courseVideos.replaceFirst('{courseId}', courseId),
    );
    final List<dynamic> data = response.data;
    return data.map((json) => CourseVideoModel.fromJson(json)).toList();
  }

  @override
  Future<CourseVideoModel> addCourseVideo({
    required String courseId,
    required String title,
    required String description,
    required File videoFile,
    required bool isPreview,
  }) async {
    final formData = FormData.fromMap({
      'Title': title,
      'Description': description,
      'IsPreview': isPreview,
      'Video': await MultipartFile.fromFile(
        videoFile.path,
        filename: videoFile.path.split('/').last,
      ),
    });

    final response = await _apiService.uploadWithTimeout(
      EndpointConstants.courseVideos.replaceFirst('{courseId}', courseId),
      data: formData,
    );
    return CourseVideoModel.fromJson(response.data);
  }
}

class MockCoursesDataSource implements CoursesDataSource {
  const MockCoursesDataSource();

  static const _sampleVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  static final List<CourseModel> _courses = [
    CourseModel(
      id: 'course-001',
      title: 'Flutter for Scalable Products',
      description:
          'Architect modular Flutter apps with maintainable layers, solid testing, and clean state management.',
      instructorName: 'Ava Morgan',
      category: 'Development',
      level: 'Advanced',
      duration: '8h 20m',
      totalLessons: 24,
      enrolledCount: 312,
      rating: 4.9,
      completionPercent: 0.65,
      isFeatured: true,
      isPublished: true,
    ),
    CourseModel(
      id: 'course-002',
      title: 'Design Systems for Learning Apps',
      description:
          'Create consistent UI foundations, spacing scales, and reusable components across web and mobile.',
      instructorName: 'Lina Perez',
      category: 'Design',
      level: 'Intermediate',
      duration: '5h 10m',
      totalLessons: 18,
      enrolledCount: 198,
      rating: 4.7,
      completionPercent: 0.38,
      isFeatured: true,
      isPublished: true,
    ),
    CourseModel(
      id: 'course-003',
      title: 'Product Analytics Fundamentals',
      description:
          'Turn learner behavior into product decisions with dashboards, funnels, and retention analysis.',
      instructorName: 'Zane Holloway',
      category: 'Analytics',
      level: 'Beginner',
      duration: '4h 45m',
      totalLessons: 16,
      enrolledCount: 421,
      rating: 4.6,
      completionPercent: 0.82,
      isFeatured: false,
      isPublished: true,
    ),
    CourseModel(
      id: 'course-004',
      title: 'AI Tutoring Experience Blueprint',
      description:
          'Map adaptive lesson flows, automated feedback loops, and safe prompt patterns for assistants.',
      instructorName: 'Mila Brooks',
      category: 'AI',
      level: 'Intermediate',
      duration: '6h 40m',
      totalLessons: 21,
      enrolledCount: 264,
      rating: 4.8,
      completionPercent: 0.54,
      isFeatured: true,
      isPublished: false,
    ),
    CourseModel(
      id: 'course-005',
      title: 'Mastering Student Engagement',
      description:
          'Build motivation systems, classroom rituals, and feedback frameworks that keep learners active.',
      instructorName: 'Emma Carter',
      category: 'Teaching',
      level: 'Beginner',
      duration: '3h 55m',
      totalLessons: 14,
      enrolledCount: 503,
      rating: 4.5,
      completionPercent: 0.91,
      isFeatured: false,
      isPublished: true,
    ),
    CourseModel(
      id: 'course-006',
      title: 'API Integration Strategy',
      description:
          'Prepare app layers for evolving APIs with repositories, DTO mapping, offline fallbacks, and monitoring.',
      instructorName: 'Noor Almasi',
      category: 'Development',
      level: 'Advanced',
      duration: '7h 05m',
      totalLessons: 20,
      enrolledCount: 154,
      rating: 4.8,
      completionPercent: 0.26,
      isFeatured: false,
      isPublished: false,
    ),
  ];

  static final Map<String, List<CourseVideoModel>> _courseVideos = {
    'course-001': [
      CourseVideoModel(
        id: 'video-001',
        courseId: 'course-001',
        title: 'Welcome and course roadmap',
        description:
            'Set expectations, outcomes, and the weekly delivery path.',
        videoUrl: _sampleVideoUrl,
        duration: '08:12',
        progress: 1,
        isPreview: true,
      ),
      CourseVideoModel(
        id: 'video-002',
        courseId: 'course-001',
        title: 'Architecture foundations',
        description:
            'Understand layers, boundaries, and scalable feature slices.',
        videoUrl: _sampleVideoUrl,
        duration: '14:48',
        progress: 0.76,
      ),
      CourseVideoModel(
        id: 'video-003',
        courseId: 'course-001',
        title: 'Building premium UI systems',
        description:
            'Turn design tokens and reusable widgets into a screen kit.',
        videoUrl: _sampleVideoUrl,
        duration: '19:30',
        progress: 0.42,
      ),
      CourseVideoModel(
        id: 'video-004',
        courseId: 'course-001',
        title: 'Ship-ready workflows',
        description:
            'Loading, empty, and error handling for polished experiences.',
        videoUrl: _sampleVideoUrl,
        duration: '11:05',
        progress: 0.12,
      ),
    ],
    'course-002': [
      CourseVideoModel(
        id: 'video-201',
        courseId: 'course-002',
        title: 'Why design systems matter',
        description:
            'Understand consistency, scalability, and faster team delivery.',
        videoUrl: _sampleVideoUrl,
        duration: '08:25',
        progress: 0.82,
        isPreview: true,
      ),
      CourseVideoModel(
        id: 'video-202',
        courseId: 'course-002',
        title: 'Spacing and typography scales',
        description:
            'Translate layout rhythm into reusable Flutter design tokens.',
        videoUrl: _sampleVideoUrl,
        duration: '10:02',
        progress: 0.54,
      ),
      CourseVideoModel(
        id: 'video-203',
        courseId: 'course-002',
        title: 'Component contracts',
        description:
            'Shape clean APIs for buttons, cards, fields, and feedback UI.',
        videoUrl: _sampleVideoUrl,
        duration: '09:04',
        progress: 0.2,
      ),
      CourseVideoModel(
        id: 'video-204',
        courseId: 'course-002',
        title: 'Dark mode design systems',
        description:
            'Build theme-ready components without duplicating styling logic.',
        videoUrl: _sampleVideoUrl,
        duration: '07:10',
        progress: 0,
      ),
    ],
    'course-003': [
      CourseVideoModel(
        id: 'video-301',
        courseId: 'course-003',
        title: 'Analytics vocabulary',
        description:
            'Learn the key engagement, funnel, and retention terms quickly.',
        videoUrl: _sampleVideoUrl,
        duration: '07:35',
        progress: 0.95,
        isPreview: true,
      ),
      CourseVideoModel(
        id: 'video-302',
        courseId: 'course-003',
        title: 'Retention dashboards',
        description:
            'Read cohort data and identify where students are dropping off.',
        videoUrl: _sampleVideoUrl,
        duration: '10:15',
        progress: 0.6,
      ),
      CourseVideoModel(
        id: 'video-303',
        courseId: 'course-003',
        title: 'Activation events',
        description:
            'Choose product signals that actually reflect learning progress.',
        videoUrl: _sampleVideoUrl,
        duration: '12:02',
        progress: 0.33,
      ),
      CourseVideoModel(
        id: 'video-304',
        courseId: 'course-003',
        title: 'Weekly reporting loops',
        description:
            'Turn analytics into routines that keep teachers aligned weekly.',
        videoUrl: _sampleVideoUrl,
        duration: '08:50',
        progress: 0,
      ),
    ],
    'course-004': [
      CourseVideoModel(
        id: 'video-401',
        courseId: 'course-004',
        title: 'Designing AI lesson flows',
        description: 'Outline safe and adaptive tutoring journeys.',
        videoUrl: _sampleVideoUrl,
        duration: '12:18',
        progress: 0.64,
      ),
      CourseVideoModel(
        id: 'video-402',
        courseId: 'course-004',
        title: 'Feedback loop architecture',
        description: 'Connect prompts, evaluations, and instructor oversight.',
        videoUrl: _sampleVideoUrl,
        duration: '17:42',
        progress: 0.28,
      ),
      CourseVideoModel(
        id: 'video-403',
        courseId: 'course-004',
        title: 'Prototype walkthrough',
        description: 'Review a mock student session from start to finish.',
        videoUrl: _sampleVideoUrl,
        duration: '09:56',
        progress: 0,
        isUploaded: false,
      ),
      CourseVideoModel(
        id: 'video-404',
        courseId: 'course-004',
        title: 'Operational guardrails',
        description:
            'Define boundaries for quality review and safe teacher overrides.',
        videoUrl: _sampleVideoUrl,
        duration: '08:20',
        progress: 0,
      ),
    ],
    'course-005': [
      CourseVideoModel(
        id: 'video-501',
        courseId: 'course-005',
        title: 'Engagement rituals',
        description:
            'Establish repeatable teaching habits that sustain learner focus.',
        videoUrl: _sampleVideoUrl,
        duration: '07:40',
        progress: 0.88,
        isPreview: true,
      ),
      CourseVideoModel(
        id: 'video-502',
        courseId: 'course-005',
        title: 'Feedback that motivates',
        description:
            'Write feedback loops that guide next action without overwhelm.',
        videoUrl: _sampleVideoUrl,
        duration: '11:28',
        progress: 0.57,
      ),
      CourseVideoModel(
        id: 'video-503',
        courseId: 'course-005',
        title: 'Celebrating milestones',
        description:
            'Use recognition moments to reinforce progress and retention.',
        videoUrl: _sampleVideoUrl,
        duration: '12:02',
        progress: 0.41,
      ),
      CourseVideoModel(
        id: 'video-504',
        courseId: 'course-005',
        title: 'Recovery for disengaged students',
        description:
            'Design interventions that help struggling learners re-enter flow.',
        videoUrl: _sampleVideoUrl,
        duration: '10:01',
        progress: 0.15,
      ),
    ],
    'course-006': [
      CourseVideoModel(
        id: 'video-601',
        courseId: 'course-006',
        title: 'Repository boundaries',
        description:
            'Set up API-ready contracts while keeping features independently testable.',
        videoUrl: _sampleVideoUrl,
        duration: '07:00',
        progress: 0.61,
      ),
      CourseVideoModel(
        id: 'video-602',
        courseId: 'course-006',
        title: 'Resilient mapping layers',
        description:
            'Use DTOs and transformation seams to survive backend changes.',
        videoUrl: _sampleVideoUrl,
        duration: '09:20',
        progress: 0.33,
      ),
      CourseVideoModel(
        id: 'video-603',
        courseId: 'course-006',
        title: 'Fallback and retry strategy',
        description:
            'Blend caching and recovery paths into a stable user experience.',
        videoUrl: _sampleVideoUrl,
        duration: '08:42',
        progress: 0.1,
      ),
      CourseVideoModel(
        id: 'video-604',
        courseId: 'course-006',
        title: 'Monitoring API health',
        description:
            'Add diagnostics so failures are visible before users complain.',
        videoUrl: _sampleVideoUrl,
        duration: '10:50',
        progress: 0,
      ),
    ],
  };

  static List<CourseModel> get catalog {
    _syncCourseMetadata();
    return List<CourseModel>.unmodifiable(_courses);
  }

  static CourseModel? findCourse(String id) {
    _syncCourseMetadata();
    final index = _courses.indexWhere((course) => course.id == id);
    return index == -1 ? null : _courses[index];
  }

  static List<CourseVideoModel> videosForCourse(String courseId) {
    _syncCourseMetadata();
    return List<CourseVideoModel>.unmodifiable(_courseVideos[courseId] ?? []);
  }

  static CourseVideoModel? findVideo(String courseId, String videoId) {
    final videos = _courseVideos[courseId] ?? const <CourseVideoModel>[];
    final index = videos.indexWhere((video) => video.id == videoId);
    return index == -1 ? null : videos[index];
  }

  @override
  Future<List<CourseModel>> getCourses({required UserRole role}) async {
    await Future<void>.delayed(AppDurations.medium);
    _syncCourseMetadata();

    if (role == UserRole.admin) {
      return List<CourseModel>.from(_courses);
    }

    return _courses.where((course) => course.isPublished).toList();
  }

  @override
  Future<List<CourseModel>> getFeaturedCourses() async {
    await Future<void>.delayed(AppDurations.short);
    _syncCourseMetadata();
    return _courses.where((course) => course.isFeatured).toList();
  }

  @override
  Future<CourseModel?> getCourseById(String id) async {
    await Future<void>.delayed(AppDurations.short);
    return findCourse(id);
  }

  @override
  Future<CourseModel> createCourse({
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
    File? imageFile,
  }) async {
    await Future<void>.delayed(AppDurations.medium);

    final course = CourseModel(
      id: 'course-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      instructorName: instructorName,
      category: category,
      level: level,
      duration: '0h 00m',
      totalLessons: 0,
      enrolledCount: 0,
      rating: 0,
      completionPercent: 0,
      isFeatured: false,
      isPublished: isPublished,
      imageUrl: imageFile?.path,
    );

    _courses.insert(0, course);
    _courseVideos[course.id] = <CourseVideoModel>[];
    return course;
  }

  @override
  Future<CourseModel> updateCourse({
    required String id,
    required String title,
    required String description,
    required String instructorName,
    required String category,
    required String level,
    required bool isPublished,
    File? imageFile,
  }) async {
    await Future<void>.delayed(AppDurations.medium);

    final index = _courses.indexWhere((course) => course.id == id);
    if (index == -1) {
      throw StateError('Course not found');
    }

    final updated = _courses[index].copyWith(
      title: title,
      description: description,
      instructorName: instructorName,
      category: category,
      level: level,
      isPublished: isPublished,
      imageUrl: imageFile?.path,
    );

    _courses[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteCourse(String id) async {
    await Future<void>.delayed(AppDurations.medium);
    _courses.removeWhere((course) => course.id == id);
    _courseVideos.remove(id);
  }

  @override
  Future<List<CourseVideoModel>> getCourseVideos(String courseId) async {
    await Future<void>.delayed(AppDurations.short);
    _syncCourseMetadata();
    return List<CourseVideoModel>.from(_courseVideos[courseId] ?? const []);
  }

  @override
  Future<CourseVideoModel> addCourseVideo({
    required String courseId,
    required String title,
    required String description,
    required File videoFile,
    required bool isPreview,
  }) async {
    await Future<void>.delayed(AppDurations.medium);

    final course = findCourse(courseId);
    if (course == null) {
      throw StateError('Course not found');
    }

    final video = CourseVideoModel(
      id: 'video-${DateTime.now().millisecondsSinceEpoch}',
      courseId: courseId,
      title: title,
      description: description,
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      duration: '10:00',
      progress: 0,
      isPreview: isPreview,
      isUploaded: true,
    );

    final updatedVideos = [
      ..._courseVideos[courseId] ?? <CourseVideoModel>[],
      video,
    ];
    _courseVideos[courseId] = updatedVideos;

    final courseIndex = _courses.indexWhere((item) => item.id == courseId);
    _courses[courseIndex] = _courses[courseIndex].copyWith(
      totalLessons: updatedVideos.length,
    );

    return video;
  }

  static void _syncCourseMetadata() {
    for (var index = 0; index < _courses.length; index++) {
      final course = _courses[index];
      final videos = _courseVideos[course.id];
      if (videos == null || videos.isEmpty) {
        continue;
      }

      _courses[index] = course.copyWith(totalLessons: videos.length);
    }
  }
}
