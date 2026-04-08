import 'package:dio/dio.dart';
import 'package:e_learning/app/theme/theme_cubit.dart';
import 'package:e_learning/core/network/api_service.dart';
import 'package:e_learning/core/network/session_manager.dart';
import 'package:e_learning/features/auth/data/datasources/auth_data_source.dart';
import 'package:e_learning/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:e_learning/features/auth/domain/repositories/auth_repository.dart';
import 'package:e_learning/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:e_learning/features/auth/domain/usecases/login_usecase.dart';
import 'package:e_learning/features/auth/domain/usecases/sign_in_as_role_usecase.dart';
import 'package:e_learning/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:e_learning/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:e_learning/features/auth/presentation/cubit/student_dashboard_cubit.dart';
import 'package:e_learning/features/auth/presentation/cubit/showcase_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_learning/features/courses/data/datasources/courses_data_source.dart';
import 'package:e_learning/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:e_learning/features/courses/domain/repositories/courses_repository.dart';
import 'package:e_learning/features/courses/domain/usecases/add_course_video_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/create_course_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/delete_course_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_course_by_id_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_course_videos_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/get_featured_courses_usecase.dart';
import 'package:e_learning/features/courses/domain/usecases/update_course_usecase.dart';
import 'package:e_learning/features/courses/presentation/cubit/courses_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/student_course_cubit.dart';
import 'package:e_learning/features/courses/presentation/cubit/video_session_cubit.dart';
import 'package:e_learning/features/comments/data/datasources/comments_data_source.dart';
import 'package:e_learning/features/comments/data/repositories/comments_repository_impl.dart';
import 'package:e_learning/features/comments/domain/repositories/comments_repository.dart';
import 'package:e_learning/features/comments/domain/usecases/add_comment_usecase.dart';
import 'package:e_learning/features/comments/domain/usecases/get_comments_usecase.dart';
import 'package:e_learning/features/comments/presentation/cubit/comments_cubit.dart';
import 'package:e_learning/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:e_learning/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:e_learning/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:e_learning/features/notifications/domain/usecases/create_notification_usecase.dart';
import 'package:e_learning/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:e_learning/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:e_learning/features/progress/data/datasources/progress_data_source.dart';
import 'package:e_learning/features/progress/data/repositories/progress_repository_impl.dart';
import 'package:e_learning/features/progress/domain/repositories/progress_repository.dart';
import 'package:e_learning/features/progress/domain/usecases/enroll_in_course_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/get_progress_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/get_video_progress_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/mark_video_completed_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/save_video_progress_usecase.dart';
import 'package:e_learning/features/progress/domain/usecases/update_progress_usecase.dart';
import 'package:e_learning/features/progress/presentation/cubit/progress_cubit.dart';
import 'package:e_learning/features/students/data/datasources/remote_students_data_source.dart';
import 'package:e_learning/features/students/data/datasources/students_data_source.dart';
import 'package:e_learning/features/students/data/repositories/students_repository_impl.dart';
import 'package:e_learning/features/students/domain/repositories/students_repository.dart';
import 'package:e_learning/features/students/domain/usecases/add_student_course_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/add_student_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/delete_student_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/get_student_by_id_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/get_students_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/get_top_students_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/update_student_usecase.dart';
import 'package:e_learning/features/students/presentation/cubit/students_cubit.dart';
import 'package:e_learning/features/profile/domain/repositories/profile_repository.dart';
import 'package:e_learning/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:e_learning/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:e_learning/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:e_learning/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:e_learning/features/head/data/repositories/head_repository_impl.dart';
import 'package:e_learning/features/head/domain/repositories/head_repository.dart';
import 'package:e_learning/features/head/domain/usecases/get_head_usecase.dart';
import 'package:e_learning/features/head/domain/usecases/create_head_usecase.dart';
import 'package:e_learning/features/head/domain/usecases/update_head_usecase.dart';
import 'package:e_learning/features/head/domain/usecases/delete_head_usecase.dart';
import 'package:e_learning/features/head/presentation/cubit/head_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  if (sl.isRegistered<AuthCubit>()) {
    return;
  }

  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);
  sl.registerLazySingleton(() => SessionManager(sl<SharedPreferences>()));

  sl
    ..registerLazySingleton(ThemeCubit.new)
    ..registerLazySingleton<Dio>(Dio.new)
    ..registerLazySingleton<ApiService>(
      () => ApiService(
        sl<Dio>(),
        tokenProvider: () async => sl<SessionManager>().getToken(),
      ),
    )
    ..registerLazySingleton<AuthDataSource>(
      () => AuthRemoteDataSource(sl<ApiService>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(dataSource: sl<AuthDataSource>()),
    )
    ..registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignInAsRoleUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()))
    ..registerLazySingleton(
      () => AuthCubit(
        login: sl<LoginUseCase>(),
        signInAsRole: sl<SignInAsRoleUseCase>(),
        signOut: sl<SignOutUseCase>(),
        sessionManager: sl<SessionManager>(),
      ),
    )
    ..registerLazySingleton<CoursesDataSource>(
      () => RemoteCoursesDataSource(apiService: sl<ApiService>()),
    )
    ..registerLazySingleton<CoursesRepository>(
      () => CoursesRepositoryImpl(dataSource: sl<CoursesDataSource>()),
    )
    ..registerLazySingleton(() => GetCoursesUseCase(sl<CoursesRepository>()))
    ..registerLazySingleton(
      () => GetFeaturedCoursesUseCase(sl<CoursesRepository>()),
    )
    ..registerLazySingleton(() => GetCourseByIdUseCase(sl<CoursesRepository>()))
    ..registerLazySingleton(() => CreateCourseUseCase(sl<CoursesRepository>()))
    ..registerLazySingleton(() => UpdateCourseUseCase(sl<CoursesRepository>()))
    ..registerLazySingleton(() => DeleteCourseUseCase(sl<CoursesRepository>()))
    ..registerLazySingleton(
      () => GetCourseVideosUseCase(sl<CoursesRepository>()),
    )
    ..registerLazySingleton(
      () => AddCourseVideoUseCase(sl<CoursesRepository>()),
    )
    ..registerFactory(
      () => CoursesCubit(
        getCourses: sl<GetCoursesUseCase>(),
        getFeaturedCourses: sl<GetFeaturedCoursesUseCase>(),
        getCourseById: sl<GetCourseByIdUseCase>(),
        createCourse: sl<CreateCourseUseCase>(),
        updateCourse: sl<UpdateCourseUseCase>(),
        deleteCourse: sl<DeleteCourseUseCase>(),
        getCourseVideos: sl<GetCourseVideosUseCase>(),
        addCourseVideo: sl<AddCourseVideoUseCase>(),
      ),
    )
    ..registerFactory(
      () => StudentDashboardCubit(
        getCourses: sl<GetCoursesUseCase>(),
        getProgress: sl<GetProgressUseCase>(),
      ),
    )
    ..registerFactory(
      () => StudentCourseCubit(
        getCourseById: sl<GetCourseByIdUseCase>(),
        getCourseVideos: sl<GetCourseVideosUseCase>(),
        getProgress: sl<GetProgressUseCase>(),
        getVideoProgress: sl<GetVideoProgressUseCase>(),
      ),
    )
    ..registerLazySingleton<StudentsDataSource>(
      () => RemoteStudentsDataSource(apiService: sl<ApiService>()),
    )
    ..registerLazySingleton<StudentsRepository>(
      () => StudentsRepositoryImpl(dataSource: sl<StudentsDataSource>()),
    )
    ..registerLazySingleton(() => GetStudentsUseCase(sl<StudentsRepository>()))
    ..registerLazySingleton(
      () => GetStudentByIdUseCase(sl<StudentsRepository>()),
    )
    ..registerLazySingleton(() => AddStudentUseCase(sl<StudentsRepository>()))
    ..registerLazySingleton(
      () => UpdateStudentUseCase(sl<StudentsRepository>()),
    )
    ..registerLazySingleton(
      () => DeleteStudentUseCase(sl<StudentsRepository>()),
    )
    ..registerLazySingleton(
      () => AddStudentCourseUseCase(sl<StudentsRepository>()),
    )
    ..registerLazySingleton(
      () => GetTopStudentsUseCase(sl<StudentsRepository>()),
    )
    ..registerFactory(
      () => StudentsCubit(
        getStudents: sl<GetStudentsUseCase>(),
        getStudentById: sl<GetStudentByIdUseCase>(),
        addStudent: sl<AddStudentUseCase>(),
        updateStudent: sl<UpdateStudentUseCase>(),
        deleteStudent: sl<DeleteStudentUseCase>(),
        addStudentCourse: sl<AddStudentCourseUseCase>(),
        getTopStudents: sl<GetTopStudentsUseCase>(),
      ),
    )
    ..registerLazySingleton<ProgressDataSource>(
      () => RemoteProgressDataSource(apiService: sl<ApiService>()),
    )
    ..registerLazySingleton<ProgressRepository>(
      () => ProgressRepositoryImpl(dataSource: sl<ProgressDataSource>()),
    )
    ..registerLazySingleton(() => GetProgressUseCase(sl<ProgressRepository>()))
    ..registerLazySingleton(
      () => GetVideoProgressUseCase(sl<ProgressRepository>()),
    )
    ..registerLazySingleton(
      () => SaveVideoProgressUseCase(sl<ProgressRepository>()),
    )
    ..registerLazySingleton(
      () => MarkVideoCompletedUseCase(sl<ProgressRepository>()),
    )
    ..registerLazySingleton(
      () => UpdateProgressUseCase(sl<ProgressRepository>()),
    )
    ..registerLazySingleton(
      () => EnrollInCourseUseCase(sl<ProgressRepository>()),
    )
    ..registerFactory(
      () => ProgressCubit(
        getProgress: sl<GetProgressUseCase>(),
        updateProgress: sl<UpdateProgressUseCase>(),
        enrollInCourse: sl<EnrollInCourseUseCase>(),
      ),
    )
    ..registerFactory(
      () => VideoSessionCubit(
        getCourseById: sl<GetCourseByIdUseCase>(),
        getCourseVideos: sl<GetCourseVideosUseCase>(),
        getVideoProgress: sl<GetVideoProgressUseCase>(),
        saveVideoProgress: sl<SaveVideoProgressUseCase>(),
        markVideoCompleted: sl<MarkVideoCompletedUseCase>(),
      ),
    )
    ..registerLazySingleton<CommentsDataSource>(MockCommentsDataSource.new)
    ..registerFactory(
      () => ShowcaseCubit(
        getHeadUseCase: sl<GetHeadUseCase>(),
        getTopStudentsUseCase: sl<GetTopStudentsUseCase>(),
      ),
    )
    ..registerLazySingleton<CommentsRepository>(
      () => CommentsRepositoryImpl(dataSource: sl<CommentsDataSource>()),
    )
    ..registerLazySingleton(() => GetCommentsUseCase(sl<CommentsRepository>()))
    ..registerLazySingleton(() => AddCommentUseCase(sl<CommentsRepository>()))
    ..registerFactory(
      () => CommentsCubit(
        getComments: sl<GetCommentsUseCase>(),
        addComment: sl<AddCommentUseCase>(),
      ),
    )
    ..registerLazySingleton<NotificationsDataSource>(
      () => RemoteNotificationsDataSource(apiService: sl<ApiService>()),
    )
    ..registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(
        dataSource: sl<NotificationsDataSource>(),
      ),
    )
    ..registerLazySingleton(
      () => GetNotificationsUseCase(sl<NotificationsRepository>()),
    )
    ..registerLazySingleton(
      () => WatchNotificationsUseCase(sl<NotificationsRepository>()),
    )
    ..registerLazySingleton(
      () => CreateNotificationUseCase(sl<NotificationsRepository>()),
    )
    ..registerLazySingleton(
      () => MarkNotificationReadUseCase(sl<NotificationsRepository>()),
    )
    ..registerFactory(
      () => NotificationsCubit(
        getNotifications: sl<GetNotificationsUseCase>(),
        watchNotifications: sl<WatchNotificationsUseCase>(),
        createNotification: sl<CreateNotificationUseCase>(),
        markNotificationRead: sl<MarkNotificationReadUseCase>(),
      ),
    )
    ..registerLazySingleton<ProfileRepository>(MockProfileRepository.new)
    ..registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepository>()))
    ..registerLazySingleton(() => UpdateProfileUseCase(sl<ProfileRepository>()))
    ..registerFactory(
      () => ProfileCubit(
        getProfile: sl<GetProfileUseCase>(),
        updateProfile: sl<UpdateProfileUseCase>(),
      ),
    )
    ..registerLazySingleton<HeadRepository>(
      () => HeadRepositoryImpl(sl<ApiService>()),
    )
    ..registerLazySingleton(() => GetHeadUseCase(sl<HeadRepository>()))
    ..registerLazySingleton(() => CreateHeadUseCase(sl<HeadRepository>()))
    ..registerLazySingleton(() => UpdateHeadUseCase(sl<HeadRepository>()))
    ..registerLazySingleton(() => DeleteHeadUseCase(sl<HeadRepository>()))
    ..registerFactory(
      () => HeadCubit(
        getHeadUseCase: sl<GetHeadUseCase>(),
        createHeadUseCase: sl<CreateHeadUseCase>(),
        updateHeadUseCase: sl<UpdateHeadUseCase>(),
        deleteHeadUseCase: sl<DeleteHeadUseCase>(),
      ),
    );
}

Future<void> resetDependencies() {
  return sl.reset();
}
