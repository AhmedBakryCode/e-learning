import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_learning/features/auth/presentation/cubit/showcase_state.dart';
import 'package:e_learning/features/head/domain/entities/head.dart';
import 'package:e_learning/features/head/domain/usecases/get_head_usecase.dart';
import 'package:e_learning/features/students/domain/usecases/get_top_students_usecase.dart';
import 'package:e_learning/features/students/data/models/student_model.dart';
import 'package:e_learning/core/constants/view_state_status.dart';

class ShowcaseCubit extends Cubit<ShowcaseState> {
  ShowcaseCubit({
    required GetHeadUseCase getHeadUseCase,
    required GetTopStudentsUseCase getTopStudentsUseCase,
  }) : _getHeadUseCase = getHeadUseCase,
       _getTopStudentsUseCase = getTopStudentsUseCase,
       super(const ShowcaseState());

  final GetHeadUseCase _getHeadUseCase;
  final GetTopStudentsUseCase _getTopStudentsUseCase;

  Future<void> loadShowcase() async {
    emit(state.copyWith(status: ViewStateStatus.loading));

    List<Head>? fetchedHeads;
    List<StudentModel>? fetchedStudents;
    String? error;

    await Future.wait([
      // Fetch Heads
      () async {
        try {
          final results = await _getHeadUseCase.call();
          fetchedHeads = results.cast<Head>();
        } catch (e) {
          error = e.toString();
        }
      }(),
      // Fetch Top Students
      () async {
        try {
          final results = await _getTopStudentsUseCase.call(
            const GetTopStudentsParams(limit: 5),
          );
          fetchedStudents = results.map((s) => StudentModel(
            id: s.id,
            name: s.name,
            email: s.email,
            activeCourses: s.activeCourses,
            completionRate: s.completionRate,
            phoneNumber: s.phoneNumber,
            parentPhoneNumber: s.parentPhoneNumber,
            profileImageUrl: s.profileImageUrl,
          )).toList();
        } catch (e) {
          error = e.toString();
        }
      }(),
    ]);

    // If both failed, then it's a failure status
    if (fetchedHeads == null && fetchedStudents == null) {
      emit(state.copyWith(
        status: ViewStateStatus.failure,
        errorMessage: error ?? 'Unknown error',
      ));
    } else {
      // Partial success is still success for the UI
      emit(state.copyWith(
        status: ViewStateStatus.success,
        heads: fetchedHeads ?? [],
        topStudents: fetchedStudents ?? [],
      ));
    }
  }
}
