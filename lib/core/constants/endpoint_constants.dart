class EndpointConstants {
  static const String baseUrl =
      'https://e-learning10.runasp.net/api/v1'; // Placeholder URL

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String profile = '/auth/me';

  // Courses
  static const String courses = '/courses';
  static const String enrolledCourses = '/courses/enrolled';
  static const String courseVideos = '/courses/{courseId}/videos';

  // Notifications
  static const String notifications = '/notifications';

  // Comments
  static const String comments = '/comments';

  // Progress
  static const String progress = '/progress';
  static const String progressEnroll = '/progress/enroll';
  static const String progressById = '/progress/{progressId}';
  static const String progressVideoSave = '/progress/video/save';
  static const String progressVideoComplete = '/progress/video/complete';

  // Students
  static const String students = '/students';
  static const String studentById = '/students/{id}';
  static const String studentCourses = '/students/{id}/courses';
  static const String topStudents = '/students/top';

  // Head
  static const String head = '/head';
  static const String headById = '/head/{id}';
}
